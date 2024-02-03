import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:flama/flama.dart';
import 'package:flama_bindings/flama_bindings.dart';

/// {@template llama_local}
/// Llama local language model supported by llama.cpp library.
/// {@endtemplate}
class LlamaLocal extends LLMBase {
  /// {@macro llama_local}
  LlamaLocal._(
    this._bindings,
    this._model,
    this._ctx,
    this._eosToken, {
    required super.seed,
    required super.model,
    required super.temperature,
    required super.maxTokens,
    required super.topK,
    required super.topP,
  });

  /// Create a new instance of [LlamaLocal] model.
  static Future<LlamaLocal> create({
    required String libraryPath,
    required String modelPath,
    int seed = 0,
    double temperature = 0.85,
    int maxTokens = 1024,
    int topK = 40,
    double topP = 0.9,
    int nGpuLayers = 999,
  }) async {
    final bindings = FlamaBindings(
      DynamicLibrary.open(libraryPath),
    );

    final params = bindings.llama_model_default_params()
      ..n_gpu_layers = nGpuLayers;

    bindings.llama_backend_init(true);

    final model = bindings.llama_load_model_from_file(
      modelPath.toNativeUtf8().cast<Char>(),
      params,
    );

    final ctxParams = bindings.llama_context_default_params()
      ..seed = seed == 0 ? math.Random().nextInt(1000) : seed
      ..n_ctx = maxTokens
      ..n_batch = maxTokens;

    final ctx = bindings.llama_new_context_with_model(
      model,
      ctxParams,
    );

    final nCtx = bindings.llama_n_ctx(ctx);

    if (maxTokens > nCtx) {
      throw Exception(
        'error: nKvReq > nCtx, the required KV cache size is not big enough',
      );
    }

    final eosToken = bindings.llama_token_eos(model);

    return LlamaLocal._(
      bindings,
      model,
      ctx,
      eosToken,
      seed: seed == 0 ? math.Random().nextInt(1000) : seed,
      model: modelPath,
      temperature: temperature,
      maxTokens: maxTokens,
      topK: topK,
      topP: topP,
    );
  }

  // llama.cpp bindings
  final FlamaBindings _bindings;

  // Model
  final Pointer<llama_model> _model;

  // Context
  final Pointer<llama_context> _ctx;

  // End of sequence token
  final int _eosToken;

  //--------------------------------------------
  // Inference artifacts
  //--------------------------------------------
  llama_batch? _batch;
  //--------------------------------------------

  @override
  Future<String> request(String input) async {
    final result = StringBuffer();

    await for (final output in stream(input)) {
      result.write(output);
    }

    return result.toString();
  }

  @override
  Stream<String> stream(String input) {
    _init(input);
    return _run();
  }

  // Initialize
  void _init(String input) {
    if (_batch != null) {
      _bindings.llama_batch_free(_batch!);
    }

    final (tokens, nTokens) = _bindings.llamaTokenize(
      model: _model,
      text: input,
      addBos: true,
    );

    _batch = _bindings.llama_batch_init(math.max(nTokens, 1), 0, 1);

    // Evaluate the initial prompt
    for (var i = 0; i < nTokens; ++i) {
      final token = tokens[i];
      _bindings.llamaBatchAdd(
        batch: _batch!,
        token: token,
        pos: i,
        seqIds: [0],
        logits: false,
      );
    }

    _batch!.logits[_batch!.n_tokens - 1] = 1;

    // Initial evaluation
    final result = _bindings.llama_decode(_ctx, _batch!);

    if (result != 0) {
      throw Exception('error: llama_decode failed');
    }
  }

  // Run inference
  Stream<String> _run() async* {
    assert(_batch != null, 'Batch is not initialized');

    var nCur = _batch!.n_tokens;
    var nTokens = _batch!.n_tokens - 1;

    while (nCur <= maxTokens) {
      // Prepare the next batch
      _batch!.n_tokens = 0;

      // Sample the next token for each parallel sequence / stream

      if (nTokens < 0) {
        // the stream has already finished
        break;
      }

      final nVocab = _bindings.llama_n_vocab(_model);
      final logits = _bindings.llama_get_logits_ith(_ctx, nTokens);

      final candidates = malloc
          .allocate<llama_token_data>(nVocab * sizeOf<llama_token_data>());

      for (var tokenId = 0; tokenId < nVocab; tokenId++) {
        candidates[tokenId].id = tokenId;
        candidates[tokenId].logit = logits[tokenId];
        candidates[tokenId].p = 0.0;
      }

      final candidatePPtr = malloc
          .allocate<llama_token_data_array>(sizeOf<llama_token_data_array>());
      candidatePPtr[0]
        ..data = candidates
        ..size = nVocab
        ..sorted = false;

      _bindings
        ..llama_sample_top_k(_ctx, candidatePPtr, topK, 1)
        ..llama_sample_top_p(_ctx, candidatePPtr, topP, 1)
        ..llama_sample_temp(_ctx, candidatePPtr, temperature);

      final newTokenId = _bindings.llama_sample_token(_ctx, candidatePPtr);

      // is it an end of stream? -> mark the stream as finished
      if (newTokenId == _eosToken || nCur == maxTokens) {
        nTokens = -1;
        malloc
          ..free(candidates)
          ..free(candidatePPtr);

        continue;
      }

      // if there is only one stream, we print immediately to stdout
      final token = _bindings.llamaTokenToPiece(_ctx, newTokenId);

      yield token;

      nTokens = _batch!.n_tokens;

      // Push this new token for next evaluation
      _bindings.llamaBatchAdd(
        batch: _batch!,
        token: newTokenId,
        pos: nCur,
        seqIds: [0],
        logits: true,
      );

      malloc
        ..free(candidates)
        ..free(candidatePPtr);

      // all streams are finished
      if (_batch!.n_tokens == 0) {
        break;
      }

      nCur += 1;

      // evaluate the current batch with the transformer model
      _bindings.llama_decode(_ctx, _batch!);
    }

    _bindings.llama_batch_free(_batch!);

    _batch = null;

    return;
  }

  @override
  Future<void> dispose() async {
    _bindings
      ..llama_free(_ctx)
      ..llama_free_model(_model)
      ..llama_backend_free();
  }
}

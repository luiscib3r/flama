import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:flama_bindings/flama_bindings.dart';

void main() {
  // Initialize binding
  final flamaBindings = FlamaBindings(
    DynamicLibrary.open('libllama.dylib'),
  );

  // Number of parallel batches
  final nParallel = 1;

  // Total length of the sequence including the prompt
  final nLen = 1024;

  // number of layers to offload to the GPU
  final nGpuLayers = 999;

  // Params
  final modelPath = 'orca-mini-3b-q4_0.gguf';
  final prompt = 'Tips to build large scale systems';
  final params = flamaBindings.llama_model_default_params();
  params.n_gpu_layers = nGpuLayers;

  // Init backend
  flamaBindings.llama_backend_init(true);

  // Initialize the model
  final model = flamaBindings.llama_load_model_from_file(
    modelPath.toNativeUtf8().cast<Char>(),
    params,
  );

  final eosToken = flamaBindings.llama_token_eos(model);

  // Tokenize the prompt
  final (tokenList, nTokens) = flamaBindings.llamaTokenize(
    model: model,
    text: prompt,
    addBos: true,
  );

  final nKvReq = nTokens + (nLen - nTokens) * nParallel;

  // Initialize context
  final contextParams = flamaBindings.llama_context_default_params();
  // contextParams.seed = 1234;
  contextParams.n_ctx = nKvReq;
  contextParams.n_batch = math.max(nLen, nParallel);

  final ctx = flamaBindings.llama_new_context_with_model(
    model,
    contextParams,
  );

  final nCtx = flamaBindings.llama_n_ctx(ctx);

  if (nKvReq > nCtx) {
    throw Exception(
      'error: nKvReq (%d) > nCtx, the required KV cache size is not big enough'
      'either reduce nParallel or increase nCtx',
    );
  }

  // Print the prompt token-by-token
  final pices = <String>[];
  for (var i = 0; i < nTokens; ++i) {
    final token = tokenList[i];
    final piece = flamaBindings.llamaTokenToPiece(ctx, token);
    pices.add(piece);
  }
  stdout.write('Prompt: ');
  stdout.write(pices.join('').trim());

  // Create a batch
  // We use this object to submit token data for decoding
  final batch =
      flamaBindings.llama_batch_init(math.max(nTokens, nParallel), 0, 1);

  // Evaluate the initial prompt
  for (var i = 0; i < nTokens; ++i) {
    final token = tokenList[i];
    flamaBindings.llamaBatchAdd(
      batch: batch,
      token: token,
      pos: i,
      seqIds: [0],
      logits: false,
    );
  }
  assert(batch.n_tokens == nTokens);

  // llama_decode will output logits only for the last token of the prompt
  batch.logits[batch.n_tokens - 1] = 1;

  // Run inference
  final result = flamaBindings.llama_decode(ctx, batch);

  if (result != 0) {
    throw Exception('error: llama_decode failed');
  }

  // Assign the system KV cache to all parallel sequences
  // This way, the parallel sequences will "reuse" the prompt tokens
  // without having to copy them
  for (var i = 1; i < nParallel; ++i) {
    flamaBindings.llama_kv_cache_seq_cp(ctx, 0, i, 0, batch.n_tokens);
  }

  // Main loop
  // We will store the parallel decoded sequences in this vector
  List<String> streams = List.filled(nParallel, '');

  // Remember the batch index of the last token for each parallel sequence
  // we need this to determine which logits to sample from
  final iBatch = malloc.allocate<Int32>(nParallel * sizeOf<Int32>());
  for (var i = 0; i < nParallel; ++i) {
    iBatch[i] = batch.n_tokens - 1;
  }

  var nCur = batch.n_tokens;

  while (nCur <= nLen) {
    // Prepare the next batch
    batch.n_tokens = 0;

    // Sample the next token for each parallel sequence / stream
    for (var i = 0; i < nParallel; ++i) {
      if (iBatch[i] < 0) {
        // the stream has already finished
        continue;
      }

      final nVocab = flamaBindings.llama_n_vocab(model);
      final logits = flamaBindings.llama_get_logits_ith(ctx, iBatch[i]);

      final candidates = malloc
          .allocate<llama_token_data>(nVocab * sizeOf<llama_token_data>());

      for (var tokenId = 0; tokenId < nVocab; tokenId++) {
        candidates[tokenId].id = tokenId;
        candidates[tokenId].logit = logits[tokenId];
        candidates[tokenId].p = 0.0;
      }

      final candidatePPtr = malloc
          .allocate<llama_token_data_array>(sizeOf<llama_token_data_array>());
      final candidateP = candidatePPtr[0];
      candidateP.data = candidates;
      candidateP.size = nVocab;
      candidateP.sorted = false;

      const topK = 40;
      const topP = 0.9;
      const temp = 0.85;

      flamaBindings.llama_sample_top_k(ctx, candidatePPtr, topK, 1);
      flamaBindings.llama_sample_top_p(ctx, candidatePPtr, topP, 1);
      flamaBindings.llama_sample_temp(ctx, candidatePPtr, temp);

      final newTokenId = flamaBindings.llama_sample_token(ctx, candidatePPtr);

      // is it an end of stream? -> mark the stream as finished
      if (newTokenId == eosToken || nCur == nLen) {
        iBatch[i] = -1;
        malloc.free(candidates);
        malloc.free(candidatePPtr);
        continue;
      }

      // if there is only one stream, we print immediately to stdout
      final token = flamaBindings.llamaTokenToPiece(ctx, newTokenId);

      if (nParallel == 1) {
        stdout.write(token);
      }

      streams[i] += token;
      iBatch[i] = batch.n_tokens;

      // Push this new token for next evaluation
      flamaBindings.llamaBatchAdd(
        batch: batch,
        token: newTokenId,
        pos: nCur,
        seqIds: [i],
        logits: true,
      );

      malloc.free(candidates);
      malloc.free(candidatePPtr);
    }

    // all streams are finished
    if (batch.n_tokens == 0) {
      break;
    }

    nCur += 1;

    // evaluate the current batch with the transformer model
    flamaBindings.llama_decode(ctx, batch);
  }

  if (nParallel > 1) {
    for (var i = 0; i < nParallel; ++i) {
      stdout.write('Sequence $i: ${streams[i]}');
    }
  }

  stdout.writeln('\n');
  malloc.free(tokenList);
  malloc.free(iBatch);
  flamaBindings.llama_batch_free(batch);
  flamaBindings.llama_free(ctx);
  flamaBindings.llama_free_model(model);
  flamaBindings.llama_backend_free();
}

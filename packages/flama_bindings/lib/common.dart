import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flama_bindings/bindings/flama_bindings.dart';

extension CommonExtension on FlamaBindings {
  (Pointer<llama_token>, int) llamaTokenize({
    required Pointer<llama_model> model,
    required String text,
    required bool addBos,
    bool special = false,
  }) {
    // upper limit for the number of tokens
    final maxTokens = text.length + (addBos ? 1 : 0) + 1;
    final tokens =
        malloc.allocate<llama_token>(maxTokens * sizeOf<llama_token>());

    final nTokens = llama_tokenize(
      model,
      text.toNativeUtf8().cast(),
      maxTokens,
      tokens,
      maxTokens,
      addBos,
      special,
    );

    final result =
        malloc.allocate<llama_token>(nTokens * sizeOf<llama_token>());

    if (nTokens < 0) {
      malloc.free(tokens);
      throw Exception('Tokenization failed');
    }

    for (var i = 0; i < nTokens; ++i) {
      result[i] = tokens[i];
    }

    malloc.free(tokens);

    return (result, nTokens);
  }

  String llamaTokenToPiece(Pointer<llama_context> ctx, int token) {
    final tokens = malloc.allocate<Char>(8);

    final model = llama_get_model(ctx);
    final nTokens = llama_token_to_piece(model, token, tokens, 8);

    if (nTokens < 0) {
      return '';
    }

    return tokens.cast<Utf8>().toDartString();
  }

  llama_batch llamaBatchAdd({
    required llama_batch batch,
    required int token,
    required int pos,
    required List<int> seqIds,
    required bool logits,
  }) {
    batch.token[batch.n_tokens] = token;
    batch.pos[batch.n_tokens] = pos;
    batch.n_seq_id[batch.n_tokens] = seqIds.length;

    for (var i = 0; i < seqIds.length; ++i) {
      batch.seq_id[batch.n_tokens][i] = seqIds[i];
    }

    batch.logits[batch.n_tokens] = logits ? 1 : 0;
    batch.n_tokens += 1;

    return batch;
  }
}

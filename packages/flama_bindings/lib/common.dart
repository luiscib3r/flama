import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flama_bindings/bindings/flama_bindings.dart';

/// Common extension for the [FlamaBindings] class.
extension CommonExtension on FlamaBindings {
  /// Tokenize the given [text].
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

  /// Get string representation of the token.
  String llamaTokenToPiece(Pointer<llama_context> ctx, int token) {
    final buffer = malloc.allocate<Char>(8);
    for (var i = 0; i < 8; ++i) {
      buffer[i] = 0;
    }

    final model = llama_get_model(ctx);
    llama_token_to_piece(model, token, buffer, 8);

    try {
      return buffer.cast<Utf8>().toDartString();
    } on FormatException {
      return '';
    } finally {
      malloc.free(buffer);
    }
  }

  /// Add a token to the batch.
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

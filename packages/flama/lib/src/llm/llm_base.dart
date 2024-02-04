/// {@template llm_base}
/// Abstract class for language models.
/// {@endtemplate}
abstract class LLMBase {
  /// {@macro llm_base}
  const LLMBase();

  /// Run inference on the model.
  Stream<String> call(String input, {bool streamed = true}) async* {
    if (streamed) {
      yield* stream(input);
      return;
    }

    yield await request(input);
  }

  /// Run async inference.
  Future<String> request(String input);

  /// Run streamed inference.
  Stream<String> stream(String input);

  /// Dispose resources.
  Future<void> dispose();
}

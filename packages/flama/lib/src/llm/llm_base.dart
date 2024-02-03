/// {@template llm_base}
/// Abstract class for language models.
/// {@endtemplate}
abstract class LLMBase {
  /// {@macro llm_base}
  const LLMBase({
    required this.seed,
    required this.model,
    required this.temperature,
    required this.maxTokens,
    required this.topK,
    required this.topP,
  });

  /// Seed for random number generation.
  final int seed;

  /// Model path.
  final String model;

  /// Temperature.
  final double temperature;

  /// Maximum number of tokens.
  final int maxTokens;

  /// Top-K: the number of highest probability vocabulary
  /// tokens to keep for sampling.
  final int topK;

  /// Top-P: the cumulative probability of the highest
  /// probability vocabulary tokens to keep for sampling.
  final double topP;

  /// Run inference on the model.
  Stream<String> call(String input, {bool streamed = true}) async* {
    if (streamed) {
      yield* stream(input);
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

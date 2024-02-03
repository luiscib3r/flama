/// {@template llm}
/// Abstract class for language models.
/// {@endtemplate}
abstract class LLM {
  /// {@macro llm}
  const LLM({
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
  final int topP;

  /// Run inference on the model.
  Future<(String?, Stream<String>?)> call(
    String input, {
    bool streamed = true,
  }) async {
    if (streamed) {
      return (null, stream(input));
    }

    return (await request(input), null);
  }

  /// Run inference.
  Future<String> request(String input);

  /// Run inference with streaming.
  Stream<String> stream(String input);
}

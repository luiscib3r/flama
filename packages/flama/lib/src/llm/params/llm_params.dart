import 'package:equatable/equatable.dart';
import 'package:flama/flama.dart';

export 'llama_local_params.dart';

/// {@template llm_params}
/// Llm params
/// {@endtemplate}
abstract class LlmParams extends Equatable {
  /// {@macro llm_params}
  const LlmParams({
    required this.seed,
    required this.model,
    required this.temperature,
    required this.maxTokens,
    required this.topK,
    required this.topP,
  });

  /// Create [LlmParams] from json
  factory LlmParams.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'LlamaLocalParams':
        return LlamaLocalParams.fromJson(json);
      default:
        throw ArgumentError('Invalid params type: ${json['type']}');
    }
  }

  /// Convert [LlmParams] to json
  Map<String, dynamic> toJson();

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

  @override
  List<Object?> get props => [
        seed,
        model,
        temperature,
        maxTokens,
        topK,
        topP,
      ];
}

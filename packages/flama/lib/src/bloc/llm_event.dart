part of 'llm_bloc.dart';

/// {@template llm_event}
/// [LlmBloc] base events
/// {@endtemplate}
sealed class LlmEvent extends Equatable {
  const LlmEvent();

  factory LlmEvent.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'LlmGenerate':
        return LlmGenerate.fromJson(json);
      default:
        throw ArgumentError('Invalid event type: ${json['type']}');
    }
  }

  /// Convert [LlmEvent] to json
  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [];
}

/// {@template llm_generate}
/// Generate text using [input]
/// {@endtemplate}
@JsonSerializable()
final class LlmGenerate extends LlmEvent {
  /// {@macro llm_generate}
  const LlmGenerate(this.input);

  /// Create [LlmGenerate] from json
  factory LlmGenerate.fromJson(Map<String, dynamic> json) =>
      _$LlmGenerateFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlmGenerateToJson(this),
        'type': runtimeType,
      };

  /// Input text
  final String input;

  @override
  List<Object?> get props => [input];
}

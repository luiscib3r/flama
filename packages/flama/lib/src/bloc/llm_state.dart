part of 'llm_bloc.dart';

/// {@template llm_state}
/// LlmState
/// {@endtemplate}
sealed class LlmState extends Equatable {
  const LlmState();

  /// Convert [LlmState] to json
  Map<String, dynamic> toJson();

  /// Map [LlmState] to type [T]
  T map<T>({
    required T Function(LlmLoading) loading,
    required T Function(LlmIdle) idle,
    required T Function(LlmGenerating) generating,
    required T Function(LlmDone) done,
  }) {
    if (this is LlmLoading) {
      return loading(this as LlmLoading);
    } else if (this is LlmIdle) {
      return idle(this as LlmIdle);
    } else if (this is LlmGenerating) {
      return generating(this as LlmGenerating);
    } else if (this is LlmDone) {
      return done(this as LlmDone);
    } else {
      throw AssertionError('Unknown state: $this');
    }
  }

  @override
  List<Object?> get props => [];
}

/// {@template llm_loading}
/// LLM is loading
/// {@endtemplate}
@JsonSerializable()
final class LlmLoading extends LlmState {
  /// {@macro llm_loading}
  const LlmLoading();

  /// Create [LlmLoading] from json
  factory LlmLoading.fromJson(Map<String, dynamic> json) =>
      _$LlmLoadingFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlmLoadingToJson(this),
        'type': runtimeType,
      };
}

/// {@template llm_idle}
/// LLM is idle
/// {@endtemplate}
@JsonSerializable()
final class LlmIdle extends LlmState {
  /// {@macro llm_idle}
  const LlmIdle();

  /// Create [LlmIdle] from json
  factory LlmIdle.fromJson(Map<String, dynamic> json) =>
      _$LlmIdleFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlmIdleToJson(this),
        'type': runtimeType,
      };
}

/// {@template llm_generating}
/// LLM is generating text
/// {@endtemplate}
@JsonSerializable()
final class LlmGenerating extends LlmState {
  /// {@macro llm_generating}
  const LlmGenerating(this.text);

  /// Create [LlmGenerating] from json
  factory LlmGenerating.fromJson(Map<String, dynamic> json) =>
      _$LlmGeneratingFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlmGeneratingToJson(this),
        'type': runtimeType,
      };

  /// Generated text
  final String text;

  @override
  List<Object?> get props => [text];
}

/// {@template llm_done}
/// LLM is done
/// {@endtemplate}
@JsonSerializable()
final class LlmDone extends LlmState {
  /// {@macro llm_done}
  const LlmDone(this.text);

  /// Create [LlmDone] from json
  factory LlmDone.fromJson(Map<String, dynamic> json) =>
      _$LlmDoneFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlmDoneToJson(this),
        'type': runtimeType,
      };

  /// Generated text
  final String text;

  @override
  List<Object?> get props => [text];
}

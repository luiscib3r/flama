import 'package:flama/flama.dart';
import 'package:json_annotation/json_annotation.dart';

part 'llama_local_params.g.dart';

/// {@template llama_local_params}
/// [LlamaLocal] params
/// {@endtemplate}
@JsonSerializable()
class LlamaLocalParams extends LlmParams {
  /// {@macro llama_local_params}
  const LlamaLocalParams({
    required super.model,
    super.topP = 0.9,
    super.topK = 40,
    super.maxTokens = 2048,
    super.temperature = 0.85,
    super.seed = 0,
    this.nGpuLayers = 999,
    this.library,
  });

  /// Create [LlamaLocalParams] from json
  factory LlamaLocalParams.fromJson(Map<String, dynamic> json) =>
      _$LlamaLocalParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$LlamaLocalParamsToJson(this),
        'type': runtimeType,
      };

  /// Dynamic library path (Optional)
  final String? library;

  /// Number of GPU layers in VRAM
  final int nGpuLayers;

  @override
  List<Object?> get props => [
        ...super.props,
        library,
        nGpuLayers,
      ];
}

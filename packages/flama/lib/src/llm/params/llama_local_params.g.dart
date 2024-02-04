// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llama_local_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlamaLocalParams _$LlamaLocalParamsFromJson(Map<String, dynamic> json) =>
    LlamaLocalParams(
      model: json['model'] as String,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      topK: json['topK'] as int? ?? 40,
      maxTokens: json['maxTokens'] as int? ?? 1024,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.85,
      seed: json['seed'] as int? ?? 0,
      nGpuLayers: json['nGpuLayers'] as int? ?? 999,
      library: json['library'] as String?,
    );

Map<String, dynamic> _$LlamaLocalParamsToJson(LlamaLocalParams instance) =>
    <String, dynamic>{
      'seed': instance.seed,
      'model': instance.model,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'topK': instance.topK,
      'topP': instance.topP,
      'library': instance.library,
      'nGpuLayers': instance.nGpuLayers,
    };

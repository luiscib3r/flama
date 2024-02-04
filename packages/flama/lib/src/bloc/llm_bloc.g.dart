// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmGenerate _$LlmGenerateFromJson(Map<String, dynamic> json) => LlmGenerate(
      json['input'] as String,
    );

Map<String, dynamic> _$LlmGenerateToJson(LlmGenerate instance) =>
    <String, dynamic>{
      'input': instance.input,
    };

LlmLoading _$LlmLoadingFromJson(Map<String, dynamic> json) => LlmLoading();

Map<String, dynamic> _$LlmLoadingToJson(LlmLoading instance) =>
    <String, dynamic>{};

LlmIdle _$LlmIdleFromJson(Map<String, dynamic> json) => LlmIdle();

Map<String, dynamic> _$LlmIdleToJson(LlmIdle instance) => <String, dynamic>{};

LlmGenerating _$LlmGeneratingFromJson(Map<String, dynamic> json) =>
    LlmGenerating(
      json['text'] as String,
    );

Map<String, dynamic> _$LlmGeneratingToJson(LlmGenerating instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

LlmDone _$LlmDoneFromJson(Map<String, dynamic> json) => LlmDone(
      json['text'] as String,
    );

Map<String, dynamic> _$LlmDoneToJson(LlmDone instance) => <String, dynamic>{
      'text': instance.text,
    };

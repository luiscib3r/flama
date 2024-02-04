// ignore_for_file: no_runtimetype_tostring

import 'dart:async';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flama/src/flama.dart';
import 'package:json_annotation/json_annotation.dart';

part 'llama_local_bloc.dart';
part 'llm_bloc.g.dart';
part 'llm_event.dart';
part 'llm_state.dart';

/// {@template llm_bloc}
/// LlmBloc
/// {@endtemplate}
abstract class LlmBloc extends Cubit<LlmState> {
  /// {@macro llm_bloc}
  LlmBloc() : super(const LlmLoading());

  late final Isolate _isolate;
  late final SendPort _sendPort;
  late StreamSubscription<dynamic> _subscription;

  /// Run llm model in isolate
  Future<void> run(LlmParams params);

  /// Generate text using [input]
  void generate(String input) {
    _sendPort.send(LlmGenerate(input));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    _isolate.kill();
    return super.close();
  }
}

class _LlmBlocIsolate extends Bloc<LlmEvent, LlmState> {
  _LlmBlocIsolate({
    required this.model,
    required this.receivePort,
    required this.sendPort,
  }) : super(const LlmIdle()) {
    on<LlmGenerate>(_generate);

    _run();
  }

  final ReceivePort receivePort;
  final SendPort sendPort;

  final LLMBase model;

  Future<void> _run() async {
    await for (final event in receivePort) {
      if (event is LlmEvent) {
        add(event);
      }
    }
  }

  StreamSubscription<String>? _tokenStreams;
  final StringBuffer _buffer = StringBuffer();
  Future<void> _generate(
    LlmGenerate event,
    Emitter<LlmState> emit,
  ) async {
    if (state is LlmLoading || state is LlmGenerating) {
      return;
    }

    emit(const LlmLoading());
    await for (final token in model(event.input)) {
      _buffer.write(token);
      emit(LlmGenerating(_buffer.toString()));
    }

    emit(LlmDone(_buffer.toString()));
    _buffer.clear();
  }

  @override
  void onChange(Change<LlmState> change) {
    sendPort.send(change.nextState);
    super.onChange(change);
  }

  @override
  Future<void> close() {
    _tokenStreams?.cancel();
    receivePort.close();
    return super.close();
  }
}

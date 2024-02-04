part of 'llm_bloc.dart';

/// {@template llama_local_bloc}
/// LlamaLocalBloc
/// {@endtemplate}
class LlamaLocalBloc extends LlmBloc {
  @override
  Future<void> run(LlmParams params) async {
    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _start,
      [receivePort.sendPort, params],
      debugName: '$runtimeType',
    );

    _subscription = receivePort.listen((message) {
      if (message is LlmState) {
        emit(message);
        return;
      }

      if (message is SendPort) {
        _sendPort = message;
      }
    });
  }

  static Future<void> _start(List<dynamic> params) async {
    final receivePort = ReceivePort();
    final sendPort = params[0] as SendPort;
    final llmParams = params[1] as LlmParams;

    sendPort.send(receivePort.sendPort);

    final model = await LlamaLocal.create(
      llmParams as LlamaLocalParams,
    );

    sendPort.send(const LlmIdle());

    _LlmBlocIsolate(
      model: model,
      receivePort: receivePort,
      sendPort: sendPort,
    );
  }
}

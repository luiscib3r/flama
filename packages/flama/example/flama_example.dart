import 'dart:io';

import 'package:flama/flama.dart';

Future<void> main(List<String> args) async {
  // Download your model from Hugging Face
  // Example:
  // huggingface-cli download stabilityai/stablelm-2-zephyr-1_6b stablelm-2-zephyr-1_6b-Q4_0.gguf --local-dir .
  final llama = await LlamaLocal.create(
    libraryPath: 'libllama.dylib',
    modelPath: 'stablelm-2-zephyr-1_6b-Q4_0.gguf',
  );

  const prompt = 'How to build a ML systems?';

  final tokenStream = llama(prompt);

  await for (final token in tokenStream) {
    stdout.write(token);
  }
  stdout.writeln();
  await stdout.flush(); 
  await llama.dispose();
}

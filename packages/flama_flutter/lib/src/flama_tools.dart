import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'ggml_metal.dart';

/// FlamaTools
abstract class FlamaTools {
  /// Load a model from assets.
  /// Copy the model from assets to the application documents directory
  /// and return the file path. If the file already exists, it will not be
  /// copied again.
  static Future<String> modelFromAsset(String assetPath) async {
    await _initMetal();
    final workDirectory = await getApplicationDocumentsDirectory();

    // Model directory
    final modelDirectory = Directory(path.join(workDirectory.path, 'model'));
    if (!modelDirectory.existsSync()) {
      modelDirectory.createSync();
    }

    // Check if file exists
    final filePath = path.join(workDirectory.path, assetPath);
    final file = File(filePath);

    if (!file.existsSync()) {
      // Copy file from assets
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
    }

    return filePath;
  }
}

Future<void> _initMetal() async {
  if (Platform.isMacOS) {
    final workDirectory = await getApplicationDocumentsDirectory();
    final metalDirectory = Directory(path.join(workDirectory.path, '..'));

    final filePath = path.join(metalDirectory.path, 'ggml-metal.metal');
    final file = File(filePath);

    await file.writeAsString(_ggmlMetal);
  }
}

import 'dart:ffi';

/// Abi extension to get dynamic library name.
extension AbiX on Abi {
  /// Get dynamic library name.
  String get library {
    switch (Abi.current()) {
      case Abi.macosArm64:
      case Abi.macosX64:
        return 'libllama.dylib';
      default:
        throw UnsupportedError('Unsupported platform ${Abi.current()}');
    }
  }
}

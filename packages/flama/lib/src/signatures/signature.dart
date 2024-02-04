import 'package:equatable/equatable.dart';
import 'package:flama/src/flama.dart';

/// {@template signature}
/// Signature.
/// {@endtemplate}
class Signature extends Equatable {
  /// {@macro signature}
  factory Signature({
    required String signature,
    String? instructions,
  }) {
    final signatureSplit = signature.split('->');
    final inputStr = signatureSplit[0];
    final outputStr = signatureSplit[1];

    final fields = <String, Field>{};

    for (final name in inputStr.split(',')) {
      fields.addField(name.trim(), InputField);
    }

    for (final name in outputStr.split(',')) {
      fields.addField(name.trim(), OutputField);
    }

    return Signature._(
      signature: signature,
      instructions: instructions ?? '',
      fields: fields,
    );
  }

  /// {@macro signature}
  const Signature._({
    required this.signature,
    required this.instructions,
    required this.fields,
  });

  /// Signature.
  final String signature;

  /// Instructions.
  final String instructions;

  /// Fields.
  final Map<String, Field> fields;

  /// Input fields.
  Map<String, InputField> get inputFields => Map.fromEntries(
        fields.entries
            .where((e) => e.value is InputField)
            .map((e) => MapEntry(e.key, e.value as InputField)),
      );

  /// Output fields.
  Map<String, OutputField> get outputFields => Map.fromEntries(
        fields.entries
            .where((e) => e.value is OutputField)
            .map((e) => MapEntry(e.key, e.value as OutputField)),
      );

  @override
  String toString() =>
      'Signature(signature=$signature, instructions=$instructions)';

  @override
  List<Object?> get props => [
        signature,
        instructions,
        fields,
      ];
}

extension _FieldsX on Map<String, Field> {
  void addField(String name, Type type) {
    if (containsKey(name)) {
      throw ArgumentError(
        'Field with name $name already exists in signature',
      );
    }

    if (type == InputField) {
      this[name] = InputField(name: name, desc: '\${$name}');
    } else {
      this[name] = OutputField(name: name, desc: '\${$name}');
    }
  }
}

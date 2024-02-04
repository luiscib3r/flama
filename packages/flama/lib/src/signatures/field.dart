import 'package:equatable/equatable.dart';

/// {@template field}
/// Field.
/// {@endtemplate}
sealed class Field extends Equatable {
  /// {@macro field}
  const Field({
    required this.name,
    required this.desc,
  });

  /// Field name.
  final String name;

  /// Field description.
  final String desc;

  /// Field prefix.
  String get prefix => '$name:';

  @override
  List<Object?> get props => [name, desc];

  @override
  String toString() => '$runtimeType(name=$name, desc=$desc)';
}

/// {@template input_field}
/// Input field.
/// {@endtemplate}
class InputField extends Field {
  /// {@macro input_field}
  const InputField({
    required super.name,
    required super.desc,
  });
}

/// {@template output_field}
/// Output field.
/// {@endtemplate}
class OutputField extends Field {
  /// {@macro output_field}
  const OutputField({
    required super.name,
    required super.desc,
  });
}

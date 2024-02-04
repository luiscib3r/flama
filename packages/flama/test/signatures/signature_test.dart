import 'package:flama/flama.dart';
import 'package:test/test.dart';

void main() {
  group('Signature', () {
    final signature = Signature(
      signature: 'name,age->id',
      instructions: 'Create a user.',
    );

    test('signature', () {
      expect(signature.signature, 'name,age->id');
    });

    test('instructions', () {
      expect(signature.instructions, 'Create a user.');
    });

    test('fields', () {
      expect(signature.fields, {
        'name': const InputField(name: 'name', desc: r'${name}'),
        'age': const InputField(name: 'age', desc: r'${age}'),
        'id': const OutputField(name: 'id', desc: r'${id}'),
      });
    });

    test('inputFields', () {
      expect(signature.inputFields, {
        'name': const InputField(name: 'name', desc: r'${name}'),
        'age': const InputField(name: 'age', desc: r'${age}'),
      });
    });

    test('outputFields', () {
      expect(signature.outputFields, {
        'id': const OutputField(name: 'id', desc: r'${id}'),
      });
    });

    test('String', () {
      expect(
        signature.toString(),
        'Signature(signature=name,age->id, instructions=Create a user.)',
      );
    });
  });
}

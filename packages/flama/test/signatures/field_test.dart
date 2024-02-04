import 'package:flama/flama.dart';
import 'package:test/test.dart';

void main() {
  group('Field', () {
    const field = InputField(
      name: 'name',
      desc: r'${name}',
    );

    test('name', () {
      expect(field.name, 'name');
    });

    test('desc', () {
      expect(field.desc, r'${name}');
    });

    test('prefix', () {
      expect(field.prefix, 'name:');
    });

    test('props', () {
      expect(field.props, ['name', r'${name}']);
    });

    test('String', () {
      expect(
        field.toString(),
        "InputField(name=name, desc=${r'${name}'})",
      );
    });
  });
}

import 'package:flama_flutter/flama_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flama Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          primary: Colors.orangeAccent,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider<LlmBloc>(
        create: (_) => LlamaLocalBloc(),
        child: const MyHomePage(title: 'Flama Example'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final bloc = context.read<LlmBloc>();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runModel();
  }

  Future<void> _runModel() async {
    final modelPath = await FlamaTools.modelFromAsset(
      'model/stablelm-2-zephyr-1_6b-Q4_1.gguf',
    );

    await bloc.run(LlamaLocalParams(model: modelPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<LlmBloc, LlmState>(
            builder: (context, state) => state.map<Widget>(
              loading: (_) => const Center(child: CircularProgressIndicator()),
              idle: (_) => Column(
                children: [
                  const Expanded(child: Center(child: Text('Idle'))),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Input',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (input) {
                      bloc.generate(input);
                      controller.clear();
                    },
                  ),
                ],
              ),
              generating: (state) => Column(
                children: [
                  const LinearProgressIndicator(),
                  SingleChildScrollView(
                    reverse: true,
                    child: Text(state.text),
                  ),
                ],
              ),
              done: (state) => Column(
                children: [
                  SingleChildScrollView(
                    reverse: true,
                    child: Text(state.text),
                  ),
                  const Spacer(),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Input',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (input) {
                      bloc.generate(input);
                      controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

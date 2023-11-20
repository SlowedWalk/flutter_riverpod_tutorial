import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() => runApp(const ProviderScope(child: App()));

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

const names = [
  'Alices',
  'Bob',
  'Charlie',
  'David',
  'Eve',
  'Fred',
  'Ginny',
  'Harriet',
  'Ileana',
  'Joseph',
  'Kincaid',
  'Larry',
];

final tickerProvider = StreamProvider((ref) => Stream.periodic(
      const Duration(seconds: 1),
      (i) => i + 1,
    ));

final namesProvider = StreamProvider((ref) => ref
    .watch(tickerProvider.future)
    .asStream()
    .map((count) => names.getRange(0, count)));

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode'),
        centerTitle: true,
      ),
      body: names.when(
        data: (nqmes) {
          return ListView.builder(
            itemCount: names.asData!.value.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(names.asData!.value.elementAt(index)),
              );
            });
          },
        error: (error, stackTrace) =>
            const Center(child: Text('Reached the end of the list')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

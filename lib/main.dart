import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() => runApp(
  const ProviderScope(
    child: App()
  )
);

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

enum City {
  cameroon,
  nigeria,
  tokyo,
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) async {
  await Future.delayed(const Duration(seconds: 1));
  switch (city) {
    case City.cameroon:
      return '🌤';
    case City.nigeria:
      return '🌧';
    case City.tokyo:
      return '🌩';
    default:
      return '🔥';
  }
}

// ui writes and read from this provider
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

const unknownWeatherEmoji = '🤷';

// will be read by the ui
final weatherProvider = FutureProvider<WeatherEmoji>((ref) async {
  final city = ref.watch(currentCityProvider);
  if (city == null) {
    return unknownWeatherEmoji;
  } else {
    return getWeather(city);
  }
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        currentWeather.when(
          data: (data) => Text(data, style: const TextStyle(fontSize: 40),),
          error: (error, stackTrace) => Text('Error: $error'),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator()
            )
),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                  onTap: () =>
                    ref.read(currentCityProvider.notifier)
                      .state = city,
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
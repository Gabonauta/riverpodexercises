import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: const HomePage(),
    );
  }
}

enum City {
  stockholm,
  paris,
  tokyo,
  newyork,
}

typedef WeatherEmoji = String;
const value = '🌧';
const unknownWeatherEmoji = '🙄';
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.stockholm: '❄',
      City.paris: '☀',
      City.tokyo: '🌨',
    }[city]!,
  );
}

//IU writes to an reads from this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
//final myProvider = Provider((_) => DateTime.now());

//UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return unknownWeatherEmoji;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currrentWather = ref.watch(
      weatherProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Weather")),
      body: Column(
        children: [
          currrentWather.when(
              data: (data) => Text(
                    data,
                    style: const TextStyle(fontSize: 40),
                  ),
              error: (_, __) => const Text('Error 😋'),
              loading: () => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),
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
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => ref
                    .read(
                      currentCityProvider.notifier,
                    )
                    .state = city,
              );
            },
          ))
        ],
      ),
    );
  }
}

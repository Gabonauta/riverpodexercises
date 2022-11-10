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

//creating a class of films
@immutable
class Film {
  final String id, title, description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        description: description,
        isFavorite: isFavorite,
      );
  @override
  String toString() =>
      //crear un inline visualmente más limpio
      // Antes: 'Film(id: $id,title:$title,description:$description,isFavorite:$isFavorite)';
      //despues:
      'Film(id: $id,'
      'title:$title,'
      'description:$description,'
      'isFavorite:$isFavorite)';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          isFavorite,
        ],
      );
}

const allFilms = [
  Film(
    id: '1',
    title: 'THe sahwshank redemption',
    description: 'This is the description for The SawShank redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    description: "Description for the Godfather",
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather Part II',
    description: 'Description for the Godfather II',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    description: 'Description for the Dark Night',
    isFavorite: false,
  )
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);
  void update(Film film, bool isFavorite) {
    state = state
        .map((e) => e.id == film.id ? e.copy(isFavorite: isFavorite) : e)
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (_) => FavoriteStatus.all,
);
// all films
final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (_) => FilmsNotifier(),
);
//favorite films

final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where(
        (element) => element.isFavorite,
      ),
);
final notfavoriteFilmsProvider = Provider(
  (ref) => ref.watch(allFilmsProvider).where(
        (element) => !element.isFavorite,
      ),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(title: const Text("Favorite Films")),
        body: Column(
          children: [
            const FilterWidget(),
            Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(favoriteStatusProvider);
                switch (filter) {
                  case FavoriteStatus.all:
                    return FilmsList(
                      provider: allFilmsProvider,
                    );

                  case FavoriteStatus.favorite:
                    return FilmsList(
                      provider: favoriteFilmsProvider,
                    );

                  case FavoriteStatus.notFavorite:
                    return FilmsList(
                      provider: notfavoriteFilmsProvider,
                    );
                }
              },
            )
          ],
        )
        // body: names.when(data: data, error: error, loading: loading),
        );
  }
}

class FilmsList extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsList({required this.provider, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
                onPressed: () {
                  final isFavorite = !film.isFavorite;
                  ref.read(allFilmsProvider.notifier).update(
                        film,
                        isFavorite,
                      );
                },
                icon: favoriteIcon),
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          items: FavoriteStatus.values
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e.toString().split('.').last)))
              .toList(),
          onChanged: (FavoriteStatus? value) {
            // final foo = ref.read(
            //   favoriteStatusProvider.state,
            // );
            ref
                .read(
                  favoriteStatusProvider.state,
                )
                .state = value!;
          },
          value: ref.watch(favoriteStatusProvider),
        );
      },
    );
  }
}

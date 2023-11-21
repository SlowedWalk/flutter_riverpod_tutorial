import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() => runApp(const ProviderScope(child: App()));

@immutable
class Film {
  final String id;
  final String title;
  final String director;
  final String releaseDate;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.director,
    required this.releaseDate,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        director: director,
        releaseDate: releaseDate,
        isFavorite: isFavorite,
      );

  @override
  String toString() => 'Film('
      'id: $id, '
      'title: $title, '
      'director: $director, '
      'releaseDate: $releaseDate, '
      'isFavorite: $isFavorite)';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    director: "Frank Darabont",
    releaseDate: "Sep 1994",
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    director: 'Francis Ford Coppola',
    releaseDate: "March 1972,",
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather: Part II',
    director: 'Francis Ford Coppola',
    releaseDate: "Dec 1974",
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    director: 'Christopher Nolan',
    releaseDate: "July 2008",
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map((element) =>
            element.id == film.id ? film.copy(isFavorite: isFavorite) : element)
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (_) => FavoriteStatus.all,
);

// all  films
final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (_) => FilmsNotifier(),
);

// favorite films
final favoriteFilmsProvider = Provider<Iterable<Film>>(
        (ref) => ref.watch(allFilmsProvider)
            .where(
                (film) => film.isFavorite
        )
);

// not favorite films
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
        (ref) => ref.watch(allFilmsProvider)
            .where(
                (film) => !film.isFavorite
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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(favoriteStatusProvider);
                switch (filter) {
                  case FavoriteStatus.all:
                    return FilmsWidget(provider: allFilmsProvider);
                  case FavoriteStatus.favorite:
                    return FilmsWidget(provider: favoriteFilmsProvider);
                  case FavoriteStatus.notFavorite:
                    return FilmsWidget(provider: notFavoriteFilmsProvider);
                }
              }
          )
        ],
      )
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;

  const FilmsWidget({required this.provider, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films.elementAt(index);
            final favoriteIcon = film.isFavorite
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border);
            return ListTile(
              title: Text(film.title),
              subtitle: Row(
                children: [
                  Text(film.director),
                  Text(' ${film.releaseDate}'),
                ],
              ),
              trailing: IconButton(
                icon: favoriteIcon,
                onPressed: () {
                  ref.read(allFilmsProvider.notifier).update(film, !film.isFavorite);
                },
              ),
            );
          }
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
          final favoriteStatus = ref.watch(favoriteStatusProvider);
          return DropdownButton(
            value: favoriteStatus,
              items: FavoriteStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                ref.read(favoriteStatusProvider.notifier).state = value!;
              }
          );
        }
    );
  }
}


import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
    current= WordPair.random();
    notifyListeners();
  }

  var favorites= <WordPair>[];

  void updateFavorites(WordPair word){
    if(favorites.contains(word)){
      favorites.remove(word);
    }else{
      favorites.add(word);
    }

    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex=0;
  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex){
      case 0:
        page = HomeComponent();
      case 1:
        page= FavoritePage();
      default:
        throw UnimplementedError("No Widget for $selectedIndex");
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text("Home")),
                NavigationRailDestination(icon: Icon(Icons.favorite), label: Text("Favorites")),
              ],
              onDestinationSelected: (selectedDestination){
                print(selectedDestination);
                setState(() {
                  selectedIndex = selectedDestination;
                });
              }, 
              selectedIndex: selectedIndex,
              extended: true,
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of( context).colorScheme.primaryContainer,
              child: page,
            ),
          )
        ],
      )
    );
  }
}

class HomeComponent extends StatelessWidget {
  const HomeComponent({super.key,});

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var favorites = appState.favorites;

    return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
    // Text('A random idea:'),
    BigNameCard(pair: pair),
    SizedBox(height: 10,),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // print('button pressed!');
            appState.updateFavorites(pair);
          },

          icon: Icon(favorites.contains(pair)?Icons.favorite: Icons.favorite_border),
          label: Text('Like'),
        ),
        SizedBox(width: 10,),
        ElevatedButton(
          onPressed: () {
            // print('button pressed!');
            appState.getNext();
          },
          child: Text('Next'),
        ),
      ],
    ),
            
              ],
            ),
          );
  }
}

class BigNameCard extends StatelessWidget {
  const BigNameCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.all(10),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritePage extends StatefulWidget{
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  var displayDelete = false;
  var selectedFavorite="";
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primary,
    );

    if(favorites.isEmpty){
      return Center(
        child: Text("No Favorites added yet!!!"),
      );
    }
    // return ListView(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.all(10),
    //       child: Text("You have ${favorites.length} favorite words saved:"),
    //     ),
    //     // favorites.map((favorite)=>Text(favorite.toString())),
    //     for(var favorite in favorites)
    //       InkWell(
    //         onTap:(){
    //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //             content: Text('Tap'),
    //           ));
    //         },
    //         child:ListTile(
    //           leading: Icon(Icons.favorite),
    //           title: Text(favorite.asPascalCase),
    //         ),
    //       ),
          // ListTile(
          //   leading: Icon(Icons.favorite),
          //   title: Text(favorite.asPascalCase),
          // ),
    //   ],
    // );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center ,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
              padding: const EdgeInsets.all(10),
              child: Text("You have ${favorites.length} favorite words saved:"),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: favorites.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context,index){
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  
                  onTap: (){
                      setState(() {
                        displayDelete = !displayDelete;
                        selectedFavorite = favorites[index].toString();
                      });
                  },
                  child: Card(
                    // margin: const EdgeInsets.all(10),
                    child:  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          favorites[index].asPascalCase,
                          style: style,
                          semanticsLabel: favorites[index].asPascalCase,
                        ),
                    ),
                  ),
                ),
                if(displayDelete && selectedFavorite == favorites[index].toString()) 
                  ElevatedButton(
                    
                    onPressed: (){
                      appState.updateFavorites(favorites[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0),
                      child: Icon(Icons.delete_forever),
                    ),
                    // label: Text("Delete"),
                  )
              ],
            );
        }),
      ],
    );
  }
}

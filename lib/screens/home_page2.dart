import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myrecipe/models/recipe_model.dart';
import 'dart:convert';
import 'package:myrecipe/widgets/food_cards.dart';
import 'favorites_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myrecipe/services/firestore_services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

List<dynamic> _recipes;
bool _isLoading = false;

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();
  String _queryText = '';
  final firestoreService = FirestoreService();

  addStringToSF(String txt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('stringValue', txt);
  }

  Future<dynamic> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _queryText = prefs.getString('stringValue') ?? '';
    });

    var response = await http.get(
        "https://api.spoonacular.com/recipes/search?query=$_queryText&number=20&diet=&apiKey=875531d336964b5ca5652dbab8d7c903");
    if (response.statusCode == 200) {
      _recipes = jsonDecode(response.body)['results']
          .map((data) => RecipeModel.fromJson(data))
          .toList();
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _isLoading == false
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('images/kitchen.jpg'),
                  fit: BoxFit.cover,
                )),
                child: Container(
                  color: Colors.white.withOpacity(.2),
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  ),
                ),
              )
            : CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    brightness: Brightness.light,
                    backgroundColor: Colors.white,
                    expandedHeight: 270.0,
                    elevation: 0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      titlePadding: EdgeInsets.only(
                        top: 30,
                        bottom: 10,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(248, 248, 247, 1),
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: TextField(
                                  controller: _textController,
                                  onSubmitted: (value) {
                                    if (value == '') {
                                      FocusScope.of(context).unfocus();
                                    } else {
                                      setState(() {
                                        _queryText = value;
                                      });
                                      addStringToSF(value);
                                      _textController.clear();
                                      getData();
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search recipes',
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(188, 188, 187, 1),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      background: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).padding.top + 10,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'My',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Josefin',
                                fontSize: 20,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Recipe',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              'Find',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              'Recipes',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return FoodCards(
                            sourceUrl: _recipes[index].sourceUrl,
                            image:
                                'https://spoonacular.com/recipeImages/${_recipes[index].image}',
                            title: _recipes[index].title,
                            servings:
                                "${_recipes[index].servings.toString()} servings",
                            readyInMinutes:
                                "Ready in ${_recipes[index].readyInMinutes.toString()} minutes",
                            icon: Icon(Icons.add_photo_alternate),
                            saveFunc: () {
                              var newRecipe = RecipeModel(
                                image:
                                    'https://spoonacular.com/recipeImages/${_recipes[index].image}',
                                id: _recipes[index].id,
                                title: _recipes[index].title,
                                sourceUrl: _recipes[index].sourceUrl,
                                servings: _recipes[index].servings,
                                readyInMinutes: _recipes[index].readyInMinutes,
                              );
                              firestoreService.saveProduct(newRecipe);
                            },
                          );
                        },
                        childCount: _recipes.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isLoading == false
          ? Container(
              color: Colors.transparent, // This is optional
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesPage(),
                  ),
                );
              },
              child: Icon(Icons.collections),
              backgroundColor: Colors.grey,
            ),
    );
  }
}

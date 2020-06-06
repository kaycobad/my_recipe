import 'package:flutter/material.dart';
import 'package:myrecipe/widgets/food_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Favorites'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('recipeModels').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading..");
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: ListView.builder(
              itemBuilder: (context, index) {
                final recipeModels = snapshot.data.documents[index];
                return FoodCards(
                  sourceUrl: recipeModels.data['sourceUrl'],
                  image: recipeModels.data['image'],
                  title: recipeModels.data['title'],
                  servings:
                      "${recipeModels.data['servings'].toString()} servings",
                  readyInMinutes:
                      "Ready in ${recipeModels.data['readyInMinutes'].toString()} minutes",
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  saveFunc: () {
                    Firestore.instance
                        .collection('recipeModels')
                        .document(recipeModels.data['id'].toString())
                        .delete();
                  },
                );
              },
              itemCount: snapshot.data.documents.length,
            ),
          );
        },
      ),
    );
  }
}

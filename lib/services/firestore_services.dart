import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myrecipe/models/recipe_model.dart';

class FirestoreService {
  Firestore _db = Firestore.instance;

  Future<void> saveProduct(RecipeModel recipeModel) {
    return _db
        .collection('recipeModels')
        .document(recipeModel.id.toString())
        .setData(recipeModel.toMap());
  }
}

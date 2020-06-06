class RecipeModel {
  final String image;
  final String sourceUrl;
  final String title;
  final int readyInMinutes;
  final int id;
  final int servings;

  RecipeModel(
      {this.image,
      this.title,
      this.sourceUrl,
      this.id,
      this.readyInMinutes,
      this.servings});

  factory RecipeModel.fromJson(Map<String, dynamic> parsedJson) {
    return RecipeModel(
      image: parsedJson["image"],
      sourceUrl: parsedJson["sourceUrl"],
      title: parsedJson["title"],
      id: parsedJson["id"],
      readyInMinutes: parsedJson["readyInMinutes"],
      servings: parsedJson["servings"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'servings': servings,
      'readyInMinutes': readyInMinutes,
      'sourceUrl': sourceUrl,
    };
  }

  RecipeModel.fromFirestore(Map<String, dynamic> firestore)
      : id = firestore['id'],
        image = firestore['image'],
        title = firestore['price'],
        servings = firestore['servings'],
        readyInMinutes = firestore['readyInMinutes'],
        sourceUrl = firestore['sourceUrl'];
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/providers/recipe_provider.dart';
import 'package:recipe_book/ui/screens/show_recipe_screen.dart';
import '../../models/recipe_model.dart';

class RecipeWidget extends StatelessWidget {
  final RecipeModel recipeModel;
  const RecipeWidget(this.recipeModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) =>
                    ShowRecipeScreen(recipeModel: recipeModel))));
      }),
      child: Container(
        decoration: BoxDecoration(
            color: !Provider.of<RecipeClass>(context).isDark
                ? Colors.pink[100]
                : null,
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: ListTile(
          tileColor: !Provider.of<RecipeClass>(context).isDark
              ? Colors.pink[100]
              : null,
          leading: recipeModel.image == null || recipeModel.image!.path.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                      color: !Provider.of<RecipeClass>(context).isDark
                          ? Colors.pink
                          : null,
                      borderRadius: BorderRadius.circular(8)),
                  height: double.infinity,
                  width: 70,
                  child: const Center(
                      child: CircleAvatar(
                    backgroundImage: AssetImage('images/food_logo.png'),
                  )))
              : Image.file(
                  recipeModel.image!,
                  width: 70,
                  height: double.infinity,
                ),
          title: Text(recipeModel.name),
          subtitle: Text('${recipeModel.preperationTime} mins'),
          trailing: InkWell(
            onTap: () {
              Provider.of<RecipeClass>(context, listen: false)
                  .updateIsFavorite(recipeModel);
            },
            child: recipeModel.isFavorite
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FridgeX/models/recipe_model.dart';
import 'package:FridgeX/providers/recipe_provider.dart';
import 'edit_recipe_screen.dart';

class ShowRecipeScreen extends StatelessWidget {
  final RecipeModel recipeModel;
  const ShowRecipeScreen({super.key, required this.recipeModel});

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF90BFA9); // Muted teal
    final isDark = Provider.of<RecipeClass>(context).isDark;

    return Consumer<RecipeClass>(
        builder: ((context, provider, child) => Scaffold(
              appBar: AppBar(
                actions: [
                  InkWell(
                    onTap: () {
                      provider.nameController.text = recipeModel.name;
                      provider.preperationTimeController.text =
                          recipeModel.preperationTime.toString();
                      provider.ingredientsController.text =
                          recipeModel.ingredients;
                      provider.instructionsController.text =
                          recipeModel.instructions;
                      provider.image = recipeModel.image;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) =>
                              EditRecipeScreen(recipeModel: recipeModel)),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      provider.deleteRecipe(recipeModel);
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.delete),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: !isDark ? greenColor : null,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: recipeModel.image == null ||
                              recipeModel.image!.path.isEmpty
                          ? const Center(
                              child: CircleAvatar(
                                backgroundColor: Color(0xFF90BFA9),
                                radius: 100,
                                backgroundImage: AssetImage('images/logo.png'),
                              ),
                            )
                          : Image.file(
                              recipeModel.image!,
                              fit: BoxFit.cover,
                              height: 170,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      recipeModel.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: !isDark ? greenColor.withOpacity(0.6) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Preperation time :',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${recipeModel.preperationTime} mins',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: !isDark ? greenColor.withOpacity(0.6) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredients',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          recipeModel.ingredients,
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: !isDark ? greenColor.withOpacity(0.6) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instructions',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          recipeModel.instructions,
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ]),
              ),
            )));
  }
}

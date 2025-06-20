import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FridgeX/ui/screens/search_recipe_screen.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';
import '../../providers/recipe_provider.dart';
import '../widgets/recipe_widget.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeClass>(
      builder: (BuildContext context, myProvider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorite Recipes'),
            actions: [
              InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => SearchRecipeScreen(
                          recipes: myProvider.favoriteRecipes)))),
                  child: const Icon(Icons.search)),
              PopupMenuButton(
                color: !myProvider.isDark ? Colors.pink[200] : null,
                itemBuilder: ((context) => [
                      PopupMenuItem(
                        onTap: (() => Scaffold.of(context).openDrawer()),
                        child: const Text('Open menu'),
                      ),
                      const PopupMenuItem(
                        child: Text('About'),
                      ),
                      PopupMenuItem(
                        onTap: (() => exit(0)),
                        child: Column(
                          children: [
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.exit_to_app_outlined,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Exit'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ],
          ),
          drawer: AppDrawer(),
          body: ListView.builder(
              itemCount: myProvider.favoriteRecipes.length,
              itemBuilder: (context, index) {
                return RecipeWidget(myProvider.favoriteRecipes[index]);
              }),
        );
      },
    );
  }
}

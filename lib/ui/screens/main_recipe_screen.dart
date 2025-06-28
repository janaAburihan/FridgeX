import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FridgeX/providers/recipe_provider.dart';
import 'package:FridgeX/ui/screens/search_recipe_screen.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';
import '../widgets/recipe_widget.dart';

class MainRecipeScreen extends StatelessWidget {
  const MainRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeClass>(
        builder: (BuildContext context, myProvider, Widget? child) => Scaffold(
              appBar: AppBar(
                title: const Text('My Recipes'),
                actions: [
                  InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) => SearchRecipeScreen(
                              recipes: myProvider.allRecipes)))),
                      child: const Icon(Icons.search)),
                  PopupMenuButton(
                    color: !myProvider.isDark ? Color(0xFFC2DCD0) : null,
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
              floatingActionButton: FloatingActionButton(
                onPressed: (() async {
                  await Navigator.pushNamed(context, '/new_recipe_screen');
                }),
                child: const Icon(Icons.add),
              ),
              drawer: AppDrawer(),
              body: ListView.builder(
                  itemCount: myProvider.allRecipes.length,
                  itemBuilder: (context, index) {
                    return RecipeWidget(myProvider.allRecipes[index]);
                  }),
            ));
  }
}

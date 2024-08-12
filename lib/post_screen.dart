import 'package:flutter/material.dart';
import 'package:project/screens/post_bottom_bar.dart';

class PostScreen extends StatelessWidget {
  final String cityName;
  final String description;
  final String imagePath;

  PostScreen(
      {required this.cityName,
      required this.description,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                imagePath,
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: PostBottomBar(
                  //cityName: cityName,
                 // description: description,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

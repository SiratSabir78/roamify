import 'package:flutter/material.dart';

class PostBottomBar extends StatelessWidget {
  final String cityName;

  final String description;

  PostBottomBar({
    required this.cityName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;

    return Container(
      height: MediaQuery.of(context).size.height / 2, // Adjusted height
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[900]
            : const Color(0xFFED2F6), // Adjusted color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20), // Added bottom padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$cityName, Pakistan",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  description,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black54 : Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'Some Info', // Placeholder text
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            
                          ),
                        ),
                      ),
                      // Add other widgets here if needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class user_scettings extends StatefulWidget {
  const user_scettings({super.key});

  @override
  State<user_scettings> createState() => _user_scettingsState();
}

class _user_scettingsState extends State<user_scettings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

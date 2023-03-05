import 'package:flutter/material.dart';
import 'main_page.dart';

void main() {
  runApp(datathon_ml());
}

class datathon_ml extends StatefulWidget {
  const datathon_ml({Key? key}) : super(key: key);

  @override
  State<datathon_ml> createState() => _datathon_mlState();
}

class _datathon_mlState extends State<datathon_ml> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'home',
      routes: {'home': (context) => MainPage()},
    );
  }
}

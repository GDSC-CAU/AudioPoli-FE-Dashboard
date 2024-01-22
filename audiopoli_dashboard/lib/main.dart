import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './mapContainer.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: styledContainer()
                        ),
                        Expanded(
                          child: styledContainer(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: mapContainer(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: styledContainer(),
            ),
          ],
        ),
      ),
    );
  }
}

class styledContainer extends StatelessWidget {
  styledContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

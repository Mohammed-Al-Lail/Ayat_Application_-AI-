import 'package:flutter/material.dart';
import 'package:myapp/quran_aya_page.dart';

void main() {
  runApp(const MyApp());
}
//just app widget and call the main page
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Quranic Aya',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      //   useMaterial3: true,
      // ),
      debugShowCheckedModeBanner: false,
      home: const QuranAyaPage(),
    );

  }
}

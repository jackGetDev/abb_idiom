import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'idiom_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ABBProvider>(create: (_) => ABBProvider()),
      ],
      child: MaterialApp(
        title: 'IDIOM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark, // Set tema menjadi dark
          scaffoldBackgroundColor: Colors.black, // Set latar belakang menjadi hitam
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.grey), // Set warna teks menjadi abu-abu
          ),
        ),
        home: IdiomPage(),
      ),
    ),
  );
}

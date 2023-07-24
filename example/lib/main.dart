import 'package:flutter/material.dart';
import 'package:flutter_autolink_text/flutter_autolink_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_autolink_text example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'flutter_autolink_text example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey<ScaffoldState> scaffold = new GlobalKey();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: AutolinkText(
            text: 'Your text with link www.example.com',
            textStyle: TextStyle(color: Colors.black),
            linkStyle: TextStyle(color: Colors.blue),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

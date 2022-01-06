import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: Login(),
  ));
}
// void main() => runApp(const Login());

String email = "psr007700@students.ephec.be";
String password = "";
TextEditingController emailController = new TextEditingController(text: email);
TextEditingController passwordController = new TextEditingController();
String url = "https://localhost:44396";
Map<String, String> header = new Map<String, String>();

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          TextField(
            controller: emailController,
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
          ),
          ElevatedButton(
            child: const Text('Login'),
            onPressed: () {
              email = emailController.text;
              password = passwordController.text;
              header['Authorization'] = email + ":" + password;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          )
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  VotePage createState() => VotePage();
}

class VotePage extends State<MyApp> {
  List<dynamic> articles = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var response = await http.get(url + '/article/user', headers: header);
    try {
      if (response.statusCode == 200) {
        articles = jsonDecode(response.body);
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Second Route"),
        ),
        body: Flex(direction: Axis.vertical, children: <Widget>[
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Number'),
              ),
            ],
            rows: List<DataRow>.generate(
              articles,
              (dynamic index) => DataRow(
                cells: <DataCell>[DataCell(Text('Row gh'))],
              ),
            ),
          ),
        ]));
  }
}

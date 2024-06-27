import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'article.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: Login(),
  ));
}
// void main() => runApp(const Login());

String emailTemp = "newbreaker@gmail.com";
String passwordTemp = "pss";
TextEditingController emailController = new TextEditingController(text: emailTemp);
TextEditingController passwordController = new TextEditingController(text: passwordTemp);
String url = "https://localhost:44396";
Map<String, String> header = new Map<String, String>();

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
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
              authenticate(context, emailController.text, passwordController.text);
            },
          )
        ],
      ),
    );
  }
}

Future<void> authenticate(BuildContext context, String email, String password) async {
  Map<String, String> headerTemp = new Map<String, String>();
  headerTemp['Authorization'] = email + ":" + password;
  var response = await http.get(url + '/users/login', headers: headerTemp);

  try {
    if (response.statusCode == 200) {
      header['Authorization'] = email + ":" + password;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } else {
      showErrorDialog(context, jsonDecode(response.body)['data'].toString());
    }
  } catch (e) {}
}

showErrorDialog(BuildContext context, String message) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("OK"),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Something went wrong"),
    content: Text(message),
    actions: [
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
        automaticallyImplyLeading: false,
      ),
      body: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: const <Widget>[
          Center(
              child: Text("You voted successfully", textAlign: TextAlign.center)
          )
        ],
      ),
    );
  }
}
class NotSessionsPage extends StatelessWidget {
  const NotSessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Voting Session Available'),
        automaticallyImplyLeading: false,
      ),
      body: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: const <Widget>[
          Center(
              child: Text("No voting session available", textAlign: TextAlign.center)
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
  Article article = new Article();

  List<SubArticle> subArticles = [];
  String counter = "0 Voted";

  bool hidden = true;

  @override
  void initState() {
    super.initState();
    getData();
  }


  Future<void> vote(int id, int type) async {
    var response = await http.get(url + '/vote/subarticle/'+id.toString()+'/vote/'+type.toString(), headers: header);

    try {
      if (response.statusCode == 200) {
        getData();
      }
    } catch (e) {}
  }

  Future<void> voteSubmit(int articleId) async {
    var response = await http.get(url + '/vote/article/'+articleId.toString()+'/vote/submit', headers: header);

    try {
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      }
    } catch (e) {}
  }

  Future<void> getData() async {
    var response = await http.get(url + '/article/user', headers: header);

    try {
      if (response.statusCode == 200) {
        var articles = (jsonDecode(response.body)['data'] as List)
            .map((item) => Article.fromJson(item));
        article = new Article();
        subArticles = [];
        if (!articles.first.submitted) {
          article = articles.first;
          subArticles = [];
          String counterMax = article.subArticles.length.toString();
          int counterVoted = 0;

          for (SubArticle sa in article.subArticles) {
            if (!hidden || sa.voteType == -1) {
              subArticles.add(sa);
            }
          }
          for (SubArticle sa in article.subArticles) {
            if (sa.voteType >= 0) {
              counterVoted++;
            }
          }
          counter = counterVoted.toString() + ' / ' + counterMax + ' voted';
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotSessionsPage()),
          );
        }

        setState(() {});
      }
    } catch (e) {}
  }

  showVoteDialog(int id, int type) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        vote(id, type);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Confirm"),
      content: Text("Are you sure?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSubmitDialog(int articleId) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        voteSubmit(articleId);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Confirm"),
      content: Text("Are you sure?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Vote page"),
          leading: Image.asset('eplogo.png'),
          automaticallyImplyLeading: false,
        ),
        body: Flex(direction: Axis.vertical, children: <Widget>[
          Text(article.name),
          Text('Hide Voted'),
          Switch(
            value: hidden,
            onChanged: (value) {
                setState(() {hidden = !hidden;getData();});
              },
            ),
          Text(counter),
          DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Name'),
              ),
              DataColumn(
                label: Text('Descr'),
              ),
              DataColumn(
                label: Text('Action'),
              ),
            ],
            rows: List<DataRow>.generate(
              subArticles.length,
              (dynamic index) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(subArticles[index].name ?? "")),
                  DataCell(Text(subArticles[index].description ?? "")),
                  DataCell(
                    Flex(direction: Axis.horizontal, children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            foregroundColor:
                            subArticles[index].voteType == 0 ?
                            MaterialStateProperty.all<Color>(Colors.yellow)
                                : MaterialStateProperty.all<Color>(Colors.black)
                        ),
                        child: const Text('D'),
                        onPressed: () {
                          showVoteDialog(subArticles[index].id, 0);
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                            foregroundColor:
                            subArticles[index].voteType == 1 ?
                            MaterialStateProperty.all<Color>(Colors.yellow)
                                : MaterialStateProperty.all<Color>(Colors.black)
                        ),
                        child: const Text('N'),
                        onPressed: () {
                          showVoteDialog(subArticles[index].id, 1);
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            foregroundColor:
                            subArticles[index].voteType == 2 ?
                            MaterialStateProperty.all<Color>(Colors.yellow)
                                : MaterialStateProperty.all<Color>(Colors.black)
                        ),
                        child: const Text('A'),
                        onPressed: () {
                          showVoteDialog(subArticles[index].id, 2);
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('SUBMIT'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              showSubmitDialog(article.id);
            },
          ),
        ]));
  }
}

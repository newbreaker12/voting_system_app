import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'article.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: Login(),
  ));
}
// void main() => runApp(const Login());

String emailTemp = "newbreaker@gmail.com";
String passwordTemp = "pass";
TextEditingController emailController = new TextEditingController(text: emailTemp);
TextEditingController passwordController = new TextEditingController(text: passwordTemp);
String url = "https://localhost:5001";

// content type json
Map<String, String> header = {
  'content-type': 'application/json',
};


UserData userData = new UserData();

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
  var response = await http.post(Uri.parse(url + '/users/login'),
      headers: header,
      body: json.encode({"email": email, "password": password})
  );

  try {
    if (response.statusCode == 200) {
      var token = jsonDecode(response.body)['token'].toString();
      header['Authorization'] = 'Bearer ' + token;
      // decode jwt
      var jwt = JwtDecoder.decode(token);
      userData.email = jwt['email'];
      userData.firtName = jwt['firstName'];
      userData.lastName = jwt['lastName'];
      userData.role = jwt['role'];


      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageWidget()),
      );
    } else {
      showOkDialog(context, "Something went wrong", jsonDecode(response.body).toString());
    }
  } catch (e) {
    showOkDialog(context, "Something went wrong", e.toString());
  }
}

showOkDialog(BuildContext context, String title, String message) {
  // set up the buttons
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
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
class HomePage extends State<HomePageWidget> {

  @override
  void initState() {
    super.initState();
  }

  requestPinCode() async {
    await http.get(Uri.parse(url + '/users/pincode'), headers: header);
  }

  gotoVotePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VotePageWidget()),
    );
  }

  gotoUserDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserDetailsWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting System'),
        automaticallyImplyLeading: false,
      ),
      body: Flex(direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center( child:
          ElevatedButton(
            child: const Text('Request Pincode'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              requestPinCode();
            },
          )),
          Center( child:
          ElevatedButton(
            child: const Text('User Details'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              gotoUserDetailsPage();
            },
          )),
          Center( child:
          ElevatedButton(
            child: const Text('Vote'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              gotoVotePage();
            },
          )
          )
        ],
      ) ,
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class VotePageWidget extends StatefulWidget {
  const VotePageWidget({Key? key}) : super(key: key);

  @override
  VotePage createState() => VotePage();
}

class UserDetailsWidget extends StatefulWidget {
  const UserDetailsWidget({Key? key}) : super(key: key);

  @override
  UserDetails createState() => UserDetails();
}

class UserDetails extends State<UserDetailsWidget> {

  TextEditingController changePasswordController = new TextEditingController(text: '');
  TextEditingController changePasswordController2 = new TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void changePassword() async {
    if (changePasswordController.text == changePasswordController2.text) {
      var response = await http.put(Uri.parse(url + '/users/changePassword'), headers: header, body: json.encode({"password": changePasswordController.text}));
      if (response.statusCode == 200) {
        showOkDialog(context, "Success", "Password changed successfully");
      } else {
        showOkDialog(context, "Something went wrong", "Something went wrong");
      }
    } else {
      showOkDialog(context, "Something went wrong", "Passwords do not match");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        automaticallyImplyLeading: false,
      ),
      body: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: <Widget>[
          Center(
              child: Text("User Details", textAlign: TextAlign.center)
          ),
          Center(
              child: Text("Name: " + userData.firtName + " " + userData.lastName, textAlign: TextAlign.center)
          ),
          Center(
              child: Text("Email: " + userData.email, textAlign: TextAlign.center)),
          Center(
              child: Text("Role: " + userData.role, textAlign: TextAlign.center)),


          Center(
              child: Text("Password Settings", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),
              )),
          TextField(
            controller: changePasswordController,
            obscureText: true,
          ),
          TextField(
            controller: changePasswordController2,
            obscureText: true,
          ),

          ElevatedButton(
          child: const Text('Change Password'),
          style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
          ),
          onPressed: () {
            changePassword();
          },
          ),

        ],

      ),
    );
  }

  void getUserData() {
    // get user data
    var response = http.get(Uri.parse(url + '/users/user'), headers: header);


  }

}

class VotePage extends State<VotePageWidget> {
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
    var response = await http.get(Uri.parse(url + '/vote/subarticle/'+id.toString()+'/vote/'+type.toString()), headers: header);

    try {
      if (response.statusCode == 200) {
        getData();
      }
    } catch (e) {}
  }

  Future<void> voteSubmit(int articleId) async {
    var response = await http.get(Uri.parse(url + '/vote/article/'+articleId.toString()+'/vote/submit'), headers: header);

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
    var response = await http.get(Uri.parse(url + '/article/user'), headers: header);

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
                  DataCell(Text(subArticles[index].name)),
                  DataCell(Text(subArticles[index].description)),
                  DataCell(
                    Flex(direction: Axis.horizontal, children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                            foregroundColor:
                            subArticles[index].voteType == 0 ?
                            WidgetStateProperty.all<Color>(Colors.yellow)
                                : WidgetStateProperty.all<Color>(Colors.black)
                        ),
                        child: const Text('D'),
                        onPressed: () {
                          showVoteDialog(subArticles[index].id, 0);
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                            foregroundColor:
                            subArticles[index].voteType == 1 ?
                            WidgetStateProperty.all<Color>(Colors.yellow)
                                : WidgetStateProperty.all<Color>(Colors.black)
                        ),
                        child: const Text('N'),
                        onPressed: () {
                          showVoteDialog(subArticles[index].id, 1);
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                            foregroundColor:
                            subArticles[index].voteType == 2 ?
                            WidgetStateProperty.all<Color>(Colors.yellow)
                                : WidgetStateProperty.all<Color>(Colors.black)
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
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              showSubmitDialog(article.id);
            },
          ),
        ]));
  }
}

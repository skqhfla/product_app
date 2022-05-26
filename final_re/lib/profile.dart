import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_re/provider/profileProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LoginProvider.dart';
import 'Storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  bool isTextFild = false;
  final Storage storage = Storage();
  final _message = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future _updateSatus(BuildContext context) async {
    try {
      _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'status_message': _message.text,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider _profileProvider = Provider.of<ProfileProvider>(context);
    LoginProvider _loginProvider = Provider.of<LoginProvider>(context);
    Stream<DocumentSnapshot> _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              semanticLabel: 'logout',
            ),
            onPressed: () {
              _auth.signOut();
              Navigator.popAndPushNamed(context, '/login');
            },
          ),
        ],
      ),
     backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
            stream: _stream,
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              try {
                var data = snapshot.data;
                _message.text = data!["status_message"];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _loginProvider.isGooge ?
                      proPic(data["profileimage"]) : proPic(null),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data["uid"],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              height: 40.0,
                              color: Colors.white,
                            ),
                            _loginProvider.isGooge ?
                            Text(
                              ifEmail(data["email"]),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ) : Text(
                              ifEmail(null),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 60.0),
                            const Text(
                              "BoRim Na",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Provider.of<ProfileProvider>(context).isEdit == true
                                ? Text(data["status_message"],
                                    style: TextStyle(color: Colors.white))
                                :
                            TextField(
                                    controller: _message,
                                    style: TextStyle(color: Colors.white)),
                            _loginProvider.isGooge ? TextButton(
                              onPressed: () {
                                _profileProvider.changeIsEdit();
                                _updateSatus(context);
                              },
                              child:
                                  Provider.of<ProfileProvider>(context).isEdit
                                      ? Text('Edit')
                                      : Text('Save'),
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                return Scaffold();
              }
            }),
      ),
    );
  }

  proPic(String? photoURL) {
    if (photoURL != null) {
      return Image.network(
        photoURL,
        width: 200,
        height: 200,
        fit: BoxFit.fill,
      );
    } else {
      return Image.network(
        "http://handong.edu/site/handong/res/img/logo.png",
        width: 200,
        height: 200,
        fit: BoxFit.fill,
      );
    }
  }

  ifEmail(String? email) {
    if (email != null) {
      return email;
    } else {
      return "Anonymous";
    }
  }

  _fetchData() {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 1));
      return 'REMOTE DATA';
    });
  }

  get_message(String? uid) async {
    await FirebaseFirestore.instance.collection("users").get().then((event) {
      for (var doc in event.docs) {
        if (doc.id == uid) {
          var message = doc.get("status_message") as String;
          print("asfd + " + message);
          return message;
        }
      }
    });

    return "I promise to take the test honestly before GOD.";
  }
}

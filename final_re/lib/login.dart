// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_re/src/authentication.dart';
import 'package:final_re/src/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'LoginProvider.dart';
import 'appstate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // TODO: Add text editing controllers (101)
  @override
  Widget build(BuildContext context) {
    LoginProvider _loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            Column(
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Google'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    primary : Colors.red,
                  ),
                  onPressed: () async {
                    _loginProvider.isLoginType('google');
                    googleSignIn().then((value) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    });
                  },
                ),
                const SizedBox(height: 18.0),
                ElevatedButton(
                  child: const Text('Guest'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    primary : Colors.grey,
                  ),
                  onPressed: () async {
                    _loginProvider.isLoginType('');
                    anonySignIn().then((value) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // TODO: Remove filled: true values (103)
            // TODO: Add TextField widgets (101)
            // TODO: Add button bar (101)
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<UserCredential> googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    setState(() {
      try {
        FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).set({
          'email': googleUser!.email,
          'name': googleUser.displayName,
          'uid': _auth.currentUser!.uid,
          'status_message': "I promise to take the test honestly before GOD.",
          'profileimage': googleUser.photoUrl,
        });
        print('google signin with success');
      } catch (e) {
        Scaffold();
      }
    });
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> anonySignIn() async {
    UserCredential userCredential =
    await FirebaseAuth.instance.signInAnonymously();
    User? user = userCredential.user;
    setState(() {
      try {
        FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).set({
          'uid': user!.uid,
          'status_message': "I promise to take the test honestly before GOD.",
        });
        print('anonymous sign in success');
      } catch (e) {
        Scaffold();
      }
    });
    return userCredential;
  }
}

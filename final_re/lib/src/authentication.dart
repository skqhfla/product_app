import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../LoginProvider.dart';
import 'widgets.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  password,
  loggedIn,
}

class Authentication extends StatelessWidget {
  const Authentication({
    required this.loginState,
    this.email,
    required this.startLoginFlow,
    required this.signInAnonymously,
    required this.signInWithGoogle,
    required this.signOut,
  });

  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  final void Function(
      void Function(Exception e) error
      ) signInAnonymously;
  final void Function(BuildContext context) signInWithGoogle;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          child: const Text('Google'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            primary : Colors.red,
          ),
          onPressed: () async {
          //  _loginProvider.isLoginType('google');
            startLoginFlow();
            signInWithGoogle(context);
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
           // _loginProvider.isLoginType('');
            startLoginFlow();
            signInAnonymously(
                    (e) => _showErrorDialog(context, 'Failed to sign in', e)
            );
            Navigator.pop(context);
          },
        ),
      ],
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
}
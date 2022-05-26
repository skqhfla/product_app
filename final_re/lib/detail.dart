import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_re/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_re/Storage.dart';

import 'edit.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.docId,
  }) : super(key: key);
  final docId;

  static DetailPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<DetailPageState>();

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {

    bool _isAuth = false;
    int count = 0;
    String url = 'path';
    FirebaseAuth _auth = FirebaseAuth.instance;
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    void _delete() async {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      products.doc(widget.docId).delete();
    }

    final Stream<DocumentSnapshot> _stream = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.docId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          try {
            if (_auth.currentUser!.uid == snapshot.data!["ownerId"]) {
              print(_auth.currentUser!.uid);
              print("true");
              _isAuth = true;
            }
            return Scaffold(
              appBar: _isAuth
                  ? AppBar(
                      actions: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPage(
                                      docId: widget.docId,
                                    ),
                                  ));
                            },
                            icon: const Icon(Icons.create)),
                        IconButton(
                            onPressed: () {
                              _delete();
                            },
                            icon: const Icon(Icons.delete))
                      ],
                    )
                  : AppBar(),
              body: Column(
                children: [
                  FutureBuilder(
                      future: storage.downloadURL(snapshot.data!["picfile"]),
                      builder:
                          (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return SizedBox(
                              width: 600,
                              height: 240,
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.fill,
                              ));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        return Container();
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            snapshot.data!["productName"].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$ " + snapshot.data!["productPrice"].toString(),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(count < 1
                                ? Icons.thumb_up_alt_outlined
                                : Icons.thumb_up_alt),
                            onPressed: () {
                              count += 1;

                              Map<String, dynamic> data = <String, dynamic>{
                                'productLikes': count,
                              };

                              if (count > 1) {
                                SnackBarWidget.show(
                                    context, "You can do it only once!");
                              } else {
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(widget.docId.toString())
                                    .update(data)
                                    .whenComplete(
                                        () => print("update completed"))
                                    .catchError((e) => print(e));

                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(widget.docId.toString())
                                    .collection('likedUsers')
                                    .doc(_auth.currentUser!.uid)
                                    .set({
                                  'likedId': _auth.currentUser!.uid,
                                })
                                    .then((value) => print('liked added'))
                                    .catchError((error) => print("failed adding like"));
                                SnackBarWidget.show(context, "I like it!");
                              }
                            },
                          ),
                          Container(
                              padding: EdgeInsets.all(30),
                              child: Text(snapshot.data!["productLikes"].toString())),
                        ],
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 1.5,
                    height: 10,
                  ),
                  Container(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        snapshot.data!["productDesc"].toString(),
                      )),
                  const Divider(
                    height: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'creator: ' + snapshot.data!["ownerId"].toString()),
                        Text(DateFormat('yyyy-MM-dd kk:mm:ss').format(
                                snapshot.data!["productCreated"].toDate()) +
                            " created"),
                        Text(DateFormat('yyyy-MM-dd kk:mm:ss').format(
                                snapshot.data!["productModified"].toDate()) +
                            " modified"),
                      ],
                    ),
                  )
                ],
              ),
            );
          } catch (e) {
            return const Scaffold();
          }
        });
  }
}

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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DropDown.dart';
import 'LoginProvider.dart';
import 'profile.dart';
import 'package:final_re/Storage.dart';

import 'add.dart';
import 'appstate.dart';
import 'detail.dart';
import 'model/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Storage storage = Storage();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String title = 'Welcom Guest!';
  String dropdownValue = 'ASC';

  @override
  Widget build(BuildContext context) {
    DropDownProvider _dropProvider = Provider.of<DropDownProvider>(context);
    Stream<QuerySnapshot> _stream = Provider.of<DropDownProvider>(context).isASC
        ? FirebaseFirestore.instance
            .collection('products')
            .orderBy('productPrice')
            .snapshots()
        : FirebaseFirestore.instance
            .collection('products')
            .orderBy('productPrice', descending: true)
            .snapshots();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/profile', (route) => false);
          },
        ),
        title: Provider.of<LoginProvider>(context).isGooge == true
            ? Text('Welcome ' + _auth.currentUser!.displayName.toString() + '!')
            : Text('Welcome Guest!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add',
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                DropdownButton(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 20,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                      _dropProvider.isType(dropdownValue);
                    });
                    //provider
                  },
                  items: <String>['ASC', 'DESC']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16.0),
                    childAspectRatio: 8.0 / 9.0,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return ProdCard(
                        docId: document.id,
                        name: document['productName'].toString(),
                        price: document['productPrice'].toString(),
                        image: document['picfile'].toString(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          } else {
            return Card();
          }
        },
      ),
    );
  }
}

class ProdCard extends StatelessWidget {
  const ProdCard({
    Key? key,
    required this.docId,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);
  final docId;
  final name;
  final price;
  final image;

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18 / 11,
            child: FutureBuilder(
                future: storage.downloadURL(image),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Container(
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.fill,
                        ));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return Container();
                }),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 8,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            docId: docId,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'more',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      // padding: const EdgeInsets.all(0.0),
                      minimumSize: const Size(5, 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

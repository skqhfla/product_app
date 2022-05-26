import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_re/Storage.dart';

import 'appstate.dart';
import 'detail.dart';
import 'model/product.dart';

class EditPage extends StatefulWidget {
  const EditPage({
    Key? key,
    required this.docId,
  }) : super(key: key);
  final docId;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _productName = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String _fileName = "logo.png";
  final Storage storage = Storage();
  bool isUpload = false;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future updateProduct(BuildContext context) async {
    try {
      Map<String, dynamic> data = <String, dynamic>{
        'picfile': _fileName,
        'productName': _productName.text,
        'productPrice': _price.text,
        'productDesc': _description.text,
        'productModified': FieldValue.serverTimestamp(),
      };

      print("file");
      print(_fileName);

      return FirebaseFirestore.instance
          .collection('products')
          .doc(widget.docId)
          .update(data)
          .whenComplete(() => print("update completed"))
          .catchError((e) => print(e));
    } catch (e) {
      print(e);
    }
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String? url = "path";
    Stream<DocumentSnapshot> _stream = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.docId)
        .snapshots();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit"),
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            )),
        actions: [
          TextButton(
              onPressed: () {
                updateProduct(context);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _stream,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              if (_fileName == 'logo.png') _fileName = data["picfile"];
              _productName.text = data["productName"];
              _price.text = data["productPrice"].toString();
              _description.text = data["productDesc"];

              return Column(
                children: [
                  Container(
                      child: FutureBuilder(
                          future: storage.downloadURL(_fileName),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              print("file = ");
                              print(_fileName);
                              url = snapshot.data;
                              return Container(
                                  width: 600,
                                  height: 240,
                                  child: Image.network(
                                    url!,
                                    fit: BoxFit.fill,
                                  ));
                            }

                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            return Container();
                          })),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final results = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            // type: FileType.custom,
                          );

                          if (results == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No File selected.'),
                              ),
                            );
                            return;
                          } else {
                            final path = results.files.single.path;
                            final fileName = results.files.single.name;

                            setState(() {
                              print("new file");
                              print(fileName);
                              _fileName = fileName;
                              print("change file");
                              print(_fileName);
                              storage.uploadFile(path!, fileName);

                              url = path;
                              print(url);
                            });

                            //_url = storage.downloadURL(fileName);
                            //print('main url = ' + url);
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          decoration:
                              InputDecoration(labelText: 'Product Name'),
                          controller: _productName,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Price'),
                          controller: _price,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Description'),
                          controller: _description,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Container();
          }),
    );
  }
}

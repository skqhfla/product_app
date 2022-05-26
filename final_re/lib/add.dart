import 'package:file_picker/file_picker.dart';
import 'package:final_re/Storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'appstate.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _productName = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late PickedFile _image;
  final Storage storage = Storage();

  final ref = FirebaseStorage.instance.ref().child('logo.png');
  String _fileName = 'logo.png';

  final _formKey = GlobalKey<FormState>(debugLabel: '_AddPageState');

  @override
  Widget build(BuildContext context) {
    String? url = "late";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add"),
        actions: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 17),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await appState.addProductToMarket(_fileName, _productName.text,
                      int.parse(_price.text), _description.text);
                  _fileName = 'logo.png';
                  _productName.clear();
                  _price.clear();
                  _description.clear();
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget> [
          FutureBuilder(
              future: storage.downloadURL(_fileName),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  url = snapshot.data;
                  return Container(
                      width: 600,
                      height: 240,
                      child: Image.network(
                        url!,
                        fit: BoxFit.fill,
                      ));
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return Container();
              }),
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
                      storage.uploadFile(path!, fileName);
                      url = path;
                    });

                    _fileName = fileName;
                    //_url = storage.downloadURL(fileName);
                    //print('main url = ' + url);
                  }
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _productName,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Product Name',
                    ),
                  ),
                  TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Price',
                    ),
                  ),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

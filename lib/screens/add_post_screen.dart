// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_method.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  void postImage(String uid, String username, String profileImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethod().uploadPost(
          _descriptionController.text, _file!, uid, username, profileImage);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar("Posted", context);
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  _selectedImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          // ignore: prefer_const_literals_to_create_immutables
          return SimpleDialog(
            title: Text("Create a Post"),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("Take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("Choose from gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return _file == null
        ? Center(
            child: IconButton(
              icon: Icon(
                Icons.upload,
              ),
              onPressed: () => _selectedImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: Text("Post to"),
              actions: [
                TextButton(
                    onPressed: () => postImage(
                          user.uid,
                          user.username,
                          user.photoUrl,
                        ),
                    child: Text(
                      "Post",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 16,
                      ),
                    ))
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? LinearProgressIndicator()
                    : Padding(
                        padding: EdgeInsets.only(top: 0),
                      ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: "Create a Post",
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                            decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(_file!),
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                          ),
                        )),
                      ),
                    ),
                    Divider(),
                  ],
                )
              ],
            ),
          );
  }
}

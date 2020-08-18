import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'user.dart';

final auth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection("users");

class AccountPage extends StatelessWidget {
  AccountPage({this.uid,this.email});
  final String uid;
  final String email;
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "アカウント",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => auth.signOut(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(300),
          child: StreamBuilder<User>(
            stream: userRef.document(uid).snapshots().map((snapshot)=>User.fromMap(uid,snapshot.data)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                final user = snapshot.data;
                nameController.text = user.name;
                return Column(
                  children: <Widget>[
                    Avatar(
                      url: user?.url,
                      radius: 70,
                      borderColor: Colors.black54,
                      borderWidth: 2.0,
                      onPressed: () => _chooseAvatar(context, user),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: nameController,
                          onEditingComplete: () async {
                            User _newUser = user.copy(
                              name: nameController.text,
                            );
                            await userRef.document(uid).setData(_newUser.toMap());
                          },
                          decoration: InputDecoration(
                            labelText: "ニックネーム",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _chooseAvatar(BuildContext context, User user) async {
    // TODO Firebase StorageパッケージはWeb対応していないので未実装
    // https://gist.github.com/happyharis/d7a4a89bbac114af00f921f6c26ab728
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    @required this.url,
    @required this.radius,
    this.borderColor,
    this.borderWidth,
    this.onPressed,
  });
  final String url;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final ui.VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _borderDecoration(),
      child: InkWell(
        onTap: onPressed,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.black12,
          backgroundImage: url != null ? NetworkImage(url) : AssetImage("images/photo.png"),
          child: url == null ? Icon(Icons.camera_alt, size: radius) : null,
        ),
      ),
    );
  }

  Decoration _borderDecoration() {
    if (borderColor != null && borderWidth != null) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      );
    }
    return null;
  }
}
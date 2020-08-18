
import 'package:flutter/material.dart';

import 'account.dart';
import 'restopage.dart';

class HomePage extends StatefulWidget {
  final String uid;
  final String email;
  HomePage({Key key,this.uid,this.email}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          RestoPage(),
          AccountPage(uid:widget.uid,email:widget.email),
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "レストラン",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "アカウント",
          ),
        ],
        onTap: (index) {
          setState(() {
            _index = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
          );
        },
      ),
    );
  }
}

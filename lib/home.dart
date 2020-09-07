import 'package:flutter/material.dart';

import 'account.dart';
import 'restopage.dart';
import 'reviewpage.dart';

class HomePage extends StatefulWidget {
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
          ReviewPage(),
          AccountPage(),
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
            icon: Icon(Icons.rate_review),
            label: "レビュー",
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

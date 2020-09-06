import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'review.dart';
import 'reviewdetail.dart';
import 'starrating.dart';

// レビューページ
// スライドアップウィジットをアニメーション表示するのでステートレスが必須
class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with SingleTickerProviderStateMixin {
  SlideUpController slideUpController = SlideUpController();
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ))..addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        slideUpController.toggle();
      } else if (status == AnimationStatus.dismissed) {
        slideUpController.toggle();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        SlideUpState state = SlideUpState();
        state.starAddAll(Review.starSelectList);
        return state;
      },
      child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Consumer<SlideUpState> (
          builder: (context, provider, child) {
            return StreamBuilder<List<Review>>(
              stream: Review.getReviwsStream(provider.starSelectedList),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<Review> reviews = snapshot.data;
                  return Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text("レビュー",style:TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                    body: reviews.isNotEmpty ?
                      ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserReviewDetail(review: reviews[index]),
                              ));
                            },
                            child: RestoUserReviewListTile(review: reviews[index]),
                          );
                        }) : Container(child:Center(child:Text("対象のレビューはありません。"))));
                } else {
                  return Container(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        ),
        SlideTransition(
          position: _offsetAnimation,
          child: Container(
            child: SlideUp(),
          ),
        ),
        Align(
          // 画面右下は検索ボタン
          alignment: Alignment.bottomRight,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(topLeft: Radius.elliptical(25, 25)),
            ),
            child: InkWell(
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onTap: () {
                if (_controller.isDismissed) {
                  // スライドアップ
                  _controller.forward();
                } else {
                  // スライドダウン
                  _controller.reverse();
                }
              },
            ),
          ),
        ),
      ],
      ),
    );
  }
}

// スライドアップページ
class SlideUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Consumer<SlideUpState>(
      builder: (context, provider, child) {
        SlideUpController controller = SlideUpController();
        controller.providerContext = context;
        return provider.isShow
            ? Container(
                height: 70,
                width: screenWidth,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(5, 5),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.only(
                      top: 10, bottom: 10, left: 10, right: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text("星数： ")],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: StarChoiceChip(),
                      ),
                    ],
                  ),
                ),
              )
            : Container();
      },
    );
  }
}

// 検索用星数リスト
class StarChoiceChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SlideUpState> (
      builder: (context, provider, child) {
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: 
            Review.starSelectList.map((star) {
              return Container(
                padding: EdgeInsets.only(right: 2),
                child: ChoiceChip(
                  backgroundColor: Colors.grey,
                  selectedColor: Colors.indigo,
                  label: Text(" $star ",style:TextStyle(fontSize:15,color:Colors.white)),
                  selected: provider.starSelectedList.contains(star),
                  onSelected: (_) {
                    provider.starContains(star)
                    ? provider.starRemove(star)
                    : provider.starAdd(star);
                  },
                ),
              );
            }).toList(),
        );
      },
    );
  }
}

// スライドアップのコントローラ
class SlideUpController {
  SlideUpController._private();
  static final SlideUpController instance = SlideUpController._private();
  factory SlideUpController() => instance;
  BuildContext _providerContext;
  set providerContext(BuildContext context) {
    _providerContext = context;
  }

  // 検索スライドの開閉を操作する
  void toggle() {
    _providerContext.read<SlideUpState>().updateState(!_providerContext.read<SlideUpState>().isShow);
  }
}

// スライドアップで保持する状態データ（スライドの開閉状態と検索条件星数リスト）
class SlideUpState with ChangeNotifier {
  // スライドの開閉状態
  bool isShow = false;
  void updateState(bool newState) {
    isShow = newState;
    notifyListeners();
  }
  // 検索条件の星数リスト
  List<int> starSelectedList = List<int>();
  // 検索条件星数リストに指定した星が含まれるかチェック
  bool starContains(int star) {
    return starSelectedList.contains(star);
  }
  // 検索条件星数リストから指定した星を削除
  void starRemove(int star) {
    starSelectedList.remove(star);
    notifyListeners();
  }
  // 検索条件星数リストに指定した星を追加
  void starAdd(int star) {
    starSelectedList.add(star);
    notifyListeners();
  }
  // 検索条件星数リストに星リストを追加
  void starAddAll(List<int> stars) {
    starSelectedList.addAll(stars);
    notifyListeners();
  }
}

// レストランとユーザ画像を表示するタイル
class RestoUserReviewListTile extends StatelessWidget {
  RestoUserReviewListTile({@required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: review.id,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(review.userphotourl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.only(top: 5),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(review.restologo),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(5.0)),
          ),
          SizedBox(width: 10),
          StarRating(
            rating: review.star.toDouble(),
          ),
        ],
      ),
      subtitle: Text(
        review.comment,
        style: TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

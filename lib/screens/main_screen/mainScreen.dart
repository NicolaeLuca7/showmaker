import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showmaker/common/myType.dart';
import 'package:showmaker/database/ShowPreview/showPreview.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';
import 'package:showmaker/screens/Show/configure/configureScreen.dart';
import 'package:showmaker/screens/Show/view/viewShow.dart';
import 'package:showmaker/screens/ShowPreview/prevCard.dart';
import '../../database/User/user.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

class MainScreen extends StatefulWidget {
  final User1 user1;
  const MainScreen({required this.user1, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState(user1: user1);
}

class _MainScreenState extends State<MainScreen> {
  User1 user1;
  _MainScreenState({required this.user1});

  double aheight = 0, awidth = 0;

  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();

  MyType<double> currentPage = MyType<double>(0);

  bool loadingNext = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int next = 4, loaded = 0;
  int previewsCount = 0;

  List<ShowPreview> previews = [];

  var lastDocument;

  bool loading = true;

  @override
  void initState() {
    pageController.addListener(() {
      double next = pageController.page ?? 0;
      setState(() {
        currentPage.value = next;
      });
    });

    initScreen();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constrains) {
            aheight = constrains.maxHeight;
            awidth = constrains.maxWidth;
            return SingleChildScrollView(
              child: Container(
                height: aheight,
                width: awidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [themeColors.lightBlack, themeColors.darkBlack],
                      transform: GradientRotation(pi / 4)),
                ),
                child: Center(
                  child: !loading
                      ? Stack(
                          children: [
                            Container(
                              child: Center(
                                child: Column(
                                  children: [
                                    Spacer(),

                                    //
                                    Container(
                                        height: 270,
                                        width: awidth,
                                        child: /*FirestoreListView(
                                          controller: scrollController,
                                          scrollDirection: Axis.horizontal,
                                          query: firestore
                                              .collection('showsPreviews')
                                              .where('userId',
                                                  isEqualTo: user1.getId())
                                              .orderBy('creationDate',
                                                  descending: true),
                                          itemBuilder: (context, doc) {
                                            ShowPreview preview =
                                                ShowPreview.fromDatabase(
                                                    doc.data());
                                            return SingleChildScrollView(
                                              child: getPrevCard(
                                                  context,
                                                  scrollController.offset >
                                                      0.5, //currentPage.value == index,
                                                  270,
                                                  awidth,
                                                  preview),
                                            );
                                          },
                                        ),
                                      ), */
                                            PageView.builder(
                                          controller: pageController,
                                          itemCount: loaded + 1,
                                          itemBuilder: (context, index) {
                                            if (index < loaded) {
                                              return SingleChildScrollView(
                                                child: getPrevCard(
                                                    context,
                                                    currentPage.value == index,
                                                    500,
                                                    awidth,
                                                    previews[index],
                                                    openPreview),
                                              );
                                            } else {
                                              if (loaded == previewsCount)
                                                return Container();
                                              return !loadingNext
                                                  ? Center(
                                                      child: IconButton(
                                                        tooltip: "Load more",
                                                        onPressed: () =>
                                                            loadNextItems(),
                                                        icon: Icon(
                                                          Icons.add,
                                                          size: 30,
                                                          color: themeColors
                                                              .yellowOrange,
                                                        ),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: themeColors
                                                            .yellowOrange,
                                                      ),
                                                    );
                                            }
                                          },
                                        )),
                                    //

                                    Spacer(),

                                    Padding(
                                      padding: EdgeInsets.only(bottom: 40),
                                      child: CustomButton(
                                        widget: Row(
                                          children: [
                                            Spacer(),
                                            Text(
                                              "Create",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 30),
                                            ),
                                            Spacer(flex: 1),
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            Spacer(flex: 2)
                                          ],
                                        ),
                                        height: 60,
                                        width: 140,
                                        borderRadius: BorderRadius.circular(10),
                                        activated: true,
                                        backgroundColors: [
                                          themeColors.accentBlack,
                                        ],
                                        borderColors: [
                                          themeColors.lightOrange
                                              .withOpacity(0.8),
                                          themeColors.darkOrange
                                              .withOpacity(0.8)
                                        ],
                                        borderWidth: 2,
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: "/ConfigureScreen"),
                                              builder: ((context) =>
                                                  ConfigureScreen(
                                                    parameters:
                                                        par.Parameters(),
                                                    images: [],
                                                    backgroundImage:
                                                        MyType(null),
                                                    userId: user1.getId()!,
                                                    existing: false,
                                                    settings: [],
                                                    showId: null,
                                                    previewId: null,
                                                  )),
                                            ),
                                          );
                                          reloadPreviews();
                                        },
                                      ),
                                    )
                                    //SizedBox(height: 40)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : CircularProgressIndicator(
                          color: themeColors.yellowOrange,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void initScreen() async {
    previewsCount = (await firestore
            .collection('showsPreviews')
            .where('userId', isEqualTo: user1.getId()!)
            .count()
            .get())
        .count;
    next = min(next, previewsCount);

    await loadNextItems();
    loading = false;
    setState(() {});
  }

  void reloadPreviews() async {
    loading = true;
    setState(() {});
    loaded = 0;
    next = 4;
    currentPage = MyType<double>(0);
    previews.clear();
    initScreen();
  }

  Future<void> loadNextItems() async {
    if (previewsCount == 0) return;

    loadingNext = true;
    setState(() {});

    next = min(next, previewsCount - loaded);
    List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots = [];

    if (loaded == 0) {
      snapshots = (await firestore
              .collection('showsPreviews')
              .where('userId', isEqualTo: user1.getId()!)
              .orderBy('creationDate', descending: true)
              .limit(next)
              .get())
          .docs;
    } else {
      snapshots = (await firestore
              .collection('showsPreviews')
              .where('userId', isEqualTo: user1.getId()!)
              .orderBy('creationDate', descending: true)
              .startAfterDocument(lastDocument)
              .limit(next)
              .get())
          .docs;
    }
    for (var doc in snapshots) {
      previews.add(ShowPreview.fromDatabase(doc.data()));
    }
    loaded += next;
    lastDocument = snapshots.last;

    loadingNext = false;
    setState(() {});
  }

  void openPreview(ShowPreview preview) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/ViewShow'),
        builder: (context) => ViewShow(id: preview.showId),
      ),
    );
    reloadPreviews();
  }
}

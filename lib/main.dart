import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackpack/detail.dart';
import 'package:trackpack/helper/utils.dart';

import 'helper/picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackpack',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  FancyDrawerController _controller;
  ScrollController _scrollController;
  List<Widget> _drawerItems = [];

  bool _floatVisibility = false;
  InterstitialAd myInterstitial;

  @override
  void initState() {
    _setPermission();
    FirebaseAdMob.instance.initialize(appId: Utils.appId);
    myInterstitial = buildInterstitialAd()..load();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {}); // Must call setState
      }); // This chunk of code is important

    _drawerItems = [
      buildItemDrawers(EvaIcons.pinOutline, "Tracking"),
      buildItemDrawers(EvaIcons.pantone, "History"),
      buildItemDrawers(EvaIcons.bellOutline, "Notification"),
      buildItemDrawers(EvaIcons.settingsOutline, "Setting"),
      buildItemDrawers(EvaIcons.infoOutline, "Help & Support"),
    ];
    super.initState();
  }

  @override
  void dispose() {
//    _bannerAd.dispose();
    myInterstitial.dispose();
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: Utils.interestId,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          myInterstitial..load();
        } else if (event == MobileAdEvent.closed) {
          myInterstitial = buildInterstitialAd()..load();
        }
        print(event);
      },
    );
  }

  void showInterstitialAd() {
    myInterstitial..show();
  }

  void showRandomInterstitialAd() {
    Random r = new Random();
    bool value = r.nextBool();

    if (value == true) {
      myInterstitial..show();
    }
  }

  _setPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
  }

  _scrollListener() {}

  _onUpdateScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= 90 && !_floatVisibility) {
      setState(() {
        _floatVisibility = true;
      });
    }

    if (metrics.pixels <= 60 && _floatVisibility) {
      setState(() {
        _floatVisibility = false;
      });
    }
  }

  Route _createRoute(trackingCode) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DetailPage(
        trackingCode: trackingCode,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FancyDrawerWrapper(
        backgroundColor: Color(0xff5841BF),
        controller: _controller,
        drawerItems: _drawerItems,
        child: Scaffold(
          body: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  NotificationListener(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        _onUpdateScroll(scrollNotification.metrics);
                      }
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          bannerWidget(),
                          myServiceWidget(),
                          informationWidget(),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _floatVisibility,
                    child: Positioned(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              height: MediaQuery.of(context).size.height / 11,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(
                                              173, 179, 191, 0.4),
                                          blurRadius: 10.0,
                                          offset: Offset(0.0, -5.0))
                                    ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    buildBottomNav(EvaIcons.pinOutline,
                                        "Tracking", Color(0xff5841BF), () {}),
                                    buildBottomNav(EvaIcons.pantone, "History",
                                        Color(0xffFF7750), () {}),
                                    buildBottomNav(
                                        EvaIcons.bellOutline,
                                        "Notification",
                                        Color(0xff2F972B),
                                        () {}),
                                    buildBottomNav(EvaIcons.menu2Outline,
                                        "Menu", Color(0xff005EB8), () {
                                      _controller.toggle();
                                    }),
                                  ],
                                ),
                              ))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bannerWidget() {
    return SizedBox(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 1.7,
        decoration: BoxDecoration(
            color: Color(0xff4E37B2),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/skuter.png",
                  height: MediaQuery.of(context).size.height / 3.4,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _controller.toggle();
                          },
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Trackpack',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Powered by Irvan',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: CircleImageInkWell(
                            onPressed: () {
                              print('onPressed');
                            },
                            size: 35,
                            image: CachedNetworkImageProvider(
                              "https://randomuser.me/api/portraits/men/22.jpg",
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Tracking Your Shipment',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Please enter your tracking number.',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 32),
                        width: MediaQuery.of(context).size.width / 1.2,
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                                child: Icon(
                              EvaIcons.pricetagsOutline,
                              color: Color(0xffea4c89),
                            )),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: TextField(
                                  onSubmitted: (data) {
                                    dialogWidget(data);
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter a tracking code',
                                      hintStyle: TextStyle(
                                          color: Colors.black, fontSize: 14)),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  dialogWidget(data) {
    showPrompt(
        context: context,
        title: "Are you sure ?",
        pathLottie: "assets/search.json",
        detailContent:
            "please do a report if there is a deviation with the data!",
        onSubmit: () {
          showInterstitialAd();
          Navigator.of(context).push(_createRoute(data));
        });
  }

  Widget myServiceWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'My Service',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    "View All",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffff3d1f),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Color(0xffFF7750),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width / 2.3,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: 8,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 51,
                    child: FadeInAnimation(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: Color(0xffdfdff1),
                            borderRadius: BorderRadius.circular(20)),
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          margin: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Color(0xff5841BF),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Image.asset("assets/delivery.png"),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Shipping',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Safe delivery',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget informationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Information',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    "View All",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffff3d1f),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Color(0xffFF7750),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://images.pexels.com/photos/4392043/pexels-photo-4392043.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260",
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Rules tracking in pandemi !!',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna...',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: 40,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://randomuser.me/api/portraits/men/32.jpg",
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Irvan Lutfi Gunawan',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '2 days ago',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  buildItemDrawers(IconData icon, String title) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          '$title',
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  buildBottomNav(
      IconData icon, String title, Color color, GestureTapCallback action) {
    return Expanded(
      child: InkWell(
        onTap: action,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(50)),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$title',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:edge_alert/edge_alert.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'helper/picker.dart';
import 'helper/utils.dart';

class DetailPage extends StatefulWidget {
  final String trackingCode;

  const DetailPage({Key key, this.trackingCode}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  BannerAd _bannerAd;
  AnimationController _controller;

  bool isLoading = true;

  String get trackingCode => widget.trackingCode;
  TextEditingController trackingController = TextEditingController();

  @override
  void initState() {
    trackingController.text = trackingCode;
    FirebaseAdMob.instance.initialize(appId: Utils.appId);
    _bannerAd = buildBannerAd()..load();
    _controller = AnimationController(vsync: this);
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
        adUnitId: Utils.bannerId,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            _bannerAd..show();
          }
        });
  }

  BannerAd buildLargeBannerAd() {
    return BannerAd(
        adUnitId: Utils.bannerId,
        size: AdSize.largeBanner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            _bannerAd
              ..show(
                  anchorType: AnchorType.bottom,
                  anchorOffset: MediaQuery.of(context).size.height * 0.15);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 200),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(35),
                  bottomLeft: Radius.circular(35)),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(173, 179, 191, 0.4),
                    blurRadius: 10.0,
                    offset: Offset(0.0, -5.0))
              ]),
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffEBECF2),
                ),
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
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
                        child: TextField(
                          controller: trackingController,
                          enabled: false,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a tracking code',
                              hintStyle:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            EvaIcons.clockOutline,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Last update",
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Color(0xffff3d1f),
                                  ),
                                ),
                                Text(
                                  '12:00',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                                Future.delayed(Duration(seconds: 3), () {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 22),
                              decoration: BoxDecoration(
                                  color: Color(0xffF4F4F8),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: <Widget>[
                                  Icon(EvaIcons.refreshOutline),
                                  Expanded(
                                    child: Text(
                                      "Refresh",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[historyComponent()],
            ),
          ),
        ),
      ),
    );
  }

  Widget historyComponent() {
    return FutureBuilder(
      future: _bannerAd.isLoaded(),
      builder: (context, isLoaded) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 64),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(173, 179, 191, 0.4),
                          blurRadius: 4.0,
                          offset: Offset(2.0, -1.0))
                    ]),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (isLoading) ...[
                      Container(
                        margin: EdgeInsets.all(32),
                        child: SpinKitWave(
                          color: Color(0xff5841BF).withOpacity(0.2),
                          size: 50.0,
                        ),
                      )
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'History',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showPrompt(
                                  context: context,
                                  title: "Are you sure ?",
                                  pathLottie: "assets/report.json",
                                  height: 315,
                                  detailContent:
                                      "Please before tracking, double-check the code you entered!",
                                  onSubmit: () {
                                    Navigator.of(context).pop();
                                    _colorfullAlert();
                                  });
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Report",
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
                                    EvaIcons.alertCircleOutline,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xff5841BF)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          EvaIcons.inboxOutline,
                                          size: 24,
                                          color: Color(0xff5841BF)
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Deliver to Customer",
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    "In Process",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "12:00",
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 12,
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            );
                          },
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _colorfullAlert() {
    EdgeAlert.show(context,
        title: 'Report',
        description: 'Report Success',
        gravity: EdgeAlert.TOP,
        backgroundColor: Colors.red);
  }
}

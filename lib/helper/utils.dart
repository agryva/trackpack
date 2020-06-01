import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_config/flutter_config.dart';

class Utils {
  static final String appId = "YOUR KEY" ?? FirebaseAdMob.testAppId;
  static final String interestId = "YOUR KEY" ?? InterstitialAd.testAdUnitId;
  static final String bannerId ="YOUR KEY" ?? BannerAd.testAdUnitId;
}

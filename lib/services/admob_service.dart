import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdMobService {
  static bool _isInitialized = false;
  
  // Use production IDs if available, otherwise fallback to test IDs
  static final String _bannerAdUnitId = AdMobConfig.bannerAdUnitId != 'YOUR_BANNER_AD_UNIT_ID_HERE'
      ? AdMobConfig.bannerAdUnitId
      : AdMobConfig.testBannerAdUnitId;
      
  static final String _interstitialAdUnitId = AdMobConfig.interstitialAdUnitId != 'YOUR_INTERSTITIAL_AD_UNIT_ID_HERE'
      ? AdMobConfig.interstitialAdUnitId
      : AdMobConfig.testInterstitialAdUnitId;
      
  static final String _rewardedAdUnitId = AdMobConfig.rewardedAdUnitId != 'YOUR_REWARDED_AD_UNIT_ID_HERE'
      ? AdMobConfig.rewardedAdUnitId
      : AdMobConfig.testRewardedAdUnitId;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('✅ AdMob initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize AdMob: $e');
      _isInitialized = false;
    }
  }

  static String get bannerAdUnitId => _bannerAdUnitId;
  static String get interstitialAdUnitId => _interstitialAdUnitId;
  static String get rewardedAdUnitId => _rewardedAdUnitId;

  static bool get isInitialized => _isInitialized;
}

class AdMobBannerWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;

  const AdMobBannerWidget({
    super.key,
    required this.adUnitId,
    this.adSize = AdSize.banner,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    print('🔄 Loading AdMob banner with ID: ${widget.adUnitId}');
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ AdMob banner loaded successfully');
          setState(() {
            _isAdLoaded = true;
          });
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ AdMob banner failed to load: ${error.message}');
          ad.dispose();
          widget.onAdFailedToLoad?.call();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      // Show a placeholder while ad is loading
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'Loading Ad...',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}

class AdMobInterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isAdReady = false;

  static Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
        },
        ),
      );
    } catch (e) {
      _isAdReady = false;
    }
  }

  static Future<void> showInterstitialAd() async {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {},
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdReady = false;
          _interstitialAd = null;
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdReady = false;
          _interstitialAd = null;
        },
      );

      await _interstitialAd!.show();
    }
  }

  static bool get isAdReady => _isAdReady;
}

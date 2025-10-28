import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static bool _isInitialized = false;
  
  static final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner
      : 'ca-app-pub-3940256099942544/6300978111';
      
  static final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial
      : 'ca-app-pub-3940256099942544/1033173712';
      
  static final String _rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Test Rewarded
      : 'ca-app-pub-3940256099942544/5224354917';

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize AdMob: $e');
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
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
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
      return const SizedBox.shrink();
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

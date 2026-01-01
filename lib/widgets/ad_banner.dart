import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdBanner extends StatefulWidget {
  final String adId;
  final bool useAdMob;
  final AdSize adSize;

  const AdBanner({
    super.key,
    required this.adId,
    this.useAdMob = true,
    this.adSize = AdSize.banner,
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the ad alive when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (widget.useAdMob && AdMobService.isInitialized) {
      return AdMobBannerWidget(
        adUnitId: AdMobService.bannerAdUnitId,
        adSize: widget.adSize,
      );
    }

    // Fallback - show empty space if AdMob is not available
    return const SizedBox(height: 50);
  }
}

class AdManager {
  static bool shouldShowAd(int itemIndex) {
    // Show ads after every 5 articles, starting from the 5th position (index 4)
    return itemIndex > 0 && (itemIndex + 1) % 6 == 0;
  }
}

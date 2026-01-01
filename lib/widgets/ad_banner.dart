import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme.dart';
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

class _AdBannerState extends State<AdBanner> {
  @override
  Widget build(BuildContext context) {
    if (widget.useAdMob && AdMobService.isInitialized) {
      return AdMobBannerWidget(
        adUnitId: AdMobService.bannerAdUnitId,
        adSize: widget.adSize,
        onAdLoaded: () {
          // Ad loaded successfully
        },
        onAdFailedToLoad: () {
          // Ad failed to load
        },
      );
    }

    // Fallback to placeholder ad if AdMob is not available
    return _buildPlaceholderAd(context);
  }

  Widget _buildPlaceholderAd(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryYellow.withValues(alpha: 0.05),
            AppTheme.darkBlue.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'AD',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPlaceholderContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: 200,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 32,
          width: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class AdManager {
  static bool shouldShowAd(int itemIndex) {
    // Show ads after every 5 articles, starting from the 5th position (index 4)
    return itemIndex > 0 && (itemIndex + 1) % 6 == 0;
  }
}

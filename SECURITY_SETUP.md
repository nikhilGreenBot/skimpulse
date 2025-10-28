# 🔒 AdMob Security Setup

## ⚠️ Important: Your AdMob IDs are Currently Exposed!

Since this repository is public, your AdMob IDs are visible to everyone. This can lead to:
- **Ad fraud** and revenue theft
- **Policy violations** with AdMob
- **Account suspension**

## 🛡️ Secure Your AdMob IDs

### Step 1: Create Your Private Config File
```bash
# Copy the template to create your private config
cp lib/config/admob_config_template.dart lib/config/admob_config.dart
```

### Step 2: Add Your Real AdMob IDs
Edit `lib/config/admob_config.dart` and replace the placeholder values:

```dart
class AdMobConfig {
  // Replace these with your actual AdMob IDs from AdMob Console
  static const String androidAppId = 'ca-app-pub-1295716450289633~1054157446';
  static const String iosAppId = 'ca-app-pub-1295716450289633~1054157446';
  static const String bannerAdUnitId = 'ca-app-pub-1295716450289633/4487696490';
  static const String interstitialAdUnitId = 'ca-app-pub-1295716450289633/4487696490';
  static const String rewardedAdUnitId = 'ca-app-pub-1295716450289633/4487696490';
  
  // Test Ad Unit IDs (safe to commit)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
}
```

### Step 3: Update Android Manifest
In `android/app/src/main/AndroidManifest.xml`, replace the test App ID with your real one:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-1295716450289633~1054157446"/>
```

### Step 4: Update iOS Info.plist
In `ios/Runner/Info.plist`, replace the test App ID with your real one:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-1295716450289633~1054157446</string>
```

## ✅ Security Features

- **`admob_config.dart` is gitignored** - won't be committed to public repo
- **Template file** shows structure without real IDs
- **Automatic fallback** to test IDs if config is missing
- **Safe for public repositories**

## 🚨 What NOT to Commit

- ❌ `lib/config/admob_config.dart` (contains real IDs)
- ❌ Any file with your actual AdMob IDs
- ❌ `.env` files with sensitive data

## ✅ What IS Safe to Commit

- ✅ `lib/config/admob_config_template.dart` (template only)
- ✅ Test Ad Unit IDs (Google's test IDs)
- ✅ Code structure and logic

## 🔄 After Setup

1. **Test your app** - should work with real ads
2. **Verify gitignore** - `admob_config.dart` should not appear in `git status`
3. **Commit changes** - only template and code changes
4. **Push to GitHub** - real IDs stay private

## 📞 Need Help?

If you see any issues:
1. Check that `admob_config.dart` exists
2. Verify your AdMob IDs are correct
3. Ensure the file is in `.gitignore`
4. Test with `flutter run`

---

**Your AdMob IDs are now secure!** 🔒✅

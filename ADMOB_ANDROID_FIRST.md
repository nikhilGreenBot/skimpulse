# AdMob Setup: Android First Approach

## 🎯 Current Situation
- App is not yet published to any app store
- AdMob requires platform selection (Android or iOS)
- Need to start with one platform

## ✅ Recommended: Start with Android

### Why Android First?
1. **No app store required** - Can test with APK files
2. **Faster setup** - Less complex than iOS
3. **Easier testing** - Install directly on Android devices
4. **Lower cost** - No Apple Developer Program fee initially

## 📱 AdMob Setup Steps

### Step 1: Create AdMob Account
1. Go to [AdMob Console](https://apps.admob.com/)
2. Sign in with Google account
3. Click "Add app"

### Step 2: Add Android App
1. **Select "Android"** (not iOS)
2. **Select "No"** for "Is the app listed on a supported app store?"
3. **App name**: Skimpulse
4. **Package name**: `com.example.skimpulse` (or your actual package name)
5. Click **"Continue"**

### Step 3: Get Ad Unit IDs
1. After app creation, go to "Ad units"
2. Create a new ad unit:
   - **Ad format**: Banner
   - **Ad unit name**: Skimpulse Banner
3. Copy the **Ad Unit ID** (looks like `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)

### Step 4: Update Your App
Replace the test IDs in `lib/services/admob_service.dart`:

```dart
// Replace this line:
static final String _bannerAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111' // Android Test Banner
    : 'ca-app-pub-3940256099942544/6300978111'; // Use Android test for now

// With your production ID:
static final String _bannerAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' // Your Android Banner ID
    : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Same for now
```

### Step 5: Update Android Manifest
In `android/app/src/main/AndroidManifest.xml`, replace the test App ID:

```xml
<!-- Replace this: -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- With your production App ID: -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

## 🧪 Testing Your App

### Build and Test
```bash
# Build APK for testing
flutter build apk --debug

# Install on Android device
flutter install
```

### What to Expect
- **Test ads** will show "Test Ad" labels
- **Real ads** will show actual advertisements
- **Revenue tracking** in AdMob console

## 📈 Next Steps (After Android is Working)

### Phase 2: Add iOS Support
1. **Go back to AdMob Console**
2. **Add iOS platform** to your existing app
3. **Get iOS Ad Unit IDs**
4. **Update your Flutter app** with iOS-specific IDs

### Phase 3: App Store Publishing
1. **Publish to Google Play Store** (Android)
2. **Publish to Apple App Store** (iOS)
3. **Update AdMob** to mark apps as "listed on supported app store"

## 🚨 Important Notes

### AdMob Review Process
- **New apps need approval** before showing real ads
- **Review takes 2-3 days** typically
- **Limited ad serving** until approved
- **Test ads work immediately** (no approval needed)

### Revenue Expectations
- **Test ads**: No revenue (for development)
- **Real ads**: Start earning after approval
- **Revenue varies** by country, ad type, user engagement

## 🛠️ Quick Test

To verify everything works:

1. **Run your app** on Android device
2. **Scroll through articles** - you should see ads every 5th article
3. **Check console logs** for ad load success/failure
4. **AdMob console** should show impressions (after approval)

## 📞 Need Help?

- **AdMob Issues**: Check [AdMob Help Center](https://support.google.com/admob/)
- **Flutter Issues**: Check [Flutter AdMob Plugin](https://pub.dev/packages/google_mobile_ads)
- **App Issues**: Check Flutter console logs

---

**Start with Android, get it working, then expand to iOS!** 🚀

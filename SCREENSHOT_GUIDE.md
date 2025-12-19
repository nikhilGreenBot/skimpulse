# Screenshot Guide for App Store Submission

## 📱 Required Screenshots

### Android (Google Play)
- **Minimum**: 2 phone screenshots (required)
- **Recommended**: 4-8 screenshots
- **Sizes**: 
  - Phone: 320px - 3840px (recommended: 1080x1920)
  - Tablet: 320px - 3840px (if supporting tablets)

### iOS (App Store)
- **Required device sizes**:
  - iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max, etc.) - 1290x2796
  - iPhone 6.5" (iPhone 11 Pro Max, XS Max) - 1242x2688
  - iPhone 5.5" (iPhone 8 Plus) - 1242x2208
  - iPad Pro 12.9" (if supporting iPad) - 2048x2732
  - iPad Pro 11" (if supporting iPad) - 1668x2388

## 🎯 Screenshots to Capture

### 1. Main Article List Screen (REQUIRED)
**What to show:**
- Article list with numbered items
- App bar with "Skimpulse" title and panda icon
- Floating action buttons (theme & sort)
- Beautiful gradient cards with articles
- At least 3-4 visible articles

**How to capture:**
1. Run the app: `flutter run`
2. Wait for articles to load
3. Scroll to show multiple articles
4. Take screenshot

**File name:** `android-main-list.png` / `ios-main-list.png`

---

### 2. Article Reading View (REQUIRED)
**What to show:**
- Article opened in webview
- App bar with back button
- Article content visible
- Clean reading interface

**How to capture:**
1. Tap on any article
2. Wait for article to load
3. Scroll to show article content
4. Take screenshot

**File name:** `android-article-view.png` / `ios-article-view.png`

---

### 3. Theme Selection (RECOMMENDED)
**What to show:**
- Bottom sheet with theme options
- Light, Dark, and Colorful themes visible
- Current selection highlighted

**How to capture:**
1. Tap the theme FAB (bottom right)
2. Bottom sheet opens showing themes
3. Take screenshot

**File name:** `android-theme-selection.png` / `ios-theme-selection.png`

---

### 4. Sort Options (RECOMMENDED)
**What to show:**
- Bottom sheet with sort options
- Original Order, A-Z, Z-A, Top Ranking, Lower Ranking
- Current selection highlighted

**How to capture:**
1. Tap the sort FAB (bottom right, second button)
2. Bottom sheet opens showing sort options
3. Take screenshot

**File name:** `android-sort-options.png` / `ios-sort-options.png`

---

### 5. Different Theme Views (OPTIONAL)
**What to show:**
- Same main screen but with different themes
- Light theme
- Dark theme
- Colorful theme

**How to capture:**
1. Change theme using theme FAB
2. Take screenshot of main screen
3. Repeat for each theme

**File name:** `android-dark-theme.png`, `android-colorful-theme.png`, etc.

---

## 📸 How to Take Screenshots

### Android (Physical Device or Emulator)
1. **Using ADB:**
   ```bash
   adb shell screencap -p /sdcard/screenshot.png
   adb pull /sdcard/screenshot.png screenshots/android/
   ```

2. **Using Device:**
   - Press Power + Volume Down (most devices)
   - Or use device screenshot feature
   - Transfer to computer

3. **Using Emulator:**
   - Click camera icon in emulator toolbar
   - Or use `flutter run` and take screenshot from emulator

### iOS (Physical Device or Simulator)
1. **Using Simulator:**
   ```bash
   # Run app in simulator
   flutter run
   
   # In simulator: Device → Screenshot
   # Or use: Cmd + S in simulator
   ```

2. **Using Physical Device:**
   - Press Power + Volume Up (iPhone X and later)
   - Or Power + Home (iPhone 8 and earlier)
   - Transfer via Photos app or Finder

3. **Using Command Line:**
   ```bash
   xcrun simctl io booted screenshot screenshots/ios/screenshot.png
   ```

---

## ✂️ Screenshot Editing Tips

1. **Remove Status Bar (Optional):**
   - Some stores prefer screenshots without status bar
   - Use image editor to crop top area

2. **Add Device Frame (Optional):**
   - Use tools like [AppMockup](https://app-mockup.com/) or [Screenshots.pro](https://screenshots.pro/)
   - Makes screenshots look more professional

3. **Ensure Quality:**
   - Use PNG format for best quality
   - Ensure text is readable
   - Check that UI elements are clear

4. **Consistency:**
   - Use same device frame for all screenshots
   - Keep same theme across screenshots (or show variety)
   - Maintain consistent spacing

---

## 📁 File Organization

After taking screenshots, organize them:

```
screenshots/
├── android/
│   ├── android-main-list.png
│   ├── android-article-view.png
│   ├── android-theme-selection.png
│   └── android-sort-options.png
├── ios/
│   ├── ios-main-list-6.7.png (iPhone 14 Pro Max)
│   ├── ios-main-list-6.5.png (iPhone 11 Pro Max)
│   ├── ios-article-view-6.7.png
│   └── ios-article-view-6.5.png
└── README.md
```

---

## ✅ Screenshot Checklist

### Android
- [ ] Main article list (required)
- [ ] Article reading view (required)
- [ ] Theme selection (recommended)
- [ ] Sort options (recommended)
- [ ] At least 2 screenshots total

### iOS
- [ ] Main article list - iPhone 6.7" (required)
- [ ] Main article list - iPhone 6.5" (required)
- [ ] Main article list - iPhone 5.5" (required)
- [ ] Article reading view - iPhone 6.7" (recommended)
- [ ] Article reading view - iPhone 6.5" (recommended)
- [ ] Theme selection (optional)
- [ ] Sort options (optional)

---

## 🚀 Quick Start

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Take screenshots** using methods above

3. **Save to appropriate folders:**
   - Android: `screenshots/android/`
   - iOS: `screenshots/ios/`

4. **Verify:**
   - All required screenshots present
   - Images are clear and readable
   - File sizes are reasonable (not too large)

5. **Upload to stores:**
   - Google Play Console → Store listing → Screenshots
   - App Store Connect → App Store → Screenshots

---

## 💡 Pro Tips

- **Show real content**: Make sure articles are loaded and visible
- **Highlight features**: Use screenshots that show key features (sorting, themes)
- **Professional look**: Consider using device frames for polished appearance
- **Test on real devices**: Screenshots from real devices often look better than emulators
- **Multiple themes**: Show variety by including different theme screenshots

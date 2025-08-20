# Skimpulse App

A Flutter mobile application that displays trending articles from Skimfeed.com in a clean, modern interface.

## Features

- 📱 **Cross-platform**: Works on iOS and Android
- 📰 **Real-time content**: Fetches latest articles from Skimfeed.com
- 🔄 **Pull to refresh**: Easy content refresh functionality
- 🌐 **External browser**: Opens articles in your default browser
- 🎨 **Modern UI**: Material Design 3 with beautiful animations
- ⚡ **Fast loading**: Optimized network requests and caching

## Screenshots

*Add screenshots here once the app is running*

## Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- iOS Simulator (for iOS development)
- Android Studio / Android Emulator (for Android development)
- Node.js (for the backend server)

## Installation

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd skimpulse_app
```

### 2. Install Flutter dependencies
```bash
flutter pub get
```

### 3. Install Node.js dependencies
```bash
npm install
```

### 4. Start the backend server
```bash
npm start
```

The server will start on `http://localhost:3000`

### 5. Run the Flutter app

#### For iOS:
```bash
flutter run -d "iPhone 16 Plus"  # or any available iOS simulator
```

#### For Android:
```bash
flutter run -d "Android Emulator"  # or any connected Android device
```

## Project Structure

```
skimpulse_app/
├── lib/
│   ├── main.dart              # Main Flutter application
│   └── article_screen.dart    # Article detail screen (future)
├── server.js                  # Backend API server
├── package.json               # Node.js dependencies
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # This file
```

## API Endpoints

- `GET /api/skimfeed` - Fetches trending articles from Skimfeed.com
- `GET /health` - Health check endpoint

## Development

### Backend Server
The Node.js server scrapes Skimfeed.com and provides a clean API for the Flutter app. It uses:
- Express.js for the web server
- Axios for HTTP requests
- Cheerio for HTML parsing
- CORS for cross-origin requests

### Flutter App
The Flutter app is built with:
- Material Design 3
- HTTP package for API calls
- URL Launcher for opening external links
- Platform-aware networking (different URLs for iOS/Android)

## Troubleshooting

### iOS Build Issues
If you encounter Swift compiler errors with `url_launcher`:
1. Clean the project: `flutter clean`
2. Remove iOS pods: `cd ios && rm -rf Pods Podfile.lock && cd ..`
3. Reinstall pods: `cd ios && pod install && cd ..`
4. Try running again: `flutter run -d "iPhone 16 Plus"`

### Network Issues
- Ensure the backend server is running on port 3000
- Check that your device/simulator can access `localhost:3000`
- For Android emulator, the app uses `10.0.2.2:3000`
- For iOS simulator, the app uses `localhost:3000`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both iOS and Android
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- [Skimfeed.com](https://skimfeed.com/) for providing the content
- Flutter team for the amazing framework
- The open-source community for the packages used

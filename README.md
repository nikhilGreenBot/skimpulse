# Skimpulse

A Flutter app that displays trending tech articles from skimfeed.com in a clean, native interface.

## Features

- 📰 Fetches latest tech articles from skimfeed.com
- 📱 Native Flutter UI with Material Design 3
- 🌐 In-app article reading with WebView
- 🔄 Pull-to-refresh functionality
- 📊 Clean article list with numbering

## Architecture

This app uses a client-server architecture:
- **Flutter App**: Native mobile interface
- **Node.js Server**: API server that fetches and parses skimfeed.com

## Setup Instructions

### 1. Flutter App Setup

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 2. Server Setup

#### For Development (Local)
```bash
# Install Node.js dependencies
npm install

# Start the server
node server.js
```

The server will run on `http://localhost:3000`

#### For Production (Deployment)

The server needs to be deployed to a cloud service. Here are some options:

**Option 1: Heroku (Free tier available)**
```bash
# Install Heroku CLI
# Create a new Heroku app
heroku create your-skimpulse-server

# Deploy
git push heroku main
```

**Option 2: Railway (Free tier available)**
- Connect your GitHub repo
- Railway will auto-deploy from your main branch

**Option 3: Render (Free tier available)**
- Connect your GitHub repo
- Set build command: `npm install`
- Set start command: `node server.js`

**Option 4: Vercel (Free tier available)**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### 3. Update App Configuration

After deploying the server, update the API URL in `lib/main.dart`:

```dart
// Replace this line:
Uri.parse('http://10.0.2.2:3000/api/skimfeed')

// With your deployed server URL:
Uri.parse('https://your-server-url.herokuapp.com/api/skimfeed')
```

## Project Structure

```
skimpulse_app/
├── lib/
│   ├── main.dart          # Main app screen
│   └── article_screen.dart # Article reading screen
├── server.js              # Node.js API server
├── package.json           # Node.js dependencies
└── pubspec.yaml          # Flutter dependencies
```

## API Endpoints

- `GET /api/skimfeed` - Returns latest articles from skimfeed.com
- `GET /health` - Health check endpoint

## Dependencies

### Flutter
- `http` - For API calls
- `webview_flutter` - For in-app article reading
- `url_launcher` - For external browser opening

### Node.js
- `express` - Web framework
- `axios` - HTTP client
- `cheerio` - HTML parsing
- `cors` - Cross-origin resource sharing

## License

MIT License - see LICENSE file for details.

## Credits

- Data source: [skimfeed.com](https://skimfeed.com)
- Built with Flutter and Node.js

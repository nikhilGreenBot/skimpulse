#!/bin/bash

# Script to update Flutter app with Render.com API URL
# Usage: ./update_render_url.sh "https://your-app-name.onrender.com"

if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide your Render.com API URL"
    echo "Usage: $0 \"https://your-app-name.onrender.com\""
    exit 1
fi

API_URL=$1

# Remove trailing slash if present
API_URL=${API_URL%/}

echo "🔧 Updating Flutter app with API URL: $API_URL"

# Update the main.dart file with production API URL
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|const String? productionApiUrl = String.fromEnvironment('API_URL');|const String? productionApiUrl = '$API_URL';|g" lib/main.dart
else
    # Linux
    sed -i "s|const String? productionApiUrl = String.fromEnvironment('API_URL');|const String? productionApiUrl = '$API_URL';|g" lib/main.dart
fi

echo "✅ Updated lib/main.dart with production API URL"

# Test the API endpoint
echo "🧪 Testing API endpoint..."
if curl -f -s "$API_URL/health" > /dev/null; then
    echo "✅ API health check passed!"
    echo "🚀 Your Flutter app is now configured to use the production API"
    echo ""
    echo "Next steps:"
    echo "1. Test your Flutter app: flutter run"
    echo "2. Build for release: flutter build apk (Android) or flutter build ios (iOS)"
    echo "3. Deploy to app stores!"
else
    echo "❌ API health check failed. Please verify your server is deployed correctly."
    echo "Expected URL: $API_URL/health"
fi

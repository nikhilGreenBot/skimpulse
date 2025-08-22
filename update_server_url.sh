#!/bin/bash

# Script to update the server URL in Flutter app
# Usage: ./update_server_url.sh "https://your-server-url.railway.app"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <server_url>"
    echo "Example: $0 https://skimpulse-api.railway.app"
    exit 1
fi

SERVER_URL=$1

# Remove trailing slash if present
SERVER_URL=${SERVER_URL%/}

echo "🔄 Updating server URL to: $SERVER_URL"

# Update main.dart
if [ -f "lib/main.dart" ]; then
    # Create backup
    cp lib/main.dart lib/main.dart.backup
    
    # Replace localhost:3000 with the new server URL
    sed -i '' "s|http://localhost:3000|$SERVER_URL|g" lib/main.dart
    
    echo "✅ Updated lib/main.dart"
else
    echo "❌ lib/main.dart not found"
fi

echo ""
echo "🎉 Server URL updated successfully!"
echo "📱 Your Flutter app will now connect to: $SERVER_URL"
echo ""
echo "💡 Don't forget to:"
echo "   1. Test your app"
echo "   2. Commit the changes: git add . && git commit -m 'Update server URL'"
echo "   3. Push: git push"

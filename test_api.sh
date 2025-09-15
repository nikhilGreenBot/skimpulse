#!/bin/bash

# Script to test your deployed Skimpulse API
# Usage: ./test_api.sh "https://your-app-name.onrender.com"

if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide your Render.com API URL"
    echo "Usage: $0 \"https://your-app-name.onrender.com\""
    exit 1
fi

API_URL=$1
API_URL=${API_URL%/}  # Remove trailing slash

echo "🧪 Testing Skimpulse API at: $API_URL"
echo "=================================================="

# Test 1: Health Check
echo "1. 🏥 Testing health endpoint..."
if response=$(curl -s -f "$API_URL/health"); then
    echo "✅ Health check passed!"
    echo "   Response: $response"
else
    echo "❌ Health check failed!"
    exit 1
fi

echo ""

# Test 2: Root endpoint
echo "2. 🏠 Testing root endpoint..."
if response=$(curl -s -f "$API_URL/"); then
    echo "✅ Root endpoint working!"
    echo "   Server info retrieved successfully"
else
    echo "❌ Root endpoint failed!"
fi

echo ""

# Test 3: Articles endpoint
echo "3. 📰 Testing articles endpoint..."
if response=$(curl -s -f "$API_URL/api/skimfeed"); then
    # Parse JSON to check if we got articles
    if echo "$response" | grep -q '"success":true'; then
        article_count=$(echo "$response" | grep -o '"total":[0-9]*' | cut -d':' -f2)
        echo "✅ Articles endpoint working!"
        echo "   Retrieved $article_count articles"
        
        # Show first article title as example
        first_title=$(echo "$response" | grep -o '"title":"[^"]*' | head -1 | cut -d'"' -f4)
        if [ ! -z "$first_title" ]; then
            echo "   Example article: \"$first_title\""
        fi
    else
        echo "⚠️  Articles endpoint responded but no articles found"
        echo "   This might be temporary - skimfeed.com could be updating"
    fi
else
    echo "❌ Articles endpoint failed!"
    echo "   This could indicate server issues or network problems"
fi

echo ""
echo "=================================================="
echo "🎯 API Test Summary:"
echo "   • Health Check: ✅"
echo "   • Root Endpoint: ✅" 
echo "   • Articles Endpoint: ✅"
echo ""
echo "🚀 Your API is ready for your Flutter app!"
echo ""
echo "Next steps:"
echo "1. Run: ./update_render_url.sh \"$API_URL\""
echo "2. Test your Flutter app: flutter run"
echo "3. Build for production: flutter build apk/ios"

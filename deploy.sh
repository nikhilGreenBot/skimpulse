#!/bin/bash

# Skimpulse Server Deployment Script
# This script helps deploy the Node.js server to various cloud platforms

echo "🚀 Skimpulse Server Deployment Script"
echo "====================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Test the server locally
echo "🧪 Testing server locally..."
node server.js &
SERVER_PID=$!

# Wait a moment for server to start
sleep 3

# Test the health endpoint
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Server is running and responding"
    kill $SERVER_PID
else
    echo "❌ Server failed to start or respond"
    kill $SERVER_PID
    exit 1
fi

echo ""
echo "🎉 Local testing completed successfully!"
echo ""
echo "📋 Deployment Options:"
echo "1. Heroku: heroku create && git push heroku main"
echo "2. Railway: Connect GitHub repo to Railway"
echo "3. Render: Connect GitHub repo to Render"
echo "4. Vercel: vercel"
echo "5. DigitalOcean App Platform: Use their dashboard"
echo ""
echo "💡 Remember to update the API URL in your Flutter app after deployment!"

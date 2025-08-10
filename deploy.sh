#!/bin/bash

# Skimpulse Server Deployment Script
# This script helps deploy the Node.js server to various platforms

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

# Test the API
curl -s http://localhost:3000/health > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Server is working locally"
else
    echo "❌ Server test failed"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Stop the test server
kill $SERVER_PID 2>/dev/null

echo ""
echo "🎉 Server is ready for deployment!"
echo ""
echo "📋 Next steps:"
echo "1. Choose a deployment platform (Heroku, Railway, Render, Vercel)"
echo "2. Follow the deployment instructions in README.md"
echo "3. Update the API URL in lib/main.dart with your deployed server URL"
echo ""
echo "💡 Quick deployment options:"
echo "   • Heroku: heroku create && git push heroku main"
echo "   • Railway: Connect GitHub repo to Railway"
echo "   • Render: Connect GitHub repo to Render"
echo "   • Vercel: npm i -g vercel && vercel"

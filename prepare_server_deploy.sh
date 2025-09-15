#!/bin/bash

# Script to prepare server files for deployment
# This creates a clean server directory for Railway deployment

echo "🚀 Preparing server files for deployment..."

# Create a temporary deployment directory
DEPLOY_DIR="server-deploy"
mkdir -p $DEPLOY_DIR

# Copy server files
cp server/server.js $DEPLOY_DIR/
cp server/package.json $DEPLOY_DIR/
cp server/package-lock.json $DEPLOY_DIR/
cp server/README.md $DEPLOY_DIR/

echo "✅ Server files prepared in: $DEPLOY_DIR"
echo ""
echo "📋 Next steps:"
echo "1. Go to Railway.app"
echo "2. Create new project"
echo "3. Upload the $DEPLOY_DIR folder"
echo "4. Or use: 'Deploy from GitHub' with root directory: /server"
echo ""
echo "💡 If Railway still has issues, you can:"
echo "   - Create a new GitHub repo with just the server files"
echo "   - Deploy that repo to Railway"
echo "   - Use the URL in your Flutter app"

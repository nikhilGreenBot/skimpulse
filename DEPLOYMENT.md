# Skimpulse Server Deployment Guide

## Option 1: Deploy to Railway (Recommended - Free)

### Step 1: Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with your GitHub account
3. Create a new project

### Step 2: Deploy Your Server
1. In Railway dashboard, click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your `skimpulse_app` repository
4. Railway will automatically detect it's a Node.js app
5. Set the root directory to `/` (root of your project)
6. Click "Deploy"

### Step 3: Get Your Server URL
1. Once deployed, Railway will give you a URL like: `https://your-app-name.railway.app`
2. Copy this URL - you'll need it for your Flutter app

### Step 4: Update Flutter App
Replace `localhost:3000` in your Flutter app with your Railway URL.

## Option 2: Deploy to Render (Alternative - Free)

### Step 1: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with your GitHub account

### Step 2: Deploy Your Server
1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Configure:
   - **Name**: `skimpulse-api`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. Click "Create Web Service"

### Step 3: Get Your Server URL
1. Render will provide a URL like: `https://your-app-name.onrender.com`
2. Use this URL in your Flutter app

## Option 3: Deploy to Heroku (Paid)

### Step 1: Install Heroku CLI
```bash
# macOS
brew install heroku/brew/heroku

# Or download from https://devcenter.heroku.com/articles/heroku-cli
```

### Step 2: Deploy
```bash
# Login to Heroku
heroku login

# Create Heroku app
heroku create your-skimpulse-api

# Deploy
git push heroku main

# Get your URL
heroku info
```

## Testing Your Deployed Server

Once deployed, test your server:

```bash
# Test health endpoint
curl https://your-server-url.railway.app/health

# Test articles endpoint
curl https://your-server-url.railway.app/api/skimfeed
```

## Environment Variables (Optional)

You can set these in your deployment platform:

- `NODE_ENV=production`
- `PORT=3000` (usually auto-set by platform)

## Troubleshooting

### Common Issues:
1. **Build fails**: Make sure `package.json` has correct dependencies
2. **Port issues**: Server should use `process.env.PORT || 3000`
3. **CORS errors**: Server already has CORS enabled
4. **Timeout errors**: Added 10-second timeout to axios requests

### Logs:
- Railway: View logs in the Railway dashboard
- Render: View logs in the Render dashboard
- Heroku: `heroku logs --tail`

## Cost Comparison

| Platform | Free Tier | Paid Plans |
|----------|-----------|------------|
| Railway  | $5/month free | $20/month |
| Render   | Free (sleeps after 15min) | $7/month |
| Heroku   | Discontinued | $7/month |

**Recommendation**: Start with Railway for the best free experience!

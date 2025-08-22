# 🚀 Deploy Skimpulse to Render.com

This guide will help you deploy your Flutter app's API server to Render.com so your mobile app can fetch data from anywhere.

## 📋 Prerequisites

- [x] GitHub account connected to Render.com
- [x] Your Flutter app repository on GitHub
- [x] Render.com account (free tier available)

## 🎯 Step-by-Step Deployment

### Step 1: Prepare Your Repository

Your repository is already configured with:
- ✅ `render.yaml` configuration file
- ✅ Clean server structure in `/server` directory
- ✅ Production-ready Node.js server

### Step 2: Deploy to Render.com

1. **Go to [Render.com](https://render.com)** and sign in
2. **Click "New +" → "Web Service"**
3. **Connect your GitHub repository**
4. **Configure the service:**
   - **Name**: `skimpulse-api` (or your preferred name)
   - **Root Directory**: `server` (important!)
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free (or paid if you prefer)

5. **Click "Create Web Service"**

### Step 3: Wait for Deployment

- Render will automatically build and deploy your server
- This usually takes 2-5 minutes
- Watch the build logs for any errors

### Step 4: Get Your API URL

Once deployed, Render will give you a URL like:
```
https://skimpulse-api-xyz123.onrender.com
```

Copy this URL - you'll need it for your Flutter app.

### Step 5: Update Your Flutter App

Run this script to update your Flutter app with the production API URL:

```bash
./update_render_url.sh "https://your-app-name.onrender.com"
```

Replace `your-app-name.onrender.com` with your actual Render URL.

### Step 6: Test Your Deployment

Test your API endpoints:

```bash
# Test health check
curl https://your-app-name.onrender.com/health

# Test articles endpoint
curl https://your-app-name.onrender.com/api/skimfeed
```

You should see JSON responses from both endpoints.

### Step 7: Test Your Flutter App

```bash
# Test on mobile device/simulator
flutter run

# Build for release
flutter build apk        # Android
flutter build ios        # iOS
```

## 🎉 You're Done!

Your Flutter app can now fetch articles from anywhere in the world through your Render.com API server.

## 📱 Next Steps

1. **Test thoroughly** on different devices
2. **Deploy to app stores**:
   - Google Play Store (Android)
   - Apple App Store (iOS)
3. **Monitor your API** through Render's dashboard

## 🔧 Troubleshooting

### Common Issues:

**Build fails on Render:**
- Ensure Root Directory is set to `server`
- Check that `package.json` exists in the server directory
- Review build logs for specific errors

**API returns 404:**
- Verify your Render URL is correct
- Check that the service is running (green status in Render dashboard)
- Test the `/health` endpoint first

**Flutter app can't connect:**
- Ensure you ran the `update_render_url.sh` script
- Check your internet connection
- Verify the API URL in your Flutter app

**CORS errors:**
- The server already has CORS enabled
- If issues persist, check the server logs in Render dashboard

### Getting Help:

1. Check Render dashboard logs
2. Test API endpoints manually with `curl`
3. Verify Flutter app configuration

## 💰 Render.com Free Tier

- ✅ **Free tier available**
- ✅ **750 hours/month** (enough for most apps)
- ✅ **Automatic SSL certificates**
- ✅ **GitHub integration**
- ⚠️ **Sleeps after 15 minutes of inactivity** (first request may be slow)

For production apps with high traffic, consider upgrading to a paid plan.

## 🔄 Future Updates

To update your server:
1. Push changes to your GitHub repository
2. Render will automatically redeploy
3. No need to update your Flutter app unless API structure changes

---

**🎯 Your Flutter app is now ready for global deployment!**

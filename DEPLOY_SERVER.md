# Deploy API Server to Railway

## Quick Deploy Method (No Separate Repo Needed)

### Step 1: Create Railway Project
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Click "New Project"

### Step 2: Deploy from GitHub
1. Select "Deploy from GitHub repo"
2. Choose your `skimpulse_app` repository
3. **Important**: Set "Root Directory" to `/server`
4. Click "Deploy"

### Step 3: Get Your Server URL
1. Railway will give you a URL like: `https://your-app-name.railway.app`
2. Copy this URL

### Step 4: Update Flutter App
Run this command to update your Flutter app with the new server URL:

```bash
./update_server_url.sh "https://your-app-name.railway.app"
```

## Alternative: Manual Deployment

If Railway still has issues, you can:

1. **Copy server files** to a new directory
2. **Create a new Railway project** from that directory
3. **Deploy the server separately**

## Testing

Once deployed, test your server:

```bash
# Test health endpoint
curl https://your-server-url.railway.app/health

# Test articles endpoint  
curl https://your-server-url.railway.app/api/skimfeed
```

## Your Flutter App

Your Flutter app remains unchanged and ready for:
- ✅ **App Store deployment**
- ✅ **Google Play Store deployment**
- ✅ **All Flutter features intact**

The server is just an API that your Flutter app connects to.

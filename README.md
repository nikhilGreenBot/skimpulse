# Skimpulse API Server

This is the API server for the Skimpulse Flutter app. It fetches and parses articles from skimfeed.com.

## Quick Deploy to Railway

### Option 1: Deploy from this repo
1. Go to [railway.app](https://railway.app)
2. Create new project
3. Select "Deploy from GitHub repo"
4. Choose this repository
5. Deploy (no special settings needed)

### Option 2: Manual upload
1. Go to [railway.app](https://railway.app)
2. Create new project
3. Choose "Upload from your computer"
4. Upload this folder
5. Deploy

## API Endpoints

- `GET /` - Server info
- `GET /health` - Health check
- `GET /api/skimfeed` - Get articles from skimfeed.com

## Environment Variables

- `PORT` - Server port (auto-set by Railway)
- `NODE_ENV` - Environment (development/production)

## Testing

Once deployed, test your server:

```bash
# Test health endpoint
curl https://your-server-url.railway.app/health

# Test articles endpoint
curl https://your-server-url.railway.app/api/skimfeed
```

## Local Development

```bash
# Install dependencies
npm install

# Start the server
npm start

# For development
npm run dev
```

## For Flutter App

After deployment, update your Flutter app with the server URL:

```bash
# In your Flutter project
./update_server_url.sh "https://your-server-url.railway.app"
```

# Skimpulse API Server

This is the API server for the Skimpulse Flutter app. It fetches and parses articles from skimfeed.com.

## Quick Start

```bash
# Install dependencies
npm install

# Start the server
npm start

# For development
npm run dev
```

## API Endpoints

- `GET /` - Server info
- `GET /health` - Health check
- `GET /api/skimfeed` - Get articles from skimfeed.com

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)

## Deployment

This server is designed to be deployed to Railway, Render, or Heroku.

See the main project's `DEPLOYMENT.md` for detailed instructions.

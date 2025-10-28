# Skimpulse - Tech News Aggregator

**Skimpulse** is a modern, elegant mobile application that brings you the latest technology news and articles in a beautiful, easy-to-read format. Stay informed about the tech world with curated content from top sources, all in one convenient app.

## What This App Does

- 📱 **Beautiful Interface**: Clean, modern design with smooth animations and intuitive navigation
- 🔥 **Hot Tech News**: Get the latest trending technology articles and news
- 🎨 **Multiple Themes**: Choose from Light, Dark, or Colorful themes to match your preference
- 🔄 **Smart Sorting**: Sort articles by date, alphabetical order, or ranking
- ⚡ **Fast Loading**: Optimized performance with quick article loading
- 🌐 **In-App Reading**: Read articles directly within the app or open in external browser
- 📱 **Cross-Platform**: Available on iOS, Android, and Web

## Features

- Real-time tech news aggregation
- Beautiful gradient backgrounds and glassmorphism effects
- Smooth animations and transitions
- Offline error handling with retry functionality
- Responsive design for all screen sizes
- Ad integration for sustainable development

## Disclaimer & Credits

**Important**: This application aggregates and displays content from various technology news sources. All article content, titles, and links are sourced from external websites and are the property of their respective owners.

**Credit**: This app utilizes data from [skimfeed.com](https://skimfeed.com) for news aggregation. I, Nikhil am  grateful to skimfeed.com for providing access to their curated technology news feed.

**Content Disclaimer**: The views and opinions expressed in the linked articles are those of the original authors and do not necessarily reflect the views of Skimpulse or its developers.

## Trademark & Legal

- **Skimpulse** is a trademark of the application developer Nikhil
- This application is provided "as is" without warranty of any kind
- Users are responsible for their own use of external links and content
- The app respects the terms of service of all linked websites
- No copyright infringement is intended; all content belongs to its original creators

## Technical Information

This repository contains both the Flutter mobile application and the Node.js API server that powers the news aggregation.

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

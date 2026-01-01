const express = require('express');
const axios = require('axios');
const cheerio = require('cheerio');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for Flutter app
app.use(cors());
app.use(express.json());

// ============================================
// RATE LIMITING - Prevent abuse
// ============================================
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again after a minute.',
    retryAfter: 60
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  // Skip rate limiting for health checks
  skip: (req) => req.path === '/health'
});

// Apply rate limiting to API endpoints
app.use('/api/', apiLimiter);

// ============================================
// IN-MEMORY CACHE FOR ARTICLES
// ============================================
const articleCache = {
  data: null,
  timestamp: null,
  ttl: 5 * 60 * 1000, // 5 minutes cache TTL (configurable via env)
  isRefreshing: false, // Prevent concurrent refresh attempts
};

// Allow cache TTL to be configured via environment variable
if (process.env.CACHE_TTL_MINUTES) {
  articleCache.ttl = parseInt(process.env.CACHE_TTL_MINUTES) * 60 * 1000;
}

/**
 * Check if cache is valid (not expired)
 */
function isCacheValid() {
  if (!articleCache.data || !articleCache.timestamp) {
    return false;
  }
  const age = Date.now() - articleCache.timestamp;
  return age < articleCache.ttl;
}

/**
 * Fetch articles from skimfeed.com
 * This is the expensive operation that we want to cache
 */
async function fetchArticlesFromSkimfeed() {
  console.log('🔍 Fetching skimfeed.com...');
  
  const response = await axios.get('https://skimfeed.com/', {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    },
    timeout: 10000 // 10 second timeout
  });

  const $ = cheerio.load(response.data);
  const articles = [];

  // Look for article links that start with r.php (these are the actual articles)
  const links = $('a[href^="r.php"]');
  
  console.log(`Found ${links.length} article links`);
  
  links.each((index, element) => {
    const $link = $(element);
    const title = $link.attr('title') || $link.text().trim();
    const url = $link.attr('href');
    
    // Filter for actual articles with substantial titles
    if (title && url && 
        title.length > 10 && 
        !title.includes('Home') &&
        !title.includes('Twitter') &&
        !title.includes('Weather') &&
        !title.includes('Tech News') &&
        !title.includes('Gaming') &&
        !title.includes('Science') &&
        !title.includes('Design') &&
        !title.includes('Politics') &&
        !title.includes('Comics') &&
        !title.includes('Football') &&
        !title.includes('Investing') &&
        !title.includes('MMA') &&
        !title.includes('Mobile News') &&
        !title.includes('Reddit') &&
        !title.includes('Trend') &&
        !title.includes('Watches') &&
        !title.includes('Youtube') &&
        !title.includes('Custom') &&
        !title.includes('Latest') &&
        !title.includes('Hacker News') &&
        !title.includes('AnandTech') &&
        !title.includes('Gizmag') &&
        !title.includes('MakeUseOf') &&
        !title.includes('Slashdot') &&
        !title.includes('The Verge') &&
        !title.includes('Wired') &&
        !title.includes('Apple Insider') &&
        !title.includes('World Holidays') &&
        !title.includes('CBC Hourly News') &&
        !title.includes('Google Plus') &&
        !title.includes('Facebook') &&
        !title.includes('Digg') &&
        !title.includes('LinkedIn') &&
        !title.includes('Blog') &&
        !title.includes('mins') &&
        !title.includes('©©') &&
        !title.includes('+') &&
        !title.includes('Fast Company') &&
        !title.includes('Next Big Future') &&
        !title.includes('ArsTechnica') &&
        !title.includes('High Scalability') &&
        !title.includes('The Tech Block') &&
        !title.includes('Continuations') &&
        !title.includes('Packet Storm Sec') &&
        !title.includes('How to Geek') &&
        !title.includes('ReadWriteWeb') &&
        !title.includes('Copyblogger') &&
        !title.includes('BBC Technology') &&
        !title.includes('The Next Web') &&
        !title.includes('Venture Beat') &&
        !title.includes('Extreme Tech') &&
        !title.includes('Cult of Mac') &&
        !title.includes('Smashing Mag') &&
        !title.includes('FastCoExist') &&
        !title.includes('Tech in Asia')) {
      
      // Convert relative URL to absolute URL
      const fullUrl = url.startsWith('http') ? url : `https://skimfeed.com/${url}`;
      
      articles.push({
        title: title,
        url: fullUrl
      });
      
      console.log(`📰 Added: "${title}" -> ${fullUrl}`);
    }
  });

  if (articles.length === 0) {
    throw new Error('No articles found');
  }

  // Limit to 20 articles
  const limitedArticles = articles.slice(0, 20);
  
  console.log(`📊 Processed ${limitedArticles.length} articles`);
  
  return {
    success: true,
    articles: limitedArticles,
    total: limitedArticles.length
  };
}

// Route to get skimfeed.com content
app.get('/api/skimfeed', async (req, res) => {
  try {
    // ============================================
    // CACHE CHECK - Serve from cache if valid
    // ============================================
    if (isCacheValid()) {
      console.log('📦 Serving from cache');
      return res.json(articleCache.data);
    }

    // ============================================
    // CACHE MISS - Need to fetch fresh data
    // ============================================
    
    // If cache is being refreshed by another request, serve stale cache if available
    if (articleCache.isRefreshing && articleCache.data) {
      console.log('⏳ Cache refresh in progress, serving stale cache');
      return res.json(articleCache.data);
    }

    // Set refreshing flag to prevent concurrent refreshes
    articleCache.isRefreshing = true;

    try {
      // Fetch fresh data
      const freshData = await fetchArticlesFromSkimfeed();
      
      // Update cache
      articleCache.data = freshData;
      articleCache.timestamp = Date.now();
      articleCache.isRefreshing = false;
      
      console.log('✅ Cache updated with fresh data');
      res.json(freshData);
      
    } catch (error) {
      articleCache.isRefreshing = false;
      
      // If we have stale cache, serve it instead of erroring
      if (articleCache.data) {
        console.log('⚠️ Error fetching fresh data, serving stale cache');
        return res.json(articleCache.data);
      }
      
      // No cache available, return error
      throw error;
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    res.status(500).json({ 
      error: 'Failed to fetch skimfeed.com',
      details: error.message 
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  const cacheStatus = articleCache.data ? {
    cached: true,
    cacheAgeSeconds: Math.floor((Date.now() - articleCache.timestamp) / 1000),
    isValid: isCacheValid(),
    ttlSeconds: Math.floor(articleCache.ttl / 1000)
  } : { cached: false };
  
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    cache: cacheStatus
  });
});

// Version check endpoint for forced updates
app.get('/api/version', (req, res) => {
  // Current app version from pubspec.yaml: 1.0.0+1
  // Format: "major.minor.patch+build"
  const currentAppVersion = '1.0.0'; // Update this when you release new versions
  
  // Minimum required version (force update if below this)
  const minimumVersion = process.env.MINIMUM_APP_VERSION || '1.0.0';
  
  // Latest available version
  const latestVersion = process.env.LATEST_APP_VERSION || '1.0.0';
  
  // Whether to force update (set via environment variable)
  const forceUpdate = process.env.FORCE_UPDATE === 'true' || false;
  
  // Update URLs (set these to your app store URLs)
  const updateUrl = process.env.UPDATE_URL || null;
  
  // Custom update message
  const updateMessage = process.env.UPDATE_MESSAGE || 
    'A new version of Skimpulse is available. Please update to continue using the app.';
  
  res.json({
    currentVersion: currentAppVersion,
    minimumVersion: minimumVersion,
    latestVersion: latestVersion,
    forceUpdate: forceUpdate,
    updateUrl: updateUrl,
    updateMessage: updateMessage,
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Skimpulse API Server',
    endpoints: {
      articles: '/api/skimfeed',
      health: '/health'
    },
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API endpoint: http://localhost:${PORT}/api/skimfeed`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💾 Caching enabled: ${articleCache.ttl / 1000} seconds TTL`);
  console.log(`🛡️ Rate limiting: 100 requests per minute per IP`);
});

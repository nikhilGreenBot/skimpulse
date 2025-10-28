const express = require('express');
const axios = require('axios');
const cheerio = require('cheerio');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for Flutter app
app.use(cors());
app.use(express.json());

// Route to get skimfeed.com content
app.get('/api/skimfeed', async (req, res) => {
  try {
    console.log('🔍 Fetching skimfeed.com...');
    
    const response = await axios.get('https://skimfeed.com/', {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      },
      timeout: 15000 // 15 second timeout
    });

    const $ = cheerio.load(response.data);
    const articles = [];

    // Look specifically for the "WHAT'S HOT" section
    // The WHAT'S HOT section is in a div with class 'boxes' that contains a span with 'WHAT'S HOT' text
    const whatsHotSection = $('.boxes').filter(function() {
      return $(this).find('span.boxtitles h2 a.popurltitle').text().includes("WHAT'S HOT");
    });
    
    if (whatsHotSection.length === 0) {
      console.log('❌ WHAT\'S HOT section not found');
      return res.status(404).json({ error: 'WHAT\'S HOT section not found' });
    }

    // Look for article links within the WHAT'S HOT section
    const links = whatsHotSection.find('a[href^="r.php"]');
    
    console.log(`Found ${links.length} article links in WHAT'S HOT section`);
    
    links.each((index, element) => {
      const $link = $(element);
      const title = $link.attr('title') || $link.text().trim();
      const url = $link.attr('href');
      
      // Filter for actual articles with substantial titles
      if (title && url && 
          title.length > 10 && 
          !title.includes('©©') && // Filter out Hacker News discussion links
          !title.includes('+') &&  // Filter out site links
          title.trim() !== '') {
        
        // Convert relative URL to absolute URL
        const fullUrl = url.startsWith('http') ? url : `https://skimfeed.com/${url}`;
        
        articles.push({
          title: title,
          url: fullUrl,
          ranking: articles.length + 1 // Add ranking based on order
        });
        
        console.log(`📰 Added from WHAT'S HOT: "${title}" -> ${fullUrl}`);
      }
    });

    if (articles.length === 0) {
      console.log('❌ No articles found');
      return res.status(404).json({ error: 'No articles found' });
    }

    // Limit to 20 articles
    const limitedArticles = articles.slice(0, 20);
    
    console.log(`📊 Returning ${limitedArticles.length} articles`);
    
    res.json({
      success: true,
      articles: limitedArticles,
      total: limitedArticles.length
    });

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
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    nodeVersion: process.version
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
    version: '1.0.0',
    nodeVersion: process.version
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API endpoint: http://localhost:${PORT}/api/skimfeed`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📦 Node version: ${process.version}`);
});

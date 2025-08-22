const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// Serve static files from Flutter web build
app.use(express.static(path.join(__dirname, 'build/web')));

// Handle Flutter routing
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

app.listen(PORT, () => {
  console.log(`🚀 Flutter web app running on port ${PORT}`);
});

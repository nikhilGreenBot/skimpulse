// Feed source configuration similar to Skimfeed's custom page
class FeedSource {
  final int id;
  final String name;
  final String category;
  final String rssUrl;
  final String? description;

  const FeedSource({
    required this.id,
    required this.name,
    required this.category,
    required this.rssUrl,
    this.description,
  });
}

class FeedSources {
  static const List<FeedSource> sources = [
    // Tech
    FeedSource(id: 1, name: "The Verge", category: "Tech", rssUrl: "https://www.theverge.com/rss/index.xml"),
    FeedSource(id: 2, name: "Hacker News", category: "Tech", rssUrl: "https://hnrss.org/frontpage"),
    FeedSource(id: 3, name: "Lifehacker", category: "Tech", rssUrl: "https://lifehacker.com/rss"),
    FeedSource(id: 4, name: "Fast Company", category: "Tech", rssUrl: "https://www.fastcompany.com/technology/rss"),
    FeedSource(id: 5, name: "ArsTechnica", category: "Tech", rssUrl: "https://feeds.arstechnica.com/arstechnica/index/"),
    FeedSource(id: 6, name: "Engadget", category: "Tech", rssUrl: "https://www.engadget.com/rss.xml"),
    FeedSource(id: 7, name: "Techcrunch", category: "Tech", rssUrl: "https://techcrunch.com/feed/"),
    FeedSource(id: 8, name: "BBC Technology", category: "Tech", rssUrl: "http://feeds.bbci.co.uk/news/technology/rss.xml"),
    FeedSource(id: 9, name: "AnandTech", category: "Tech", rssUrl: "https://www.anandtech.com/rss/"),
    FeedSource(id: 12, name: "Slashdot", category: "Tech", rssUrl: "http://rss.slashdot.org/Slashdot/slashdot"),
    FeedSource(id: 13, name: "Smashing Mag", category: "Tech", rssUrl: "https://www.smashingmagazine.com/feed/"),
    FeedSource(id: 14, name: "ReadWriteWeb", category: "Tech", rssUrl: "https://readwrite.com/feed/"),
    FeedSource(id: 15, name: "Copyblogger", category: "Tech", rssUrl: "https://copyblogger.com/feed/"),
    FeedSource(id: 18, name: "BetaBeat", category: "Tech", rssUrl: "https://www.betabeat.com/feed/"),
    FeedSource(id: 19, name: "MakeUseOf", category: "Tech", rssUrl: "https://www.makeuseof.com/feed/"),
    FeedSource(id: 21, name: "The Next Web", category: "Tech", rssUrl: "https://thenextweb.com/feed/"),
    FeedSource(id: 22, name: "Digital Trends", category: "Tech", rssUrl: "https://www.digitaltrends.com/feed/"),
    FeedSource(id: 23, name: "High Scalability", category: "Tech", rssUrl: "http://highscalability.com/rss.xml"),
    FeedSource(id: 24, name: "Geek", category: "Tech", rssUrl: "https://www.geek.com/feed/"),
    FeedSource(id: 25, name: "The Tech Block", category: "Tech", rssUrl: "https://thetechblock.com/feed/"),
    FeedSource(id: 26, name: "Bit-Tech", category: "Tech", rssUrl: "https://www.bit-tech.net/rss/"),
    FeedSource(id: 27, name: "MedGadget", category: "Tech", rssUrl: "https://www.medgadget.com/feed/"),
    FeedSource(id: 29, name: "Next Big Future", category: "Tech", rssUrl: "https://www.nextbigfuture.com/feed"),
    FeedSource(id: 30, name: "Design", category: "Tech", rssUrl: "https://www.design-milk.com/feed/"),
    FeedSource(id: 31, name: "Gizmag", category: "Tech", rssUrl: "https://newatlas.com/feed/"),
    FeedSource(id: 32, name: "A VC", category: "Tech", rssUrl: "https://avc.com/feed/"),
    FeedSource(id: 33, name: "Continuations", category: "Tech", rssUrl: "https://continuations.com/feed/"),
    FeedSource(id: 34, name: "FastCoExist", category: "Tech", rssUrl: "https://www.fastcompany.com/social-impact/rss"),
    FeedSource(id: 35, name: "Extreme Tech", category: "Tech", rssUrl: "https://www.extremetech.com/feed"),
    FeedSource(id: 85, name: "Wired", category: "Tech", rssUrl: "https://www.wired.com/feed/rss"),
    FeedSource(id: 204, name: "Apple Insider", category: "Tech", rssUrl: "https://appleinsider.com/rss/news/"),
    FeedSource(id: 272, name: "Venture Beat", category: "Tech", rssUrl: "https://venturebeat.com/feed/"),
    FeedSource(id: 273, name: "Cult of Mac", category: "Tech", rssUrl: "https://www.cultofmac.com/feed/"),
    FeedSource(id: 282, name: "Tech in Asia", category: "Tech", rssUrl: "https://www.techinasia.com/feed"),
    FeedSource(id: 283, name: "QZ", category: "Tech", rssUrl: "https://qz.com/feed/"),
    FeedSource(id: 313, name: "How to Geek", category: "Tech", rssUrl: "https://www.howtogeek.com/feed/"),

    // News
    FeedSource(id: 128, name: "BBC World", category: "News", rssUrl: "http://feeds.bbci.co.uk/news/world/rss.xml"),
    FeedSource(id: 129, name: "CNN", category: "News", rssUrl: "http://rss.cnn.com/rss/edition.rss"),
    FeedSource(id: 130, name: "MSNBC", category: "News", rssUrl: "http://www.msnbc.com/rss"),
    FeedSource(id: 131, name: "Fox", category: "News", rssUrl: "http://feeds.foxnews.com/foxnews/latest"),
    FeedSource(id: 132, name: "ABC News", category: "News", rssUrl: "https://abcnews.go.com/abcnews/topstories"),
    FeedSource(id: 133, name: "Daily Mail", category: "News", rssUrl: "https://www.dailymail.co.uk/news/index.rss"),
    FeedSource(id: 134, name: "The Guardian", category: "News", rssUrl: "https://www.theguardian.com/world/rss"),
    FeedSource(id: 137, name: "The Times", category: "News", rssUrl: "https://www.thetimes.co.uk/rss"),
    FeedSource(id: 138, name: "WorldCrunch", category: "News", rssUrl: "https://worldcrunch.com/rss"),
    FeedSource(id: 139, name: "Japan Times", category: "News", rssUrl: "https://www.japantimes.co.jp/rss/news/"),
    FeedSource(id: 140, name: "The Australian", category: "News", rssUrl: "https://www.theaustralian.com.au/rss"),
    FeedSource(id: 141, name: "Moscow Times", category: "News", rssUrl: "https://www.themoscowtimes.com/rss"),
    FeedSource(id: 143, name: "Times of India", category: "News", rssUrl: "https://timesofindia.indiatimes.com/rssfeeds/296589292.cms"),
    FeedSource(id: 144, name: "Al Jazeera", category: "News", rssUrl: "https://www.aljazeera.com/xml/rss/all.xml"),
    FeedSource(id: 145, name: "Observer", category: "News", rssUrl: "https://observer.com/feed/"),
    FeedSource(id: 146, name: "Harpers", category: "News", rssUrl: "https://harpers.org/feed/"),
    FeedSource(id: 147, name: "Pro publica", category: "News", rssUrl: "https://www.propublica.org/feeds/propublica/main"),
    FeedSource(id: 205, name: "Business Insider India", category: "News", rssUrl: "https://www.businessinsider.in/rss_section_feeds/"),
    FeedSource(id: 271, name: "Business Insider", category: "News", rssUrl: "https://www.businessinsider.com/rss"),
    FeedSource(id: 288, name: "Reuters Tech", category: "News", rssUrl: "https://feeds.reuters.com/reuters/technologyNews"),
    FeedSource(id: 289, name: "NYT Tech", category: "News", rssUrl: "https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml"),
    FeedSource(id: 290, name: "NYT World", category: "News", rssUrl: "https://rss.nytimes.com/services/xml/rss/nyt/World.xml"),
    FeedSource(id: 291, name: "OZY", category: "News", rssUrl: "https://www.ozy.com/feed/"),

    // Gaming
    FeedSource(id: 92, name: "Kotaku", category: "Gaming", rssUrl: "https://kotaku.com/rss"),
    FeedSource(id: 93, name: "IGN", category: "Gaming", rssUrl: "https://www.ign.com/feeds/all.xml"),
    FeedSource(id: 94, name: "GiantBomb", category: "Gaming", rssUrl: "https://www.giantbomb.com/feeds/reviews/"),
    FeedSource(id: 95, name: "GamaSutra", category: "Gaming", rssUrl: "https://www.gamasutra.com/php-bin/rss.php"),
    FeedSource(id: 96, name: "RockPaperShotgun", category: "Gaming", rssUrl: "https://www.rockpapershotgun.com/feed/"),
    FeedSource(id: 97, name: "Destructoid", category: "Gaming", rssUrl: "https://www.destructoid.com/feed/"),
    FeedSource(id: 98, name: "VG247", category: "Gaming", rssUrl: "https://www.vg247.com/feed/"),
    FeedSource(id: 99, name: "Joystiq", category: "Gaming", rssUrl: "https://www.joystiq.com/feed/"),
    FeedSource(id: 100, name: "WiredGaming", category: "Gaming", rssUrl: "https://www.wired.com/feed/tag/gaming/rss"),
    FeedSource(id: 101, name: "Pocket Tactics", category: "Gaming", rssUrl: "https://www.pockettactics.com/feed/"),
    FeedSource(id: 102, name: "TouchArcade", category: "Gaming", rssUrl: "https://toucharcade.com/feed/"),
    FeedSource(id: 103, name: "Eurogamer", category: "Gaming", rssUrl: "https://www.eurogamer.net/feed"),
    FeedSource(id: 163, name: "Polygon", category: "Gaming", rssUrl: "https://www.polygon.com/rss/index.xml"),
    FeedSource(id: 177, name: "Reddit Truegaming", category: "Gaming", rssUrl: "https://www.reddit.com/r/truegaming.rss"),
    FeedSource(id: 180, name: "AllGamesBeta", category: "Gaming", rssUrl: "https://allgamesbeta.com/feed/"),
    FeedSource(id: 181, name: "CheapAssGamer", category: "Gaming", rssUrl: "https://www.cheapassgamer.com/feed/"),
    FeedSource(id: 182, name: "OnGamers", category: "Gaming", rssUrl: "https://www.ongamers.com/feed/"),
    FeedSource(id: 183, name: "Steam", category: "Gaming", rssUrl: "https://store.steampowered.com/feeds/news.xml"),
    FeedSource(id: 184, name: "Shoryuken", category: "Gaming", rssUrl: "https://shoryuken.com/feed/"),
    FeedSource(id: 185, name: "PCGamer", category: "Gaming", rssUrl: "https://www.pcgamer.com/rss/"),
    FeedSource(id: 187, name: "Gamespot", category: "Gaming", rssUrl: "https://www.gamespot.com/feeds/news/"),
    FeedSource(id: 188, name: "GameInformer", category: "Gaming", rssUrl: "https://www.gameinformer.com/feeds/news"),
    FeedSource(id: 189, name: "ArsGaming", category: "Gaming", rssUrl: "https://arstechnica.com/gaming/feed/"),
    FeedSource(id: 190, name: "GameTrailers", category: "Gaming", rssUrl: "https://www.gametrailers.com/feeds/reviews"),
    FeedSource(id: 191, name: "VideoGamer", category: "Gaming", rssUrl: "https://www.videogamer.com/rss/"),
    FeedSource(id: 192, name: "DualShockers", category: "Gaming", rssUrl: "https://www.dualshockers.com/feed/"),
    FeedSource(id: 193, name: "Siliconera", category: "Gaming", rssUrl: "https://www.siliconera.com/feed/"),
    FeedSource(id: 194, name: "ShackNews", category: "Gaming", rssUrl: "https://www.shacknews.com/rss.xml"),
    FeedSource(id: 195, name: "GamesRadar", category: "Gaming", rssUrl: "https://www.gamesradar.com/rss/"),
    FeedSource(id: 196, name: "USGamer", category: "Gaming", rssUrl: "https://www.usgamer.net/feed/"),
    FeedSource(id: 198, name: "Reddit Games", category: "Gaming", rssUrl: "https://www.reddit.com/r/games.rss"),
    FeedSource(id: 199, name: "Reddit GameDeals", category: "Gaming", rssUrl: "https://www.reddit.com/r/gamedeals.rss"),
    FeedSource(id: 200, name: "Reddit GamerNews", category: "Gaming", rssUrl: "https://www.reddit.com/r/gamernews.rss"),
    FeedSource(id: 201, name: "Reddit GameBundles", category: "Gaming", rssUrl: "https://www.reddit.com/r/gamebundles.rss"),

    // Science
    FeedSource(id: 37, name: "Flowing Data", category: "Science", rssUrl: "https://flowingdata.com/feed"),
    FeedSource(id: 38, name: "Makezine", category: "Science", rssUrl: "https://makezine.com/feed/"),
    FeedSource(id: 39, name: "Hack-a-day", category: "Science", rssUrl: "https://hackaday.com/feed/"),
    FeedSource(id: 40, name: "Ted Videos", category: "Science", rssUrl: "https://www.ted.com/talks/rss"),
    FeedSource(id: 41, name: "MIT Tech", category: "Science", rssUrl: "https://www.technologyreview.com/feed/"),
    FeedSource(id: 42, name: "Reddit Science", category: "Science", rssUrl: "https://www.reddit.com/r/science.rss"),
    FeedSource(id: 43, name: "Science Daily", category: "Science", rssUrl: "https://www.sciencedaily.com/rss/all.xml"),
    FeedSource(id: 44, name: "Discovery", category: "Science", rssUrl: "https://www.discovery.com/feeds"),
    FeedSource(id: 45, name: "Discover Magazine", category: "Science", rssUrl: "https://www.discovermagazine.com/feed"),
    FeedSource(id: 46, name: "PSFK", category: "Science", rssUrl: "https://www.psfk.com/feed"),
    FeedSource(id: 202, name: "DataTau", category: "Science", rssUrl: "https://www.datatau.com/rss"),
    FeedSource(id: 203, name: "DataIsBeautiful", category: "Science", rssUrl: "https://www.reddit.com/r/dataisbeautiful.rss"),
    FeedSource(id: 295, name: "PhysOrg", category: "Science", rssUrl: "https://phys.org/rss-feed/"),
    FeedSource(id: 297, name: "RoboHub", category: "Science", rssUrl: "https://robohub.org/feed/"),
    FeedSource(id: 298, name: "Robotics BizRev", category: "Science", rssUrl: "https://www.roboticsbusinessreview.com/feed/"),
    FeedSource(id: 299, name: "Robotiq", category: "Science", rssUrl: "https://blog.robotiq.com/feed"),
    FeedSource(id: 300, name: "IEEE Robotics", category: "Science", rssUrl: "https://spectrum.ieee.org/rss/fulltext"),
    FeedSource(id: 301, name: "Eureka Alert", category: "Science", rssUrl: "https://www.eurekalert.org/rss/"),
    FeedSource(id: 302, name: "Advanced Science", category: "Science", rssUrl: "https://onlinelibrary.wiley.com/rss/journal/21983844"),

    // Reddit
    FeedSource(id: 166, name: "R All", category: "Reddit", rssUrl: "https://www.reddit.com/r/all.rss"),
    FeedSource(id: 167, name: "R Askreddit", category: "Reddit", rssUrl: "https://www.reddit.com/r/AskReddit.rss"),
    FeedSource(id: 168, name: "R Worldnews", category: "Reddit", rssUrl: "https://www.reddit.com/r/worldnews.rss"),
    FeedSource(id: 169, name: "R Iama", category: "Reddit", rssUrl: "https://www.reddit.com/r/IAmA.rss"),
    FeedSource(id: 170, name: "R Movies", category: "Reddit", rssUrl: "https://www.reddit.com/r/movies.rss"),
    FeedSource(id: 171, name: "R Music", category: "Reddit", rssUrl: "https://www.reddit.com/r/Music.rss"),
    FeedSource(id: 172, name: "R Technology", category: "Reddit", rssUrl: "https://www.reddit.com/r/technology.rss"),
    FeedSource(id: 173, name: "R Bestof", category: "Reddit", rssUrl: "https://www.reddit.com/r/bestof.rss"),
    FeedSource(id: 174, name: "R News", category: "Reddit", rssUrl: "https://www.reddit.com/r/news.rss"),
    FeedSource(id: 175, name: "R Askscience", category: "Reddit", rssUrl: "https://www.reddit.com/r/askscience.rss"),
    FeedSource(id: 176, name: "R Explainlikeimfive", category: "Reddit", rssUrl: "https://www.reddit.com/r/explainlikeimfive.rss"),
    FeedSource(id: 261, name: "Futurology", category: "Reddit", rssUrl: "https://www.reddit.com/r/Futurology.rss"),

    // Aggregators
    FeedSource(id: 75, name: "Reddit", category: "Agg", rssUrl: "https://www.reddit.com/r/all.rss"),
    FeedSource(id: 76, name: "Digg", category: "Agg", rssUrl: "https://digg.com/rss.xml"),
    FeedSource(id: 77, name: "Buzzfeed", category: "Agg", rssUrl: "https://www.buzzfeed.com/index.xml"),
    FeedSource(id: 78, name: "Metafilter", category: "Agg", rssUrl: "https://www.metafilter.com/feeds/"),
    FeedSource(id: 80, name: "TheOnion", category: "Agg", rssUrl: "https://www.theonion.com/rss"),
    FeedSource(id: 81, name: "BoingBoing", category: "Agg", rssUrl: "https://boingboing.net/feed"),
    FeedSource(id: 82, name: "Weird News", category: "Agg", rssUrl: "https://www.weirdnews.com/feed/"),
    FeedSource(id: 83, name: "Fark", category: "Agg", rssUrl: "https://www.fark.com/rss/"),
    FeedSource(id: 84, name: "Mashable", category: "Agg", rssUrl: "https://mashable.com/feeds/rss/all"),
    FeedSource(id: 86, name: "ClientsFromHell", category: "Agg", rssUrl: "https://clientsfromhell.net/feed/"),
    FeedSource(id: 87, name: "Cracked", category: "Agg", rssUrl: "https://www.cracked.com/feed"),
    FeedSource(id: 88, name: "The Chive", category: "Agg", rssUrl: "https://thechive.com/feed/"),
    FeedSource(id: 89, name: "How Stuff Works", category: "Agg", rssUrl: "https://www.howstuffworks.com/rss"),
    FeedSource(id: 90, name: "ITOTD", category: "Agg", rssUrl: "https://www.itotd.com/rss/"),
    FeedSource(id: 91, name: "Meta Filter", category: "Agg", rssUrl: "https://www.metafilter.com/feeds/"),
    FeedSource(id: 179, name: "BoingBoing", category: "Agg", rssUrl: "https://boingboing.net/feed"),
    FeedSource(id: 270, name: "Vice", category: "Agg", rssUrl: "https://www.vice.com/en_us/rss"),
    FeedSource(id: 274, name: "Tech Insider", category: "Agg", rssUrl: "https://www.businessinsider.com/rss"),
    FeedSource(id: 292, name: "Ad Week", category: "Agg", rssUrl: "https://www.adweek.com/feed/"),
  ];

  // Predefined feed combinations similar to Skimfeed
  static const Map<String, List<int>> predefinedFeeds = {
    "whats_hot": [75, 76, 77, 78, 80, 81, 82, 83, 84, 86, 87, 88, 89, 90, 91, 179, 270, 274, 292],
    "latest": [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15, 18, 19, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 85],
    "tech": [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15, 18, 19, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 85, 204, 272, 273, 282, 283, 313],
    "gaming": [92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 163, 177, 180, 181, 182, 183, 184, 185, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 198, 199, 200, 201],
    "science": [37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 202, 203, 295, 297, 298, 299, 300, 301, 302],
    "news": [128, 129, 130, 131, 132, 133, 134, 137, 138, 139, 140, 141, 143, 144, 145, 146, 147, 205, 271, 288, 289, 290, 291],
    "reddit": [166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 261],
  };

  static FeedSource? getSourceById(int id) {
    try {
      return sources.firstWhere((source) => source.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<FeedSource> getSourcesByIds(List<int> ids) {
    return ids
        .map((id) => getSourceById(id))
        .where((source) => source != null)
        .cast<FeedSource>()
        .toList();
  }

  static List<FeedSource> getSourcesByCategory(String category) {
    return sources.where((source) => source.category == category).toList();
  }

  static List<String> getCategories() {
    return sources.map((source) => source.category).toSet().toList()..sort();
  }
}

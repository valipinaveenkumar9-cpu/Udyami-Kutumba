import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/api/news/news_api.dart';
import '../../../core/models/news_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const Color primaryColor = Color(0xFF20C7B5);

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Community',
    'Jobs',
    'Events',
    'Leadership',
    'Area',
    'UQueens',
  ];

  List<NewsModel> _allNews = [];
  List<NewsModel> _featuredNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    final fetched = await NewsAPI.getAllNews(limit: 50);
    final featured = await NewsAPI.getFeaturedNews();
    if (mounted) {
      setState(() {
        _allNews = fetched;
        _featuredNews = featured;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Light / Dark colors
    final backgroundColor =
        isDark ? Colors.black : const Color(0xFFF5F7FA);

    final cardColor =
        isDark ? const Color(0xFF15191A) : Colors.white;

    final textColor =
        isDark ? Colors.white : const Color(0xFF0D1B4C);

    final secondaryTextColor =
        isDark ? Colors.white54 : Colors.grey.shade600;

    final borderColor =
        isDark ? Colors.white12 : Colors.grey.shade200;

    final iconBackgroundColor = isDark
        ? primaryColor.withValues(alpha: 0.10)
        : primaryColor.withValues(alpha: 0.08);

    final filteredNews = selectedCategory == 'All'
        ? _allNews
        : _allNews
            .where(
              (news) => news.category == selectedCategory,
            )
            .toList();

    return Scaffold(
      backgroundColor: backgroundColor,

      // ---------------------------------------------------------
      // APP BAR
      // ---------------------------------------------------------

      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
        ),

        title: Text(
          'News',
          style: TextStyle(
            color: textColor,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
              const ThemeToggleButton(),
          IconButton(
            onPressed: () {
              _showSearchDialog(
                context,
                cardColor,
                textColor,
                secondaryTextColor,
              );
            },
            icon: Icon(
              Icons.search_rounded,
              color: textColor,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ---------------------------------------------------------
      // BODY
      // ---------------------------------------------------------

      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          backgroundColor: cardColor,

          onRefresh: () async {
            await _fetchNews();
          },

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                Text(
                  'Latest Updates',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Stay updated with your community',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // CATEGORY FILTER
                // ------------------------------------------------

                SizedBox(
                  height: 40,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,

                    itemBuilder: (context, index) {
                      final category = categories[index];

                      final isSelected =
                          selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },

                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),

                          margin: const EdgeInsets.only(
                            right: 9,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 17,
                          ),

                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : cardColor,

                            borderRadius:
                                BorderRadius.circular(22),

                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : borderColor,
                            ),
                          ),

                          child: Text(
                            category,

                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : textColor.withValues(
                                      alpha: 0.70,
                                    ),

                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // ------------------------------------------------
                // FEATURED NEWS
                // ------------------------------------------------

                if (selectedCategory == 'All') ...[
                  if (_featuredNews.isNotEmpty)
                    _buildFeaturedNews(
                      context,
                      _featuredNews.first,
                      cardColor,
                      textColor,
                      secondaryTextColor,
                      borderColor,
                    ),

                  const SizedBox(height: 28),

                  Text(
                    'Latest News',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),
                ],

                // ------------------------------------------------
                // SELECTED CATEGORY TITLE
                // ------------------------------------------------

                if (selectedCategory != 'All') ...[
                  Text(
                    '$selectedCategory News',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),
                ],

                // ------------------------------------------------
                // NEWS LIST
                // ------------------------------------------------

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredNews.isEmpty)
                  _buildEmptyState(
                    textColor,
                    secondaryTextColor,
                  )
                else
                  ...filteredNews.map(
                    (news) => _buildNewsCard(
                      context,
                      news,
                      cardColor,
                      textColor,
                      secondaryTextColor,
                      borderColor,
                      iconBackgroundColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FEATURED NEWS
  // =============================================================

  Widget _buildFeaturedNews(
    BuildContext context,
    NewsModel featuredNews,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsScreen(
              news: featuredNews,
            ),
          ),
        );
      },

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: primaryColor.withValues(
              alpha: 0.25,
            ),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Featured image area
            Container(
              height: 180,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    primaryColor.withValues(
                      alpha: 0.25,
                    ),
                    cardColor,
                  ],
                ),
              ),

              child: featuredNews.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: Image.network(
                        featuredNews.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: primaryColor,
                        size: 70,
                      ),
                    ),
            ),

            // Featured content
            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // Featured badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: 0.12,
                      ),

                      borderRadius:
                          BorderRadius.circular(7),
                    ),

                    child: const Text(
                      'FEATURED',

                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // Title
                  Text(
                    featuredNews.title,

                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    featuredNews.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: secondaryTextColor,
                        size: 14,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${featuredNews.publishedAt != null ? timeago.format(DateTime.parse(featuredNews.publishedAt!)) : 'Just now'} • ${featuredNews.source.isNotEmpty ? featuredNews.source : '2 min read'}',

                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // NEWS CARD
  // =============================================================

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'community': return Icons.groups_rounded;
      case 'jobs': return Icons.work_rounded;
      case 'events': return Icons.event_rounded;
      case 'leadership': return Icons.workspace_premium_rounded;
      case 'ward': return Icons.location_city_rounded;
      case 'uqueens': return Icons.auto_awesome_rounded;
      default: return Icons.article_rounded;
    }
  }

  Widget _buildNewsCard(
    BuildContext context,
    NewsModel news,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
    Color iconBackgroundColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsScreen(
              news: news,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 13),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: cardColor,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: borderColor,
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ---------------------------------------------------
            // ICON
            // ---------------------------------------------------

            Container(
              width: 56,
              height: 56,

              decoration: BoxDecoration(
                color: iconBackgroundColor,

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Icon(
                _getCategoryIcon(news.category),
                color: primaryColor,
                size: 27,
              ),
            ),

            const SizedBox(width: 13),

            // ---------------------------------------------------
            // CONTENT
            // ---------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // Category
                  Text(
                    news.category.toUpperCase(),

                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Title
                  Text(
                    news.title,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Description
                  Text(
                    news.summary,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // Date and read time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: secondaryTextColor,
                        size: 13,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${news.publishedAt != null ? timeago.format(DateTime.parse(news.publishedAt!)) : 'Just now'} • ${news.source.isNotEmpty ? news.source : '2 min read'}',

                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            // Arrow
            Padding(
              padding:
                  const EdgeInsets.only(top: 20),

              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: secondaryTextColor,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // EMPTY STATE
  // =============================================================

  Widget _buildEmptyState(
    Color textColor,
    Color secondaryTextColor,
  ) {
    return SizedBox(
      width: double.infinity,

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 60,
        ),

        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              color: secondaryTextColor,
              size: 60,
            ),

            const SizedBox(height: 15),

            Text(
              'No news available',

              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Check back later for new updates.',

              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // SEARCH DIALOG
  // =============================================================

  void _showSearchDialog(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Text(
            'Search News',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            autofocus: true,

            style: TextStyle(
              color: textColor,
            ),

            decoration: InputDecoration(
              hintText: 'Search news...',

              hintStyle: TextStyle(
                color: secondaryTextColor,
              ),

              prefixIcon: const Icon(
                Icons.search_rounded,
                color: primaryColor,
              ),

              filled: true,

              fillColor:
                  Theme.of(context).brightness ==
                          Brightness.dark
                      ? Colors.black
                      : const Color(0xFFF5F7FA),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),

                borderSide: BorderSide.none,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Close',

                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}



// =================================================================
// NEWS DETAILS SCREEN
// =================================================================

class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsScreen({
    super.key,
    required this.news,
  });

  static const Color primaryColor =
      Color(0xFF20C7B5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? Colors.black : const Color(0xFFF5F7FA);

    final cardColor =
        isDark ? const Color(0xFF15191A) : Colors.white;

    final textColor =
        isDark ? Colors.white : const Color(0xFF0D1B4C);

    final secondaryTextColor =
        isDark ? Colors.white54 : Colors.grey.shade600;

    final borderColor =
        isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ---------------------------------------------------------
      // APP BAR
      // ---------------------------------------------------------

      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
        ),

        title: Text(
          'News Details',

          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
              const ThemeToggleButton(),
          IconButton(
            onPressed: () {},

            icon: Icon(
              Icons.share_outlined,
              color: textColor,
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------
      // BODY
      // ---------------------------------------------------------

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          30,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ---------------------------------------------------
            // IMAGE
            // ---------------------------------------------------

            news.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      news.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius:
                    BorderRadius.circular(22),

                border: Border.all(
                  color: borderColor,
                ),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    primaryColor.withValues(
                      alpha: 0.25,
                    ),
                    cardColor,
                  ],
                ),
              ),

              child: Icon(
                Icons.image_outlined,
                color: primaryColor,
                size: 80,
              ),
            ),

            const SizedBox(height: 22),

            // ---------------------------------------------------
            // CATEGORY
            // ---------------------------------------------------

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                    BorderRadius.circular(8),
              ),

              child: Text(
                news.category.toUpperCase(),

                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------------------------------------------
            // TITLE
            // ---------------------------------------------------

            Text(
              news.title,

              style: TextStyle(
                color: textColor,
                fontSize: 27,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 12),

            // ---------------------------------------------------
            // DATE
            // ---------------------------------------------------

            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: secondaryTextColor,
                  size: 15,
                ),

                const SizedBox(width: 5),

                Text(
                  '${news.publishedAt != null ? timeago.format(DateTime.parse(news.publishedAt!)) : 'Just now'} • ${news.source.isNotEmpty ? news.source : '2 min read'}',

                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ---------------------------------------------------
            // DESCRIPTION
            // ---------------------------------------------------

            Text(
              news.body.isNotEmpty ? news.body : news.summary,

              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black87,
                fontSize: 15,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 28),

            // ---------------------------------------------------
            // ABOUT
            // ---------------------------------------------------

            Text(
              'About this update',

              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Our community continues to grow with new '
              'opportunities, activities and initiatives. '
              'Stay connected through the app to discover '
              'more updates and participate in upcoming '
              'events.',

              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 25),

            // ---------------------------------------------------
            // INFORMATION CARD
            // ---------------------------------------------------

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius:
                    BorderRadius.circular(17),

                border: Border.all(
                  color: borderColor,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: primaryColor,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Stay connected with the latest community updates.',

                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
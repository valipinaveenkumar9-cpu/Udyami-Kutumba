import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/session_manager.dart';
import 'post_news_screen.dart';

class NewsManagementDashboardScreen extends StatefulWidget {
  const NewsManagementDashboardScreen({super.key});

  @override
  State<NewsManagementDashboardScreen> createState() => _NewsManagementDashboardScreenState();
}

class _NewsManagementDashboardScreenState extends State<NewsManagementDashboardScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    "All", "Business", "Technology", "Policy", "Agriculture",
    "Finance", "Health", "Education", "Infrastructure"
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      _articles.clear();
    }
    if (!_hasMore) return;
    
    setState(() => _isLoading = true);
    try {
      final token = SessionManager.token;
      
      String urlStr = "https://backend.udyamikutumba.com/news/getAllNews?page=$_page&limit=20";
      if (_searchQuery.isNotEmpty) urlStr += "&search=$_searchQuery";
      if (_selectedCategory != 'All') urlStr += "&category=$_selectedCategory";
      
      final url = Uri.parse(urlStr);
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      print('DEV DEBUG - News API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('DEV DEBUG - News API RAW JSON: ${response.body}');
        final data = json.decode(response.body);
        
        List<dynamic>? newArticles;
        if (data['data'] is List) {
          newArticles = data['data'];
        } else if (data['news'] is List) {
          newArticles = data['news'];
        } else if (data['data'] != null && data['data']['news'] is List) {
          newArticles = data['data']['news'];
        }

        if (newArticles != null) {
          setState(() {
            _articles.addAll(newArticles!);
            if (newArticles.length < 20) _hasMore = false;
            _page++;
          });
          print('DEV DEBUG - Parsed News Count: ${_articles.length}');
        } else {
           print('DEV DEBUG - Could not parse news array from response!');
        }
      } else {
        print('DEV DEBUG - News API Error: ${response.body}');
      }
    } catch (e) {
      print('DEV DEBUG - News API Exception: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteNews(String id) async {
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/news/deleteNews/$id");
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchNews(reset: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article removed')));
      }
    } catch (e) {
      print('Delete News Error: $e');
    }
  }

  Future<void> _toggleFeatured(String id, bool isFeatured) async {
    try {
      final token = SessionManager.token;
      final url = Uri.parse("https://backend.udyamikutumba.com/news/updateNews/$id");
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'isFeatured': !isFeatured}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchNews(reset: true);
      }
    } catch (e) {
      print('Toggle Featured Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _articles.length;
    int featuredCount = _articles.where((a) => a['isFeatured'] == true || a['featured'] == true).length;
    int withMediaCount = _articles.where((a) => (a['imageUrl'] != null && a['imageUrl'].toString().isNotEmpty) || (a['image'] != null && a['image'].toString().isNotEmpty)).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('News Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchNews(reset: true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostNewsScreen()),
                );
                if (result == true) {
                  _fetchNews(reset: true);
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1f3c),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Create, edit, feature and remove news articles shown to members.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard('Total', total.toString(), 'All articles', Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('Featured', featuredCount.toString(), 'Pinned to feed', Colors.amber.shade700),
                const SizedBox(width: 8),
                _buildStatCard('With Media', withMediaCount.toString(), 'Have image', Colors.purple),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _fetchNews(reset: true);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search title, category, source...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'All' ? 'All Articles' : value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _selectedCategory = newValue);
                            _fetchNews(reset: true);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // List
          Expanded(
            child: _isLoading && _articles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                    ? const Center(child: Text("No articles found."))
                    : RefreshIndicator(
                        onRefresh: () => _fetchNews(reset: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _articles.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _articles.length) {
                              _fetchNews();
                              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                            }
                            final article = _articles[index];
                            final id = article['newsId'] ?? article['id'] ?? article['_id'];
                            final isFeatured = article['isFeatured'] ?? article['featured'] ?? false;
                            final imageUrl = article['imageUrl'] ?? article['image'];
                            final category = article['category'] ?? article['sector'] ?? 'Business';

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade200,
                                        image: imageUrl != null && imageUrl.toString().isNotEmpty
                                            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                            : null,
                                      ),
                                      child: imageUrl == null || imageUrl.toString().isEmpty
                                          ? Center(child: Text(category.isNotEmpty ? category[0] : 'N', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)))
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(category, style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                article['publishedAt'] != null ? article['publishedAt'].toString().substring(0, 10) : 'Recently',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                              if (article['source'] != null) ...[
                                                const SizedBox(width: 4),
                                                Text('· ${article['source']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                              ]
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            article['title'] ?? 'Untitled',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            article['summary'] ?? '',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                                  child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => _toggleFeatured(id.toString(), isFeatured),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isFeatured ? Colors.amber.shade50 : Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isFeatured ? Colors.amber.shade200 : Colors.transparent)
                                                  ),
                                                  child: Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isFeatured ? Colors.amber.shade700 : Colors.black54)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => _deleteNews(id.toString()),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                                  child: Text('Remove', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

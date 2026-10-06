import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'widgets/marketos_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/app_video_player.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final SocialChannelApi _socialApi = SocialChannelApi();
  bool _isLoading = true;
  bool _hasError = false;
  
  List<GeneratedContentItem> _allMedia = [];
  List<String> _campaigns = ['All campaigns'];
  
  String _mediaFilter = 'all'; // 'all', 'image', 'video'
  String _campaignFilter = 'All campaigns';

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final contents = await _socialApi.getAllGeneratedContent();
      
      final mediaItems = <GeneratedContentItem>[];
      final campaignSet = <String>{'All campaigns'};
      
      for (var c in contents) {
        if (c.mediaUrl != null && c.mediaUrl!.isNotEmpty) {
          mediaItems.add(c);
          final campaignName = _extractCampaignName(c);
          if (campaignName.isNotEmpty) {
            campaignSet.add(campaignName);
          }
        }
      }

      if (mounted) {
        setState(() {
          _allMedia = mediaItems;
          _campaigns = campaignSet.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }
  
  String _extractCampaignName(GeneratedContentItem c) {
    if (c.productName != null && c.productName!.isNotEmpty) return c.productName!;
    if (c.aiResponse != null && c.aiResponse!['campaign'] != null) {
      return c.aiResponse!['campaign'].toString();
    }
    return 'Untitled Campaign';
  }
  
  String _extractTitle(GeneratedContentItem c) {
    if (c.aiResponse != null && c.aiResponse!['title'] != null) {
      return c.aiResponse!['title'].toString();
    }
    if (c.activityType != null && c.activityType!.isNotEmpty) {
      return c.activityType!;
    }
    return 'Media Asset';
  }

  List<GeneratedContentItem> get _filteredMedia {
    return _allMedia.where((item) {
      // Filter by media type
      bool matchType = true;
      final url = item.mediaUrl ?? '';
      final isVid = isVideoUrl(url) || (item.mediaType?.toLowerCase() == 'video');
      
      if (_mediaFilter == 'image') {
        matchType = !isVid;
      } else if (_mediaFilter == 'video') {
        matchType = isVid;
      }
      
      // Filter by campaign
      bool matchCampaign = true;
      if (_campaignFilter != 'All campaigns') {
        matchCampaign = _extractCampaignName(item) == _campaignFilter;
      }
      
      return matchType && matchCampaign;
    }).toList();
  }

  Widget _buildFilterChip(String label, String value, IconData? icon, Color text, Color surf, Color line, Color gold) {
    final isSelected = _mediaFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : text),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _mediaFilter = value);
        },
        backgroundColor: surf,
        selectedColor: gold,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? gold : line),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);
    
    final filteredList = _filteredMedia;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: text),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Storage',
          style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: line, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load storage', style: TextStyle(color: text, fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // Intro Section
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text('CAMPAIGN LIBRARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: muted)),
                    //             const SizedBox(height: 8),
                    //             Text('Finished work, ready to reuse.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: text)),
                    //             const SizedBox(height: 6),
                    //             Text('Every approved image and video from your completed campaigns, in one place.', style: TextStyle(fontSize: 13, color: muted)),
                    //           ],
                    //         ),
                    //       ),
                    //       const SizedBox(width: 16),
                    //       Column(
                    //         children: [
                    //           Text(filteredList.length.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: text)),
                    //           Text('assets', style: TextStyle(fontSize: 11, color: muted)),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    
                    // Filters Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: surf,
                        border: Border.symmetric(horizontal: BorderSide(color: line)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Filter by', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: text)),
                              Text('${filteredList.length} results', style: TextStyle(fontSize: 12, color: muted)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All media', 'all', null, text, surf, line, gold),
                                _buildFilterChip('Images', 'image', Icons.image_outlined, text, surf, line, gold),
                                _buildFilterChip('Videos', 'video', Icons.play_circle_outline_rounded, text, surf, line, gold),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Campaign Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: line),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _campaignFilter,
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                                dropdownColor: surf,
                                style: TextStyle(color: text, fontSize: 14),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() => _campaignFilter = newValue);
                                  }
                                },
                                items: _campaigns.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Media Grid
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_copy_outlined, size: 48, color: muted),
                                  const SizedBox(height: 16),
                                  Text('No matching media', style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('Try another campaign or media type.', style: TextStyle(color: muted, fontSize: 13)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                final url = item.mediaUrl ?? '';
                                final isVid = isVideoUrl(url) || (item.mediaType?.toLowerCase() == 'video');
                                final dateStr = item.createdAt != null 
                                    ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(item.createdAt!) ?? DateTime.now()) 
                                    : 'Unknown date';
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: isVid
                                                ? AppVideoThumbnail(videoUrl: url)
                                                : GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => Dialog(
                                                          backgroundColor: Colors.transparent,
                                                          insetPadding: EdgeInsets.zero,
                                                          child: Stack(
                                                            fit: StackFit.expand,
                                                            children: [
                                                              InteractiveViewer(
                                                                child: CachedNetworkImage(
                                                                  imageUrl: url,
                                                                  fit: BoxFit.contain,
                                                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 64)),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 40,
                                                                right: 20,
                                                                child: IconButton(
                                                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                                  onPressed: () => Navigator.pop(context),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: CachedNetworkImage(
                                                      imageUrl: url,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => Container(
                                                        color: surf,
                                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                      ),
                                                      errorWidget: (context, url, error) => Container(
                                                        color: surf,
                                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(isVid ? Icons.play_arrow : Icons.image_outlined, size: 12, color: Colors.white),
                                                  const SizedBox(width: 4),
                                                  Text(isVid ? 'Video' : 'Image', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isVid)
                                            const Center(
                                              child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _extractTitle(item),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: text),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _extractCampaignName(item),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: muted),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dateStr, style: TextStyle(fontSize: 11, color: muted)),
                                        // Fake size for aesthetics like web
                                        Text(isVid ? '15 MB' : '2 MB', style: TextStyle(fontSize: 11, color: muted)),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/api/directory/directory_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

// ─────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────
class MemberModel {
  final String name;
  final String role;
  final String company;
  final String location;
  final String image;
  final String category;
  final double rating;
  final int reviews;
  final String phone;

  const MemberModel({
    required this.name,
    required this.role,
    required this.company,
    required this.location,
    required this.image,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.phone,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final businessDetails = profile['businessDetails'] as Map<String, dynamic>? ?? {};

    String cat = businessDetails['sector']?.toString() ?? '';
    if (cat.isEmpty || cat.toLowerCase() == 'null') {
      final bType = businessDetails['businessType']?.toString() ?? '';
      if (bType.isNotEmpty) {
        cat = bType.split('|')[0].trim();
      }
    }
    if (cat.isEmpty) cat = 'Unknown';

    print('DEV DEBUG - MemberModel - Name: ${json['name']}, RAW Business Details: $businessDetails');
    print('DEV DEBUG - MemberModel - Extracted Category: $cat, Extracted Company: ${businessDetails['businessName']}');

    return MemberModel(
      name: json['name']?.toString() ?? 'Unknown',
      role: profile['jobTitle']?.toString() ?? 'Member',
      company: businessDetails['businessName']?.toString() ?? businessDetails['companyName']?.toString() ?? 'No Company',
      location: businessDetails['businessAddress']?.toString() ?? 'Unknown',
      image: profile['profileImage']?.toString() ?? '',
      category: cat,
      rating: 4.5,
      reviews: 0,
      phone: profile['phoneNumber']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────
// MEMBER DIRECTORY SCREEN
// ─────────────────────────────────────────────────────
class MemberDirectoryScreen extends StatefulWidget {
  const MemberDirectoryScreen({super.key});

  @override
  State<MemberDirectoryScreen> createState() => _MemberDirectoryScreenState();
}

class _MemberDirectoryScreenState extends State<MemberDirectoryScreen> {
  String _selectedCategory = "All";
  String _searchQuery = "";
  
  final DirectoryAPI _directoryAPI = DirectoryAPI();
  List<MemberModel> _allMembers = [];
  bool _isLoading = true;
  Timer? _debounce;

  List<String> _categories = ["All"];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    final results = await _directoryAPI.getAllMembers();
    if (mounted) {
      setState(() {
        _allMembers = results.map((e) => MemberModel.fromJson(e)).toList();
        _updateCategories();
        _isLoading = false;
      });
    }
  }

  void _updateCategories() {
    final Set<String> uniqueCategories = {"All"};
    for (var member in _allMembers) {
      if (member.category.isNotEmpty && member.category.toLowerCase() != 'unknown') {
        uniqueCategories.add(member.category);
      }
    }
    _categories = uniqueCategories.toList();
    print('DEV DEBUG - _updateCategories - Generated Categories: $_categories');
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = "All";
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.isEmpty) {
      return _fetchMembers();
    }
    setState(() => _isLoading = true);
    final results = await _directoryAPI.searchBusinessMembers(query);
    if (mounted) {
      setState(() {
        _allMembers = results.map((e) => MemberModel.fromJson(e)).toList();
        _updateCategories();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMembers(query);
    });
  }

  List<MemberModel> get _filtered {
    return _allMembers.where((m) {
      final matchCat =
          _selectedCategory == "All" || m.category.toLowerCase() == _selectedCategory.toLowerCase();
      // Name and company are already filtered by the API if using search query, 
      // but we keep local fallback for safety.
      return matchCat;
    }).toList();
  }

  // Category icon map
  IconData _categoryIcon(String cat) {
    switch (cat) {
      case "Food":
        return Icons.restaurant;
      case "Jobs":
        return Icons.work_outline;
      case "IT":
        return Icons.computer;
      case "Hotels":
        return Icons.hotel;
      case "Shops":
        return Icons.store;
      case "Doctor":
        return Icons.local_hospital;
      case "Education":
        return Icons.school;
      case "Beauty":
        return Icons.face_retouching_natural;
      default:
        return Icons.grid_view;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            elevation: 0,
        backgroundColor: Colors.transparent,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Member Directory",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal.shade800,
            ),
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: TextFormField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search businesses or members...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.teal.shade400),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category chips ──
          SizedBox(
            height: 62,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcon(cat),
                          size: 15,
                          color: selected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat,
                          style: TextStyle(
                            color: selected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Member list ──
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No members found.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (_searchQuery.isEmpty) {
                            await _fetchMembers();
                          } else {
                            await _searchMembers(_searchQuery);
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final m = filtered[index];
                            return MemberCard(
                              member: m,
                              categoryIcon: _categoryIcon(m.category),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// MEMBER CARD WIDGET
// ─────────────────────────────────────────────────────
class MemberCard extends StatelessWidget {
  final MemberModel member;
  final IconData categoryIcon;

  const MemberCard({super.key, required this.member, required this.categoryIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Theme.of(context).colorScheme.surface 
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Theme.of(context).brightness == Brightness.dark 
            ? null 
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Top row: avatar + info ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: member.image.isNotEmpty && member.image.startsWith('http')
                          ? NetworkImage(member.image)
                          : null,
                      child: member.image.isEmpty || !member.image.startsWith('http')
                          ? Icon(Icons.person, color: Colors.teal)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categoryIcon,
                          size: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member.role,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade300 : Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              member.company,
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              member.location,
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "share", child: Text("Share")),
                    PopupMenuItem(value: "report", child: Text("Report")),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Rating row ──
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < member.rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  member.rating.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(
                  "(${member.reviews} Reviews)",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade900.withValues(alpha: 0.5) : Colors.teal.shade100,
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal.shade900,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberProfileScreen(member: member),
                        ),
                      );
                    },
                    child: const Text(
                      "View Profile",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.teal.shade900,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade700 : Colors.teal.shade100, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(member: member),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CHAT MESSAGE MODEL
// ─────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  _ChatMessage({required this.text, required this.isMe, required this.time});
}

// ─────────────────────────────────────────────────────
// ORIGINAL CHAT SCREEN
// ─────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final MemberModel member;
  const ChatScreen({super.key, required this.member});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendAnim;
  bool _showAttach = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hi! I found your profile in the directory.",
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    _ChatMessage(
      text: "Hey! Great to hear from you 😊",
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 11)),
    ),
    _ChatMessage(
      text: "I would like to know more about your services.",
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    _ChatMessage(
      text: "Absolutely! Feel free to ask anything.",
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sendAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.80,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sendAnim.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _sendAnim.reverse().then((_) => _sendAnim.forward());
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: DateTime.now()));
      _controller.clear();
    });
    _scrollToBottom();
    final replies = [
      "Thanks for reaching out!",
      "I will get back to you shortly.",
      "Sure, let us discuss further.",
      "Great! Looking forward to it.",
      "Noted! Will respond soon.",
    ];
    replies.shuffle();
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(text: replies.first, isMe: false, time: DateTime.now()),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, "0");
    return "$h:$m ${t.hour >= 12 ? "PM" : "AM"}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _header(context),
          _dateDivider(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 19,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade300],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundImage: NetworkImage(widget.member.image),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          "Active now",
                          style: TextStyle(
                            color: Colors.teal.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Today",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ),
          Expanded(child: Container(height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200)),
        ],
      ),
    );
  }

  Widget _bubble(_ChatMessage msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(widget.member.image),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.68,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.teal : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? Colors.teal.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmt(msg.time),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _inputBar() {
    final hasText = _controller.text.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
        border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showAttach)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachIcon(
                      Icons.insert_drive_file,
                      Colors.purple.shade400,
                      "Document",
                    ),
                    _attachIcon(
                      Icons.camera_alt,
                      Colors.pink.shade400,
                      "Camera",
                    ),
                    _attachIcon(Icons.image, Colors.purpleAccent, "Gallery"),
                    _attachIcon(Icons.headset, Colors.orange.shade400, "Audio"),
                    _attachIcon(
                      Icons.location_on,
                      Colors.green.shade500,
                      "Location",
                    ),
                    _attachIcon(Icons.person, Colors.blue.shade400, "Contact"),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      _showAttach ? Icons.close : Icons.add,
                      color: Colors.grey.shade400,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() => _showAttach = !_showAttach);
                    },
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 16),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Message",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, right: 6),
                    child: ScaleTransition(
                      scale: _sendAnim,
                      child: GestureDetector(
                        onTap: _send,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasText ? Colors.teal : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: hasText
                                ? Colors.white
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
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

  Widget _attachIcon(IconData icon, Color bg, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// MEMBER PROFILE SCREEN
// ─────────────────────────────────────────────────────
class MemberProfileScreen extends StatelessWidget {
  final MemberModel member;
  const MemberProfileScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.teal,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  Hero(
                    tag: member.name,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: member.image.isNotEmpty && member.image.startsWith('http')
                          ? NetworkImage(member.image)
                          : null,
                      child: member.image.isEmpty || !member.image.startsWith('http')
                          ? Icon(Icons.person, color: Colors.teal, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.role,
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).colorScheme.surface 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: Theme.of(context).brightness == Brightness.dark 
                      ? null 
                      : [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.business,
                      title: "Company",
                      value: member.company,
                    ),
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffF0F0F0),
                    ),
                    _DetailRow(
                      icon: Icons.location_on,
                      title: "Location",
                      value: member.location,
                    ),
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffF0F0F0),
                    ),
                    _DetailRow(
                      icon: Icons.category,
                      title: "Category",
                      value: member.category,
                    ),
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffF0F0F0),
                    ),
                    _DetailRow(
                      icon: Icons.phone,
                      title: "Phone",
                      value: member.phone,
                    ),
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffF0F0F0),
                    ),
                    _DetailRow(
                      icon: Icons.star,
                      title: "Rating",
                      value: "${member.rating} (${member.reviews} reviews)",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey[700], 
            size: 20
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

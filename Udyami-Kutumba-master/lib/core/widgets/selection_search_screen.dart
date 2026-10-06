import 'package:flutter/material.dart';

class SelectionSearchScreen extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String displayKey;
  final String searchHint;
  final VoidCallback? onAddPressed;

  const SelectionSearchScreen({
    super.key,
    required this.title,
    required this.items,
    required this.displayKey,
    this.searchHint = "Search...",
    this.onAddPressed,
  });

  @override
  State<SelectionSearchScreen> createState() => _SelectionSearchScreenState();
}

class _SelectionSearchScreenState extends State<SelectionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final displayValue = item[widget.displayKey]?.toString().toLowerCase() ?? '';
        return displayValue.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (widget.onAddPressed != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: widget.onAddPressed,
              tooltip: "Add New",
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No items found", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                        if (widget.onAddPressed != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: widget.onAddPressed,
                            icon: const Icon(Icons.add),
                            label: const Text("Add New"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ]
                      ],
                    ),
                  )
                : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final displayValue = item[widget.displayKey]?.toString() ?? '';
                return ListTile(
                  title: Text(
                    displayValue,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

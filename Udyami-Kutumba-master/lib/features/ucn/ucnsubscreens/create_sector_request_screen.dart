import 'package:flutter/material.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CreateSectorRequestScreen extends StatefulWidget {
  const CreateSectorRequestScreen({super.key});

  @override
  State<CreateSectorRequestScreen> createState() => _CreateSectorRequestScreenState();
}

class _CreateSectorRequestScreenState extends State<CreateSectorRequestScreen> {
  final SectorAPI _sectorApi = SectorAPI();
  bool _isLoading = false;
  
  List<dynamic> _sectors = [];
  Map<String, dynamic>? _selectedSector;
  
  List<dynamic> _subSectors = [];
  Map<String, dynamic>? _selectedSubSector;
  
  List<dynamic> _tags = [];
  Map<String, dynamic>? _selectedTag;
  
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSectors();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchSectors() async {
    setState(() => _isLoading = true);
    try {
      final response = await _sectorApi.getAllSectors();
      if (mounted && response != null && response['success'] == true) {
        setState(() {
          _sectors = response['data'] ?? [];
        });
      }
    } catch (e) {
      print('Exception fetching sectors: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSectorChanged(Map<String, dynamic>? newSector) {
    setState(() {
      _selectedSector = newSector;
      _subSectors = newSector?['subSectors'] ?? [];
      _selectedSubSector = null;
      _tags = [];
      _selectedTag = null;
    });
  }

  void _onSubSectorChanged(Map<String, dynamic>? newSubSector) {
    setState(() {
      _selectedSubSector = newSubSector;
      _tags = newSubSector?['tags'] ?? [];
      _selectedTag = null;
    });
  }

  void _onTagChanged(Map<String, dynamic>? newTag) {
    setState(() {
      _selectedTag = newTag;
    });
  }

  Future<void> _showCreateTagDialog() async {
    if (_selectedSubSector == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Sub-Category first')));
       return;
    }
    final textController = TextEditingController();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Create New Tag'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'e.g. Flutter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              Navigator.pop(c);
              final res = await _sectorApi.createBusinessTags({
                 'tagName': textController.text.trim(),
                 'description': '${textController.text.trim()} tag',
                 'subSectorId': _selectedSubSector!['subSectorId'],
              });
              if (res != null && res['success'] == true) {
                 final newTag = {
                    'tagName': textController.text.trim(),
                    'tagId': res['data']?['tagId'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
                 };
                 setState(() {
                    _tags = List.from(_tags)..add(newTag);
                    _selectedTag = newTag;
                 });
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag created!')));
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create tag.')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_selectedSector == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a sector')));
      return;
    }
    if (_selectedSubSector == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a sub-sector')));
      return;
    }
    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a business tag')));
      return;
    }

    final userId = SessionManager.user?['userId'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User session not found')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'userId': userId,
        'createdUserId': userId,
        'sectorId': _selectedSector!['sectorId'],
        'subSector': _selectedSubSector!['subSectorName'],
        'businessTag': _selectedTag!['tagName'],
        'remarks': _remarksController.text.trim(),
      };
      
      final response = await _sectorApi.createSectorRequest(payload);
      if (mounted) {
        if (response != null && response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted successfully')));
          Navigator.pop(context);
        } else {
          final msg = response?['message'] ?? 'Failed to submit request';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      print('Exception submitting request: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting request')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Apply for Sector",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading && _sectors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Business Category (Sector)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedSector,
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Select a sector",
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _sectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                      value: s,
                      child: Text(s['sectorName'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: _onSectorChanged,
                  ),
                  
                  const SizedBox(height: 24),
                  Text("Business Sub-Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedSubSector,
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Select sub-category",
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _subSectors.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                      value: s,
                      child: Text(s['subSectorName'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: _onSubSectorChanged,
                  ),

                  const SizedBox(height: 24),
                  Text("Business Tag", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedTag,
                          isExpanded: true,
                          dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "Select business tag",
                            hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            filled: true,
                            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: _tags.map((s) => DropdownMenuItem<Map<String, dynamic>>(
                            value: s,
                            child: Text(s['tagName'] ?? 'Unknown', overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: _onTagChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.teal.withValues(alpha: 0.15) : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, color: isDark ? Colors.teal.shade300 : Colors.teal, size: 28),
                          onPressed: _showCreateTagDialog,
                          tooltip: 'Add new tag',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text("Remarks (Optional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Any additional details...",
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

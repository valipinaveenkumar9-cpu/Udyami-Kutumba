import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../viewmodels/communications_viewmodel.dart';
import 'campaign_step3_schedule_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ContactPickerScreen extends StatefulWidget {
  final String title;
  final List<Contact> contacts;
  final String campaignType;
  final CommunicationsViewModel viewModel;

  const ContactPickerScreen({
    super.key,
    required this.title,
    required this.contacts,
    required this.campaignType,
    required this.viewModel,
  });

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  TextEditingController searchController = TextEditingController();
  List<Contact> displayedContacts = [];
  bool _isCreatingCampaign = false;

  @override
  void initState() {
    super.initState();
    displayedContacts = List.from(widget.contacts);
    searchController.addListener(_filterContacts);
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        displayedContacts = List.from(widget.contacts);
      } else {
        displayedContacts = widget.contacts.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
              contact.phone.toLowerCase().contains(query) ||
              contact.sector.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _handleCreateCampaign() {
    final selectedContacts = widget.contacts.where((e) => e.selected).toList();
    final memberIds = selectedContacts.map((c) => c.name).toList(); // Assuming name or id for now
    
    print('DEV DEBUG - ContactPickerScreen: Selected ${memberIds.length} members. Moving to Step 3.');
    
    widget.viewModel.newCampaignMemberIds.addAll(memberIds);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignStep3ScheduleScreen(
          campaignType: widget.campaignType,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int selectedCount = widget.contacts.where((e) => e.selected).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$selectedCount of ${widget.contacts.length} selected",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: selectedCount == 0 ? null : _handleCreateCampaign,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Add $selectedCount recipients",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                  hintText: "Search name, phone, sector",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    activeColor: theme.colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    value: selectedCount == widget.contacts.length && widget.contacts.isNotEmpty,
                    title: Text(
                      "Select All (${widget.contacts.length})",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onChanged: (value) {
                      setState(() {
                        for (var contact in widget.contacts) {
                          contact.selected = value ?? false;
                        }
                      });
                    },
                  ),
                ),
                ...displayedContacts.map((contact) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: contact.selected ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.shade100,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CheckboxListTile(
                      activeColor: theme.colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      value: contact.selected,
                      onChanged: (value) {
                        setState(() {
                          contact.selected = value ?? false;
                        });
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          contact.initials,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "${contact.phone} • ${contact.sector}",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api/ubn/hall_booking_api.dart';
import '../../../core/api/ubn/meeting_api.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class HallCoordinatorScreen extends StatefulWidget {
  final String? meetingId;
  const HallCoordinatorScreen({super.key, this.meetingId});

  @override
  State<HallCoordinatorScreen> createState() => _HallCoordinatorScreenState();
}

class _HallCoordinatorScreenState extends State<HallCoordinatorScreen> {
  String _selectedHall = 'Taluka community hall';
  final TextEditingController _dateController = TextEditingController(text: "2026-08-01T10:00:00.000Z");
  final TextEditingController _seatsController = TextEditingController(text: "60");

  final HallBookingAPI _api = HallBookingAPI();
  final MeetingAPI _meetingApi = MeetingAPI();
  
  bool _isLoading = false;
  List<dynamic> _bookings = [];
  List<dynamic> _meetings = [];
  String? _selectedMeetingId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchBookings(),
      _fetchMeetings(),
    ]);
  }

  Future<void> _fetchMeetings() async {
    try {
      print('DEV DEBUG - _fetchMeetings - hall_coordinator_screen.dart');
      final response = await _meetingApi.getAllMeetings();
      print('DEV DEBUG - _fetchMeetings - Response: $response');
      if (mounted) {
        if (response != null) {
          setState(() {
            if (response is List) {
              _meetings = response;
            } else if (response is Map && response['data'] != null) {
              _meetings = response['data'];
            }
            // Ensure uniqueness
            final uniqueIds = <String>{};
            _meetings.retainWhere((m) => uniqueIds.add(m['meetingId']));
            
            if (_meetings.isNotEmpty && _selectedMeetingId == null) {
              _selectedMeetingId = _meetings.first['meetingId'];
            }
          });
        }
      }
    } catch (e) {
      print('DEV DEBUG - _fetchMeetings - Exception: $e');
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      print('DEV DEBUG - _fetchBookings - hall_coordinator_screen.dart - Fetching all hall bookings');
      final response = await _api.getAllHallBookings();
      if (mounted) {
        if (response != null && response['success'] == true) {
          setState(() {
            _bookings = response['data'] ?? [];
            print('DEV DEBUG - _fetchBookings - Fetched ${_bookings.length} bookings');
          });
        } else {
          setState(() {
            _error = response?['message'] ?? 'Failed to load bookings';
            print('DEV DEBUG - _fetchBookings - Error: $_error');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          print('DEV DEBUG - _fetchBookings - Exception: $_error');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createBooking() async {
    if (_seatsController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final meetingId = _selectedMeetingId ?? widget.meetingId ?? "f63ee114-b9b9-45cb-9c60-f76c16f45c68";
      print('DEV DEBUG - _createBooking - hall_coordinator_screen.dart - Creating booking for $meetingId');
      
      final response = await _api.createHallBooking(
        meetingId: meetingId,
        hallName: _selectedHall,
        bookingDate: _dateController.text,
        seats: int.tryParse(_seatsController.text) ?? 60,
      );

      if (mounted) {
        if (response != null && response['success'] == true) {
          print('DEV DEBUG - _createBooking - Success');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created successfully!')));
          _fetchBookings(); // Refresh
        } else {
          final error = response?['message'] ?? 'Failed to create booking';
          print('DEV DEBUG - _createBooking - Error: $error');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      print('DEV DEBUG - _createBooking - Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBooking(String id) async {
    setState(() => _isLoading = true);
    try {
      print('DEV DEBUG - _deleteBooking - Deleting booking $id');
      final response = await _api.deleteHallBooking(id);
      if (mounted) {
        if (response != null && response['success'] == true) {
          print('DEV DEBUG - _deleteBooking - Success');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking deleted')));
          _fetchBookings();
        } else {
          final error = response?['message'] ?? 'Failed to delete booking';
          print('DEV DEBUG - _deleteBooking - Error: $error');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      print('DEV DEBUG - _deleteBooking - Exception: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Hall Coordinator",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Book the venue for the circle’s meetings. The confirmed hall sets the meeting location and the QR check-in geofence.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.teal.shade900, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Taluka community hall",
                        style: TextStyle(
                          color: Colors.teal.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Thu 24 Jul · 7:30 AM · 60 seats · geo 12.99°N, 77.57°E",
                    style: TextStyle(color: Colors.teal.shade800, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // For Meeting
            Text("For meeting", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _meetings.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("No upcoming meetings found", style: TextStyle(color: Colors.grey, fontSize: 15)),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedMeetingId,
                        hint: const Text("Select a meeting"),
                        items: _meetings.map((meeting) {
                          final dateStr = meeting['date'] != null 
                              ? DateFormat('EEE d MMM · h:mm a').format(DateTime.parse(meeting['date']).toLocal()) 
                              : '';
                          return DropdownMenuItem<String>(
                            value: meeting['meetingId'],
                            child: Text("${meeting['agenda'] ?? 'Circle Meeting'} · $dateStr", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMeetingId = value;
                          });
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Choose Hall
            Text("Choose hall", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildSegmentedButton("Taluka hall"),
                  _buildSegmentedButton("Ward 4 mantapa"),
                  _buildSegmentedButton("FCMCSL office"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inputs Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Seats",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Confirm booking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Booking sets the geofence used for on-site QR check-in.",
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text("Booking history", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // History List
            if (_isLoading && _bookings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_error != null && _bookings.isEmpty)
              Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            else if (_bookings.isEmpty)
              const Center(child: Text("No bookings found", style: TextStyle(color: Colors.grey)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  final id = booking['hallBookingId'] ?? booking['id'] ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(Icons.meeting_room, color: Colors.blue.shade700, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking['hallName'] ?? 'Unknown Hall', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text("${booking['bookingDate'] ?? ''} · ${booking['seats'] ?? 0} seats", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteBooking(id),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedButton(String title) {
    bool isSelected = _selectedHall == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedHall = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

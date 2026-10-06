using System;
using System.IO;

class Program {
    static void Main() {
        string apiPath = "lib/core/api/meeting_api.dart";
        string apiContent = File.ReadAllText(apiPath);
        
        apiContent = apiContent.Replace(
            "Future<dynamic> startMeeting(String meetingId, String userId) async {
    final url = Uri.parse('$baseUrl/startMeeting/$meetingId?userId=$userId');
    print('DEV DEBUG - post - meeting_api.dart - API POST Request to: $url');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
      );",
            "Future<dynamic> startMeeting(String meetingId, String userId, {String? meetingType}) async {
    final url = Uri.parse('$baseUrl/startMeeting/$meetingId');
    print('DEV DEBUG - post - meeting_api.dart - API POST Request to: $url');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': userId,
          if (meetingType != null) 'meetingType': meetingType,
        }),
      );"
        );
        
        apiContent = apiContent.Replace(
            "Future<dynamic> endMeeting(String meetingId, String userId, {String? meetingType}) async {
    String urlStr = '$baseUrl/endMeeting/$meetingId?userId=$userId';
    if (meetingType != null && meetingType.isNotEmpty) {
      urlStr += '&meetingType=${meetingType.toUpperCase()}';
    }
    final url = Uri.parse(urlStr);
    print('DEV DEBUG - post - meeting_api.dart - API POST Request to: $url');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
      );",
            "Future<dynamic> endMeeting(String meetingId, String userId, {String? meetingType}) async {
    final url = Uri.parse('$baseUrl/endMeeting/$meetingId');
    print('DEV DEBUG - post - meeting_api.dart - API POST Request to: $url');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': userId,
          if (meetingType != null && meetingType.isNotEmpty) 'meetingType': meetingType.toUpperCase(),
        }),
      );"
        );

        File.WriteAllText(apiPath, apiContent);
        Console.WriteLine("Updated meeting_api.dart");

        string uiPath = "lib/features/ucn/ucnsubscreens/meeting_detail_screen.dart";
        string uiContent = File.ReadAllText(uiPath);

        // Fix Start Meeting
        uiContent = uiContent.Replace(
            "final success = await _meetingAPI.startMeeting(widget.meeting!.meetingId, currentUser['userId'].toString());
                              setState(() => _isSubmitting = false);
                              if (success != null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Started')));
                                SessionManager.setActiveMeetingId(widget.meeting!.meetingId);
                                Navigator.pop(context, true);
                              }",
            "final success = await _meetingAPI.startMeeting(widget.meeting!.meetingId, currentUser['userId'].toString(), meetingType: widget.meeting!.meetingType);
                              setState(() => _isSubmitting = false);
                              if (success != null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Started')));
                                SessionManager.setActiveMeetingId(widget.meeting!.meetingId);
                                setState(() {
                                  _meetingStatus = 'Started';
                                });
                              }"
        );
        
        // Add _meetingStatus
        uiContent = uiContent.Replace(
            "class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  bool _isSubmitting = false;",
            "class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  bool _isSubmitting = false;
  String _meetingStatus = 'Scheduled';

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      _meetingStatus = widget.meeting!.status;
    }
  }"
        );

        // Replace widget.meeting!.status with _meetingStatus
        uiContent = uiContent.Replace("widget.meeting!.status != 'Started' && widget.meeting!.status != 'Ended'", "_meetingStatus != 'Started' && _meetingStatus != 'Ended'");
        uiContent = uiContent.Replace("widget.meeting!.status == 'Started'", "_meetingStatus == 'Started'");
        uiContent = uiContent.Replace("widget.meeting!.status == 'Ended'", "_meetingStatus == 'Ended'");
        uiContent = uiContent.Replace("widget.meeting!.status.toUpperCase()", "_meetingStatus.toUpperCase()");
        uiContent = uiContent.Replace("Text('Status: ${widget.meeting!.status}'", "Text('Status: $_meetingStatus'");

        File.WriteAllText(uiPath, uiContent);
        Console.WriteLine("Updated meeting_detail_screen.dart");
    }
}

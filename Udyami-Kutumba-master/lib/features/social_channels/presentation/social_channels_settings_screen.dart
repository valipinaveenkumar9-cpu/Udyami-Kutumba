import 'package:flutter/material.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'widgets/marketos_theme.dart';

class SocialChannelsSettingsScreen extends StatefulWidget {
  const SocialChannelsSettingsScreen({super.key});

  @override
  State<SocialChannelsSettingsScreen> createState() => _SocialChannelsSettingsScreenState();
}

class _SocialChannelsSettingsScreenState extends State<SocialChannelsSettingsScreen> {
  final SocialChannelApi _socialApi = SocialChannelApi();
  List<ChannelConnectionItem> _connections = ChannelConnectionItem.defaultConnections();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConnectedAccounts();
  }

  Future<void> _fetchConnectedAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _socialApi.getUserSocialMediaAccounts();
      debugPrint('DEV DEBUG - _fetchConnectedAccounts: Loaded ${accounts.length} accounts');
      
      final updated = _connections.map((conn) {
        final matched = accounts.any((acc) {
          final isMatch = acc.platform.toUpperCase() == conn.platformKey && acc.connected;
          if (acc.platform.toUpperCase() == conn.platformKey) {
            debugPrint('DEV DEBUG - Account found for ${conn.platformKey}: connected=${acc.connected}, isActive=${acc.isActive}. isMatch=$isMatch');
          }
          return isMatch;
        });
        return conn.copyWith(connected: matched);
      }).toList();
      
      if (mounted) {
        setState(() => _connections = updated);
      }
    } catch (e) {
      debugPrint('DEV DEBUG - _fetchConnectedAccounts Error: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showConnectAccountDialog(ChannelConnectionItem conn) async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isConnecting = false;

    final surf = MarketOSTheme.surf(context);
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: surf,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: conn.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(conn.icon, color: conn.color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connect ${conn.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sign in to link your account',
                                style: TextStyle(fontSize: 13, color: muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: usernameCtrl,
                      style: TextStyle(color: text, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Username or email',
                        labelStyle: TextStyle(color: muted, fontSize: 14),
                        filled: true,
                        fillColor: bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: gold, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      style: TextStyle(color: text, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: muted, fontSize: 14),
                        filled: true,
                        fillColor: bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: gold, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isConnecting ? null : () => Navigator.pop(dialogCtx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Cancel', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isConnecting
                              ? null
                              : () async {
                                  final user = usernameCtrl.text.trim();
                                  final pass = passwordCtrl.text;

                                  if (user.isEmpty || pass.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter both username and password.')),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isConnecting = true);

                                  final result = await _socialApi.connectSocialMediaAccount(
                                    platform: conn.platformKey,
                                    username: user,
                                    password: pass,
                                  );

                                  setDialogState(() => isConnecting = false);

                                  if (result['success'] != false) {
                                    Navigator.pop(dialogCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${conn.name} connected successfully. An Admin will review and activate it within 1-2 working days.'),
                                        backgroundColor: const Color(0xFF1F8F5F),
                                      ),
                                    );
                                    
                                    // Optimistic UI update to match web behavior exactly
                                    setState(() {
                                      final index = _connections.indexWhere((c) => c.platformKey == conn.platformKey);
                                      if (index != -1) {
                                        _connections[index] = _connections[index].copyWith(connected: true);
                                      }
                                    });
                                    
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'Connection failed.'),
                                        backgroundColor: const Color(0xFFC23F2C),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isConnecting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surf = MarketOSTheme.surf(context);
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Settings',
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: line, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Accounts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage social channel connections and approval guardrails.',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: line),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _connections.length,
                        separatorBuilder: (_, __) => Divider(color: line, height: 1),
                        itemBuilder: (context, index) {
                          final conn = _connections[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: conn.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(conn.icon, color: conn.color, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conn.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: text,
                                        ),
                                      ),
                                      Text(
                                        conn.connected ? 'Connected' : 'Not connected',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: conn.connected
                                              ? const Color(0xFF1F8F5F)
                                              : muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (!conn.connected) {
                                      _showConnectAccountDialog(conn);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${conn.name} is already connected.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    conn.connected ? 'Manage' : 'Connect',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: gold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

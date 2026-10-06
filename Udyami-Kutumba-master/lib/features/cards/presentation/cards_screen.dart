import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';
import 'package:udyamikutumba/core/models/user_model.dart';

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  // RepaintBoundary key – used to capture the card as an image
  final GlobalKey _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "MY Card",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          children: [
            // ── Card wrapped in RepaintBoundary ──
            RepaintBoundary(
              key: _cardKey,
              child: _MemberCard(),
            ),

            const SizedBox(height: 24),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xffDDE3EA), 
                        width: 1.5
                      ),
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.share_outlined, size: 20),
                    label: Text(
                      "Share Card",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xffDDE3EA), 
                        width: 1.5
                      ),
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to card-only preview page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _CardPreviewPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.download_outlined, size: 20),
                    label: Text(
                      "Download Card",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              "Share your member card with others or download for offline use.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Card-only preview page (shown when Download is tapped)
// ══════════════════════════════════════════════════════
class _CardPreviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Member Card",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
              const ThemeToggleButton(),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.download, color: isDark ? Colors.white : Colors.black, size: 20),
            label: Text("Save",
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _MemberCard(), // _MemberCard now handles its own aspect ratio
        ),
      ),
    );
  }
}



class _MemberCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = SessionManager.user;
    final user = userData != null ? UserModel.fromJson(userData) : null;
    final memberIdStr = user?.memberId ?? "N/A";
    final userName = user?.name ?? "Guest User";
    final userRole = (user?.roles.isNotEmpty ?? false) ? (user?.roles.first.role ?? user?.roles.first.roleName ?? "Member") : "Member";
    final companyName = user?.companyName ?? "Udyami Kutumba";
    final userLocation = user?.businessLocation ?? user?.officeLocation ?? "N/A";
    final profileImage = user?.profileImage ?? user?.image;
    final qrData = "UDYAMI KUTUMBA: ID $memberIdStr";

    return AspectRatio(
      aspectRatio: 1.586, // Standard ATM/PAN Card Ratio
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16), // Softer corners for smaller size
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 500,
            height: 315.25, // 500 / 1.586
            child: Stack(
              children: [
                // ── Decorative blob (top-right) ──
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00897B).withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00897B).withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // ── Card content ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──
                      Row(
                        children: [
                          // Logo
                          Image.asset(
                            "assets/logo/uk_logo_white_bg_1584x672.png",
                            height: 34,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.eco, color: Colors.teal, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Brand name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "UDYAMI KUTUMBA",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  "One Home. One Enterprise.",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Verified badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100, 
                                width: 1.5
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined, color: Color(0xff00897B), size: 13),
                                SizedBox(width: 4),
                                Text(
                                  "VERIFIED",
                                  style: TextStyle(
                                    color: Color(0xff00897B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      Divider(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffEEF2F7), 
                        height: 1
                      ),
                      const Spacer(),

                      // ── Body row: Photo | Details+QR ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Left: Photo + Ward ──
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Profile photo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 100,
                                  height: 125,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffEEF2F7),
                                  child: profileImage != null && profileImage.isNotEmpty
                                      ? Image.network(
                                          profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Image.network(
                                          "https://ui-avatars.com/api/?background=random&name=${Uri.encodeComponent(userName)}",
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Ward label
                              Row(
                                children: [
                                  Icon(Icons.radio_button_unchecked, color: Colors.grey.shade500, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "WARD",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 10,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Color(0xff00897B), size: 14),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 82, // constraints text to not overflow past photo width
                                    child: Text(
                                      userLocation,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(width: 20),

                          // ── Right: Member details + QR ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // MEMBER label
                                Text(
                                  "MEMBER",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Name
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: Color(0xff00897B),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Role
                                Text(
                                  userRole,
                                  style: TextStyle(
                                    color: Color(0xff00897B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Company
                                Text(
                                  companyName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // ID badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xff00897B),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "ID $memberIdStr",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.surface,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),

                                    // QR code
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Dialog(
                                              backgroundColor: Colors.transparent,
                                              insetPadding: EdgeInsets.zero,
                                              elevation: 0,
                                              child: Center(
                                                child: Container(
                                                  height: 300,
                                                  width: 300,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Theme.of(context).colorScheme.surface,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100, 
                                                      width: 2
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.3),
                                                        blurRadius: 20,
                                                        offset: const Offset(0, 10),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets.all(24),
                                                  child: QrImageView(
                                                    data: qrData,
                                                    version: QrVersions.auto,
                                                    eyeStyle: QrEyeStyle(
                                                      eyeShape: QrEyeShape.square,
                                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                                    ),
                                                    dataModuleStyle: QrDataModuleStyle(
                                                      dataModuleShape: QrDataModuleShape.square,
                                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                                    ),
                                                    backgroundColor: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade100, 
                                            width: 1.5
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: QrImageView(
                                          data: qrData,
                                          version: QrVersions.auto,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape: QrEyeShape.square,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: QrDataModuleShape.square,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                          ),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      Divider(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xffEEF2F7), 
                        height: 1
                      ),
                      const Spacer(),

                      // ── Tagline ──
                      const Center(
                        child: Text(
                          "One Home. One Enterprise. One Strong Nation.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff00897B),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


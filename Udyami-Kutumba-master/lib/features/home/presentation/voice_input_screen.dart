import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:udyamikutumba/core/api/requirements/requirements_api.dart';
import 'package:udyamikutumba/core/utils/session_manager.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  bool _hasSpeech = false;
  double level = 0.0;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  bool _isSubmitting = false;

  final SpeechToText speech = SpeechToText();
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;

  // ── Source options (must match backend accepted values) ──
  String _selectedSource = 'Voice-to-Chat';
  final List<String> _sourceOptions = [
    'Voice-to-Chat',
    'Meeting notes',
    'Email',
    'Other',
  ];

  // ── Category options (must match backend accepted values) ──
  String _selectedCategory = 'Finance';
  final List<String> _categoryOptions = [
    'Finance',
    'Business',
    'Employment',
    'Infrastructure',
    'Education',
    'Health',
    'Agriculture',
    'Technology',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    initSpeechState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    speech.cancel();
    super.dispose();
  }

  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
      );
      if (hasSpeech) {
        speech.unexpectedPhraseAggregator = _punctAggregator;
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  String _punctAggregator(List<String> phrases) {
    return phrases.join('. ');
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
      onSoundLevelChange: soundLevelListener,
    );
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    final detected = _detectCategoryFromText(result.recognizedWords);
    setState(() {
      lastWords = result.recognizedWords;
      _textController.text = lastWords;
      if (detected != null) {
        _selectedCategory = detected;
      }
    });
  }

  /// Scans recognized text for category keywords and returns the best match.
  String? _detectCategoryFromText(String text) {
    final lower = text.toLowerCase();

    // Finance keywords
    if (RegExp(
      r'loan|finance|financial|fund|funding|investment|invest|bank|credit|capital|money|rupee|lakh|crore|budget|grant|subsidy|insurance|deposit|borrow|debt|mortgage|equity|dividend|revenue|profit|loss|account|savings|expenditure|income|tax|interest|emi|payment|cash|wealth|pension|provident',
    ).hasMatch(lower)) {
      return 'Finance';
    }

    // Health keywords
    if (RegExp(
      r'health|hospital|doctor|medicine|medical|clinic|treatment|disease|illness|injury|surgery|patient|nurse|pharmacy|drug|prescription|diagnosis|therapy|wellness|healthcare|ambulance|emergency|vaccination|vaccine|sanitation|hygiene|mental health|disability|dental|eye|blood|cancer|diabetes|heart|bp|blood pressure|covid|fever|pain|infection',
    ).hasMatch(lower)) {
      return 'Health';
    }

    // Employment keywords
    if (RegExp(
      r'job|employ|employment|work|worker|salary|wage|hire|hiring|staff|career|vacancy|recruit|recruitment|labour|labor|skill|training|profession|occupation|apprentice|internship|fresher|experience|resume|cv|interview|placement|workforce',
    ).hasMatch(lower)) {
      return 'Employment';
    }

    // Infrastructure keywords
    if (RegExp(
      r'infrastructure|road|bridge|building|construction|water supply|drainage|sewer|electricity|power|light|street light|transport|bus|railway|metro|flyover|highway|tower|network|internet|broadband|pipeline|housing|shelter|land|plot|compound|boundary|gate|public toilet|sanitation|waste|garbage',
    ).hasMatch(lower)) {
      return 'Infrastructure';
    }

    // Education keywords
    if (RegExp(
      r'education|school|college|university|study|student|teacher|learning|scholarship|course|degree|class|exam|admission|library|book|notebook|stationery|syllabus|curriculum|academic|tuition|coaching|literacy|knowledge|skill development|vocational|digital literacy|e-learning|online class',
    ).hasMatch(lower)) {
      return 'Education';
    }

    // Agriculture keywords
    if (RegExp(
      r'agriculture|farm|farmer|crop|seed|fertilizer|pesticide|irrigation|harvest|land|soil|water|field|cattle|livestock|poultry|dairy|kisan|kisaan|agri|organic|greenhouse|horticulture|floriculture|sericulture|fishery|aquaculture|mandi|market price|tractor|equipment|storage|warehouse|cold storage',
    ).hasMatch(lower)) {
      return 'Agriculture';
    }

    // Technology keywords
    if (RegExp(
      r'technology|tech|software|app|application|website|digital|computer|mobile|phone|device|internet|online|cloud|ai|machine learning|data|database|code|program|developer|startup|innovation|automation|robot|iot|sensor|hardware|network|cybersecurity|blockchain|ecommerce|e-commerce|platform',
    ).hasMatch(lower)) {
      return 'Technology';
    }

    // Business keywords
    if (RegExp(
      r'business|company|enterprise|shop|store|trade|market|product|service|supplier|vendor|client|customer|partner|contract|deal|export|import|manufacture|production|factory|industry|commercial|office|branding|marketing|advertisement|promotion|franchise',
    ).hasMatch(lower)) {
      return 'Business';
    }

    return null; // no match — keep current selection
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = error.errorMsg;
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  // ── API Submit ────────────────────────────────────────────
  Future<void> _submitRequirement() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please speak or type your requirement first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = SessionManager.user?['userId'] as String?;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await RequirementsAPI.createRequirement(
      userId: userId,
      requirement: text,
      category: _selectedCategory,
      source: _selectedSource,
      status: 'Pending',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      _textController.clear();
      lastWords = '';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF8A2BE2)),
              SizedBox(width: 8),
              Text('Submitted!'),
            ],
          ),
          content: const Text(
            'Your requirement has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF8A2BE2)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit requirement.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isListening = speech.isListening;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildMicrophone(isListening),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        isListening ? 'Listening...' : 'Tap microphone to start',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                            ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 260.0, 70.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Speak clearly and naturally',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildTextBox(),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Source',
                      _selectedSource,
                      _sourceOptions,
                      (val) {
                        if (val != null) {
                          setState(() => _selectedSource = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Category',
                      _selectedCategory,
                      _categoryOptions,
                      (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoBox(),
                    const SizedBox(height: 24),
                    _buildSendButton(),
                    if (lastError.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        lastError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Voice Input',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  color: Color(0xFF8A2BE2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Microphone ─────────────────────────────────────────────
  Widget _buildMicrophone(bool isListening) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isListening) ...[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 +
                      (_animationController.value * 0.5) +
                      (level / 20.0),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF1493).withValues(alpha: 0.1),
                    ),
                  ),
                );
              },
            ),
          ],
          GestureDetector(
            onTap: () {
              if (!_hasSpeech) {
                initSpeechState();
              } else if (isListening) {
                stopListening();
              } else {
                startListening();
              }
            },
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE7F6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Text Box ───────────────────────────────────────────────
  Widget _buildTextBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF1493).withValues(alpha: 0.4),
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _textController,
            maxLines: 5,
            minLines: 4,
            decoration: InputDecoration(
              hintText:
                  'I want to create a new post about today\'s meeting...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 12,
            child: Icon(
              Icons.edit,
              color: const Color(0xFF8A2BE2),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown ───────────────────────────────────────────────
  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              items: options.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Box ───────────────────────────────────────────────
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF5C6BC0), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can edit the text before sending.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Send Button ────────────────────────────────────────────
  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRequirement,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isSubmitting
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/api/communications/communications_api.dart';
import '../../../core/utils/session_manager.dart';
import '../models/wallet_model.dart';
import '../models/bulk_campaign_model.dart';
import '../models/campaign.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunicationsViewModel extends ChangeNotifier {
  final CommunicationsAPI _api = CommunicationsAPI();

  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;

  List<Map<String, dynamic>> localRecharges = [];

  List<BulkCampaignModel> _campaigns = [];
  List<BulkCampaignModel> get campaigns => _campaigns;

  List<Campaign> _campaignHistory = [];
  List<Campaign> get campaignHistory => _campaignHistory;

  bool _isLoadingWallet = false;
  bool get isLoadingWallet => _isLoadingWallet;

  bool _isLoadingCampaigns = false;
  bool get isLoadingCampaigns => _isLoadingCampaigns;

  // --- Campaign Builder State ---
  String? newCampaignChannel;
  String campaignInputType = 'manual'; // 'manual' or 'csv'
  String? newCampaignSubject;
  String? newCampaignMessage;
  String? newCampaignTemplateId;
  List<String> newCampaignMemberIds = [];
  List<String> newCampaignUploadIds = [];
  String? newCampaignScheduledAt;
  String? newCampaignVoiceFileId;
  PlatformFile? selectedFile;
  PlatformFile? selectedVoiceFile;
  String? uploadErrorMessage;
  
  List<dynamic> uploadedCsvData = [];
  bool isLoadingCsvData = false;

  void startNewCampaign(String channel) {
    print('DEV DEBUG - CommunicationsViewModel: Starting new campaign builder for channel: $channel');
    newCampaignChannel = channel;
    campaignInputType = 'manual';
    newCampaignSubject = null;
    newCampaignMessage = null;
    newCampaignTemplateId = null;
    newCampaignMemberIds = [];
    newCampaignUploadIds = [];
    newCampaignScheduledAt = null;
    newCampaignVoiceFileId = null;
    selectedFile = null;
    selectedVoiceFile = null;
    uploadErrorMessage = null;
    uploadedCsvData = [];
    notifyListeners();
  }

  Future<void> fetchWalletData() async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) {
      print('DEV DEBUG - CommunicationsViewModel: No user in SessionManager');
      return;
    }
    final userId = user['userId'].toString();

    _isLoadingWallet = true;
    notifyListeners();

    try {
      print('DEV DEBUG - CommunicationsViewModel: Fetching wallet data for $userId');
      final response = await _api.getWalletData(userId);
      await _loadLocalRecharges(userId);
      
      if (response != null && response['success'] != false) {
        final walletData = response['data'] ?? response;
        if (walletData != null && walletData is Map<String, dynamic>) {
          _wallet = WalletModel.fromJson(walletData);
          print('DEV DEBUG - CommunicationsViewModel: Fetched wallet successfully. Coins: ${_wallet?.coins}');
        } else {
          _wallet = WalletModel(userId: userId, coins: 0);
          print('DEV DEBUG - CommunicationsViewModel: Empty wallet data, defaulting to 0 coins.');
        }
      } else {
        // Wallet not found (404) - auto-create one
        final statusCode = response?['statusCode'];
        if (statusCode == 404) {
          print('DEV DEBUG - CommunicationsViewModel: Wallet not found, auto-creating wallet for $userId');
          final createResponse = await _api.addWalletData(userId, 0);
          if (createResponse != null && createResponse['success'] != false) {
            print('DEV DEBUG - CommunicationsViewModel: Wallet created successfully, re-fetching...');
            final reFetch = await _api.getWalletData(userId);
            if (reFetch != null && reFetch['success'] != false) {
              final walletData = reFetch['data'] ?? reFetch;
              if (walletData != null && walletData is Map<String, dynamic>) {
                _wallet = WalletModel.fromJson(walletData);
                print('DEV DEBUG - CommunicationsViewModel: Re-fetched wallet. Coins: ${_wallet?.coins}');
              } else {
                _wallet = WalletModel(userId: userId, coins: 0);
              }
            } else {
              _wallet = WalletModel(userId: userId, coins: 0);
            }
          } else {
            _wallet = WalletModel(userId: userId, coins: 0);
            print('DEV DEBUG - CommunicationsViewModel: Failed to auto-create wallet.');
          }
        } else {
          _wallet = WalletModel(userId: userId, coins: 0);
          print('DEV DEBUG - CommunicationsViewModel: API returned failure or null for wallet, defaulting to 0.');
        }
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error fetching wallet - $e');
    } finally {
      _isLoadingWallet = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocalRecharges(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('local_recharges_$userId');
    if (data != null) {
      try {
        final List decoded = jsonDecode(data);
        localRecharges = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        localRecharges = [];
      }
    }
  }

  Future<void> _addLocalRecharge(String userId, int coins) async {
    localRecharges.insert(0, {
      'amount': coins,
      'date': DateTime.now().toIso8601String(),
      'title': 'Coin pack — Recharge',
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_recharges_$userId', jsonEncode(localRecharges));
  }

  Future<bool> addWalletCoins(int coinsToAdd) async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) return false;
    final userId = user['userId'].toString();

    try {
      print('DEV DEBUG - CommunicationsViewModel: Adding $coinsToAdd coins for $userId');
      final response = await _api.addWalletData(userId, coinsToAdd);
      if (response != null && (response['success'] == true || response['statusCode'] == 201)) {
        print('DEV DEBUG - CommunicationsViewModel: Coins added successfully');
        await _addLocalRecharge(userId, coinsToAdd);
        // Refresh wallet data to get updated balance
        await fetchWalletData();
        return true;
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error adding coins - $e');
    }
    return false;
  }

  Future<void> fetchAllCampaigns() async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) return;
    final userId = user['userId'].toString();

    _isLoadingCampaigns = true;
    notifyListeners();

    try {
      print('DEV DEBUG - CommunicationsViewModel: Fetching campaigns for $userId');
      final response = await _api.getAllCampaigns(userId: userId);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        List data = [];
        if (rawData is Map) {
          data = rawData['data'] ?? [];
        } else if (rawData is List) {
          data = rawData;
        }
        _campaigns = data.map((json) => BulkCampaignModel.fromJson(json)).toList();
        print('DEV DEBUG - CommunicationsViewModel: Fetched ${_campaigns.length} campaigns successfully');
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error fetching campaigns - $e');
    } finally {
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }

  Future<void> fetchCampaignHistory() async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) return;
    final userId = user['userId'].toString();

    _isLoadingCampaigns = true;
    notifyListeners();

    try {
      print('DEV DEBUG - CommunicationsViewModel: Fetching campaign history for $userId');
      final response = await _api.getCampaignReport(userId);
      if (response != null && (response['success'] == true || response['statusCode'] == 200)) {
        final data = response['data'];
        List rawList = [];
        if (data is Map) {
          rawList = data['data'] ?? [];
        } else if (data is List) {
          rawList = data;
        }

        Map<String, Map<String, dynamic>> campaignGroups = {};
        Map<String, List<dynamic>> campaignRecipients = {};

        for (var item in rawList) {
          if (item == null || item['campaign'] == null) continue;
          final campaignJson = item['campaign'];
          final campaignId = campaignJson['campaignId'];
          if (campaignId == null) continue;
          
          if (!campaignGroups.containsKey(campaignId)) {
             campaignGroups[campaignId] = Map<String, dynamic>.from(campaignJson);
             campaignRecipients[campaignId] = [];
          }
          
          // Add this recipient to the campaign's list
          campaignRecipients[campaignId]!.add(item);
        }

        _campaignHistory = campaignGroups.values.map<Campaign>((json) {
          String campaignId = json['campaignId'] ?? '';
          String channelStr = json['channel'] ?? 'Unknown';
          String uiChannel = channelStr;
          IconData icon = Icons.campaign;
          if (channelStr.toUpperCase() == 'EMAIL') {
            uiChannel = 'Bulk Email';
            icon = Icons.email_rounded;
          } else if (channelStr.toUpperCase() == 'SMS') {
            uiChannel = 'Bulk SMS';
            icon = Icons.sms_rounded;
          } else if (channelStr.toUpperCase() == 'WHATSAPP') {
            uiChannel = 'WhatsApp';
            icon = Icons.chat_rounded;
          } else if (channelStr.toUpperCase() == 'IVR') {
            uiChannel = 'Voice IVR';
            icon = Icons.record_voice_over_rounded;
          }

          String dbStatus = (json['adminStatus'] ?? json['status'] ?? 'pending').toString().toUpperCase();
          String statusText = "Sending";
          MaterialColor statusColor = Colors.orange;

            if (dbStatus == 'COMPLETED' || dbStatus == 'DELIVERED' || dbStatus == 'APPROVED') {
              statusText = dbStatus == 'APPROVED' ? "Approved" : "Completed";
              statusColor = Colors.green;
            } else if (dbStatus == 'FAILED' || dbStatus == 'REJECTED') {
              statusText = dbStatus == 'REJECTED' ? "Rejected" : "Failed";
              statusColor = Colors.red;
            } else if (dbStatus == 'PENDING' || dbStatus == 'DRAFT' || dbStatus == 'SENDING') {
              statusText = dbStatus == 'PENDING' ? "Pending" : "Sending";
              statusColor = Colors.orange;
            } else if (dbStatus == 'IN_PROGRESS') {
              statusText = "In Progress";
              statusColor = Colors.blue;
            } else {
              statusText = dbStatus.replaceAll('_', ' ').toLowerCase();
              statusText = statusText.substring(0, 1).toUpperCase() + statusText.substring(1);
              statusColor = Colors.blue;
            }
          
          int totalRecipients = json['totalRecipients'] ?? 0;
          int totalCoinDeducted = json['totalCoinDeducted'] ?? 0;
          
          final recipientsList = campaignRecipients[campaignId] ?? [];
          if (totalRecipients == 0 && recipientsList.isNotEmpty) {
             totalRecipients = recipientsList.length;
          }
          
          return Campaign(
            id: campaignId,
            title: "$uiChannel Campaign",
            channel: channelStr.toUpperCase(),
            subtitle: "Sent on ${json['createdAt'] != null ? json['createdAt'].toString().split('T').first : 'N/A'}",
            statusText: statusText,
            statusColor: statusColor,
            icon: icon,
            recipientsText: "$totalRecipients Members",
            coinsSpent: totalCoinDeducted,
            submittedDate: json['createdAt']?.toString().split('T').first ?? "Recently",
            verifiedText: "Approved by Admin",
            sendingText: "Sending messages",
            reportText: "Available soon",
            uploadIds: json['uploadIds'] != null ? List<String>.from(json['uploadIds']) : [],
            recipients: recipientsList,
            primaryStats: [
               CampaignStats(label: "Requested", value: "$totalRecipients"),
               CampaignStats(label: "Coins charged", value: "$totalCoinDeducted"),
            ],
            secondaryStats: [
              CampaignStats(label: "Completed", value: "${json['successCount'] ?? 0}"),
              CampaignStats(label: "Failed", value: "${json['failedCount'] ?? 0}"),
            ]
          );
        }).toList();
        
        // Sort by creation date descending
        _campaignHistory.sort((a, b) => b.subtitle.compareTo(a.subtitle));

        // Dedup by ID just in case
        final seen = <String>{};
        _campaignHistory.retainWhere((c) => seen.add(c.id));

        print('DEV DEBUG - CommunicationsViewModel: Mapped ${_campaignHistory.length} campaigns to UI history');
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error fetching campaign history - $e');
    } finally {
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }

  Future<bool> createCampaign(BulkCampaignModel newCampaign) async {
    try {
      print('DEV DEBUG - CommunicationsViewModel: Creating campaign');
      final response = await _api.createBulkCampaign(newCampaign.toJson());
      if (response != null && (response['success'] == true || response['statusCode'] == 201)) {
        print('DEV DEBUG - CommunicationsViewModel: Campaign created successfully');
        await fetchCampaignHistory();
        return true;
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error creating campaign - $e');
    }
    return false;
  }

  String mapChannelToApi(String uiChannel) {
    switch (uiChannel) {
      case 'Bulk Email': return 'EMAIL';
      case 'Bulk SMS': return 'SMS';
      case 'WhatsApp':
      case 'Meta WhatsApp': return 'WHATSAPP';
      case 'Voice IVR':
      case 'Interactive IVR': return 'IVR';
      default: return uiChannel.toUpperCase().replaceAll(' ', '_');
    }
  }

  Future<bool> uploadSelectedFile() async {
    if (selectedFile == null || selectedFile!.path == null) {
      print('DEV DEBUG - CommunicationsViewModel: No file selected to upload');
      uploadErrorMessage = "No CSV file selected.";
      return false;
    }

    final isIvr = newCampaignChannel == 'Voice IVR' || newCampaignChannel == 'Interactive IVR';
    if (isIvr && (selectedVoiceFile == null || selectedVoiceFile!.path == null)) {
      print('DEV DEBUG - CommunicationsViewModel: No voice file selected for IVR');
      uploadErrorMessage = "No voice file (MP3) selected for IVR campaign.";
      return false;
    }

    try {
      print('DEV DEBUG - CommunicationsViewModel: Parsing local CSV file for review: ${selectedFile!.name}');
      
      // Parse CSV Locally for Step 2 Review
      uploadedCsvData.clear();
      
      if (selectedFile!.path != null) {
        String fileContent;
        try {
          fileContent = await File(selectedFile!.path!).readAsString();
        } catch (e) {
          final bytes = await File(selectedFile!.path!).readAsBytes();
          fileContent = utf8.decode(bytes, allowMalformed: true);
        }
        
        final lines = fileContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
        
        if (lines.length > 1) {
          final headers = lines.first.split(',').map((e) => e.trim()).toList();
          
          for (int i = 1; i < lines.length; i++) {
            final values = lines[i].split(',');
            Map<String, dynamic> row = {};
            for (int j = 0; j < headers.length && j < values.length; j++) {
              row[headers[j]] = values[j].trim();
            }
            uploadedCsvData.add(row);
          }
        }
        print('DEV DEBUG - CommunicationsViewModel: Successfully parsed ${uploadedCsvData.length} rows locally');
      }

      return true;

    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error parsing CSV locally - $e');
      uploadErrorMessage = "Failed to read CSV file.";
      return false;
    }
  }

  Future<Map<String, dynamic>?> finalizeCampaignUpload() async {
    if (selectedFile == null || selectedFile!.path == null) {
      return null;
    }

    final isIvr = newCampaignChannel == 'Voice IVR' || newCampaignChannel == 'Interactive IVR';
    final apiChannel = mapChannelToApi(newCampaignChannel ?? 'EMAIL');
    final user = SessionManager.user;
    final userId = user?['userId']?.toString() ?? "";

    try {
      print('DEV DEBUG - CommunicationsViewModel: Finalizing Campaign Upload to DB...');
      
      final csvMultipartFile = await http.MultipartFile.fromPath(
        'file',
        selectedFile!.path!,
      );

      http.MultipartFile? voiceMultipartFile;
      if (isIvr && selectedVoiceFile != null) {
        voiceMultipartFile = await http.MultipartFile.fromPath(
          'voiceFile',
          selectedVoiceFile!.path!,
        );
      }

      final response = await _api.uploadCsvData(
        userId: userId,
        channel: apiChannel,
        scheduledAt: newCampaignScheduledAt ?? DateTime.now().toUtc().toIso8601String(),
        subject: newCampaignSubject,
        message: newCampaignMessage,
        templateId: newCampaignTemplateId,
        file: csvMultipartFile,
        voiceFile: voiceMultipartFile,
      );

      if (response != null && (response['success'] == true || (response['success'] == null && response['statusCode'] == 201))) {
        print('DEV DEBUG - CommunicationsViewModel: Campaign submitted successfully to DB');
        
        // Print Actual API Deductions
        try {
          if (response['campaign'] != null && response['campaign']['data'] != null) {
            final campaignData = response['campaign']['data'];
            final actualRecipients = campaignData['totalRecipients'];
            final actualCoinsDeducted = campaignData['totalCoins'];
            final finalWalletBalance = campaignData['walletBalance'];
            
            print('DEV DEBUG - CommunicationsViewModel: --- CAMPAIGN ACTUAL RESULTS ---');
            print('DEV DEBUG - CommunicationsViewModel: Messages Requested/Sent: $actualRecipients');
            print('DEV DEBUG - CommunicationsViewModel: Coins Reduced/Deducted: $actualCoinsDeducted');
            print('DEV DEBUG - CommunicationsViewModel: New Wallet Balance: $finalWalletBalance');
          }
        } catch (e) {
          print('DEV DEBUG - CommunicationsViewModel: Error parsing campaign deduction response: $e');
        }

        await fetchCampaignHistory();
        if (userId.isNotEmpty) {
          await fetchWalletData(); // Refresh wallet
        }
        return response;
      } else {
        uploadErrorMessage = response != null && response['message'] != null ? response['message'].toString() : "Unknown API error";
        
        // Extract detailed errors from failedRecords if available
        try {
          if (response != null && response['failedRecords'] != null && (response['failedRecords'] as List).isNotEmpty) {
            final firstFailed = response['failedRecords'][0];
            if (firstFailed['errors'] != null && (firstFailed['errors'] as List).isNotEmpty) {
              final detailedError = firstFailed['errors'][0].toString();
              uploadErrorMessage = "$uploadErrorMessage ($detailedError)";
            }
          }
        } catch (_) {}

        return null;
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error finalizing campaign upload - $e');
      return null;
    }
  }

  Future<void> fetchUploadedCsvData() async {
    final user = SessionManager.user;
    if (user == null || user['userId'] == null) return;
    final userId = user['userId'].toString();

    isLoadingCsvData = true;
    notifyListeners();

    try {
      print('DEV DEBUG - CommunicationsViewModel: Fetching uploaded CSV data for $userId');
      final response = await _api.getUploadedCsvDataForUser(userId);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          if (data is Map) {
            uploadedCsvData = data['data'] ?? [data];
          } else if (data is List) {
            uploadedCsvData = data;
          } else {
            uploadedCsvData = [data];
          }
          
          if (uploadedCsvData.isNotEmpty) {
            final firstRecord = uploadedCsvData[0];
            if (firstRecord is Map && firstRecord['uploadId'] != null) {
              newCampaignUploadIds = [firstRecord['uploadId']];
              print('DEV DEBUG - CommunicationsViewModel: Set newCampaignUploadIds to $newCampaignUploadIds');
            }
          }
        } else {
          uploadedCsvData = [];
        }
        print('DEV DEBUG - CommunicationsViewModel: Fetched ${uploadedCsvData.length} records');
        
        // As a fallback, if we didn't get uploadId from upload API, grab it from the fetched data
        if (newCampaignUploadIds.isEmpty && uploadedCsvData.isNotEmpty) {
           final firstRecord = uploadedCsvData[0];
           if (firstRecord['uploadId'] != null) {
             newCampaignUploadIds = [firstRecord['uploadId']];
           } else if (firstRecord['_id'] != null) {
             newCampaignUploadIds = [firstRecord['_id']];
           }
        }
      }
    } catch (e) {
      print('DEV DEBUG - CommunicationsViewModel: Error fetching CSV data - $e');
    } finally {
      isLoadingCsvData = false;
      notifyListeners();
    }
  }
}

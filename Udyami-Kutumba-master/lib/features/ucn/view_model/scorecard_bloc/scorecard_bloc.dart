import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/ubn/scorecard_api.dart';
import '../../../../core/api/ubn/lead_api.dart';
import '../../../../core/api/ubn/face_to_face_api.dart';
import '../../../../core/api/ubn/guest_api.dart';
import '../../../../core/api/ubn/gratitude_api.dart';
import '../../../../core/utils/session_manager.dart';
import 'scorecard_event.dart';
import 'scorecard_state.dart';

class ScorecardBloc extends Bloc<ScorecardEvent, ScorecardState> {
  final ScorecardApi _api;

  ScorecardBloc(this._api) : super(ScorecardInitial()) {
    on<FetchScorecardData>(_onFetchScorecardData);
  }

  Future<void> _onFetchScorecardData(
    FetchScorecardData event,
    Emitter<ScorecardState> emit,
  ) async {
    print('DEV DEBUG - ScorecardBloc - FetchScorecardData event received');
    emit(ScorecardLoading());
    
    try {
      final user = SessionManager.user;
      print('DEV DEBUG - ScorecardBloc - Current User from Session: $user');
      
      final userId = user?['userId']?.toString();
      String? wardName = user?['ward']?.toString() ?? user?['wardName']?.toString();
      
      if (userId == null || userId.isEmpty) {
        print('DEV DEBUG - ScorecardBloc - Error: User ID is null or empty');
        emit(const ScorecardError("User ID not found."));
        return;
      }

      if (wardName == null || wardName.isEmpty) {
        try {
           print('DEV DEBUG - ScorecardBloc - Ward name empty in session, fetching user profile to get ward...');
           final profileRes = await _api.get('/userprofile/getUserProfileById/$userId');
           if (profileRes != null && profileRes['success'] == true) {
              wardName = profileRes['data']?['profile']?['ward']?.toString();
           }
        } catch(e) {
           print('DEV DEBUG - ScorecardBloc - Failed to fetch profile for ward: $e');
        }
      }

      // Ensure we have a human-readable ward name instead of a UUID (Ward ID)
      if (wardName != null && wardName.isNotEmpty) {
        final isUuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(wardName!);
        if (isUuid) {
          try {
            print('DEV DEBUG - ScorecardBloc - Resolving ward UUID via LocationAPI for: $wardName');
            
            // 1. We need the user's district to query the lightweight LocationAPI
            final profileRes = await _api.get('/userprofile/getUserProfileById/$userId');
            if (profileRes != null && profileRes['success'] == true) {
              final districtName = profileRes['data']?['profile']?['district']?.toString();
              
              if (districtName != null && districtName.isNotEmpty) {
                // 2. Fetch all districts to find the matching districtId
                final distRes = await _api.get('/district/getAllDistricts');
                if (distRes != null && distRes['success'] == true) {
                  final List rawDistricts = distRes['data'] ?? [];
                  final dMap = rawDistricts.firstWhere(
                    (d) => d['districtName'] == districtName, 
                    orElse: () => <String, dynamic>{},
                  ) as Map<String, dynamic>;
                  
                  final districtId = dMap['districtId']?.toString();
                  if (districtId != null && districtId.isNotEmpty) {
                    // 3. Fetch talukas & wards for this district (lightweight, no GeoJSON)
                    final talukaRes = await _api.get('/district/getAllDistricts?districtId=$districtId');
                    if (talukaRes != null && talukaRes['success'] == true) {
                      final List rawTalukas = talukaRes['data'] ?? [];
                      bool found = false;
                      for (var t in rawTalukas) {
                        if (t is Map<String, dynamic>) {
                          final List wards = t['wards'] ?? [];
                          for (var w in wards) {
                            if (w is Map<String, dynamic>) {
                              final wId = w['wardId']?.toString() ?? w['id']?.toString();
                              if (wId == wardName) {
                                wardName = w['wardName']?.toString() ?? w['name']?.toString() ?? wardName;
                                print('DEV DEBUG - ScorecardBloc - Resolved Ward ID to Name: $wardName');
                                found = true;
                                break;
                              }
                            }
                          }
                        }
                        if (found) break;
                      }
                    }
                  }
                }
              }
            }
          } catch (e) {
            print('DEV DEBUG - ScorecardBloc - Failed to resolve ward name via LocationAPI: $e');
          }
        } else {
          print('DEV DEBUG - ScorecardBloc - Ward is already a name, no resolution needed: $wardName');
        }
      }

      print('DEV DEBUG - ScorecardBloc - Extracted userId: $userId, final wardName: $wardName');

      print('DEV DEBUG - ScorecardBloc - Fetching scorecard for userId: $userId');
      final scorecardResponse = await _api.getScorecard(userId);
      
      print('DEV DEBUG - ScorecardBloc - Fetching scoring weights');
      final weightsResponse = await _api.getAllScoringWeights();
      
      dynamic leaderboardResponse;
      if (wardName != null && wardName.isNotEmpty) {
        print('DEV DEBUG - ScorecardBloc - Fetching leaderboard for ward: $wardName');
        leaderboardResponse = await _api.getWardLeaderboard(wardName, limit: 10); // Changed limit to 10 for more data
      } else {
        print('DEV DEBUG - ScorecardBloc - Ward name is empty, skipping leaderboard fetch');
      }

      if (scorecardResponse is Map && scorecardResponse['success'] == false) {
        print('DEV DEBUG - ScorecardBloc - API returned explicit error: ${scorecardResponse['message']} | ${scorecardResponse['error']} | Code: ${scorecardResponse['statusCode']}');
        emit(ScorecardError(scorecardResponse['message'] ?? "Failed to fetch scorecard."));
        return;
      } else if (scorecardResponse == null) {
        print('DEV DEBUG - ScorecardBloc - Scorecard response is null.');
        emit(const ScorecardError("Scorecard response is null."));
        return;
      }

      print('DEV DEBUG - ScorecardBloc - Scorecard API Response Data Structure check. Starting calculations...');
      try {
        final score = scorecardResponse.score;
        final attendance = scorecardResponse.attendance;
        final leads = scorecardResponse.leads;
        final guests = scorecardResponse.guests;
        final f2f = scorecardResponse.faceToFace;
        final gratitude = scorecardResponse.gratitudeSlips;

        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> Total Score: ${score.total}/${score.max} (Level: ${score.level})');
        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> Attendance: ${attendance.achieved}/${attendance.total} | ${attendance.percentage}% | Pts: ${attendance.score}/${attendance.maxScore}');
        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> Leads: ${leads.achieved}/${leads.target} | ${leads.percentage}% | Pts: ${leads.score}/${leads.maxScore}');
        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> Guests: ${guests.achieved}/${guests.target} | ${guests.percentage}% | Pts: ${guests.score}/${guests.maxScore}');
        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> F2F: ${f2f.achieved}/${f2f.target} | ${f2f.percentage}% | Pts: ${f2f.score}/${f2f.maxScore}');
        print('DEV DEBUG - ScorecardBloc [Calculation Check] -> Gratitude: ${gratitude.formattedValue} (Target: ${gratitude.target}) | ${gratitude.percentage}% | Pts: ${gratitude.score}/${gratitude.maxScore}');
        
        if (leaderboardResponse != null && leaderboardResponse.success) {
           print('DEV DEBUG - ScorecardBloc [Leaderboard Check] -> Fetched ${leaderboardResponse.data?.leaderboard.length ?? 0} users in leaderboard for ward: ${leaderboardResponse.data?.ward}');
        } else {
           print('DEV DEBUG - ScorecardBloc [Leaderboard Check] -> Leaderboard response is null or failed.');
        }
      } catch(e) {
        print('DEV DEBUG - ScorecardBloc - Exception while logging calculations: $e');
      }

      print('DEV DEBUG - ScorecardBloc - Successfully fetched scorecard data. Emitting ScorecardLoaded state.');
      emit(ScorecardLoaded(
        scorecard: scorecardResponse,
        scoringWeightsResponse: (weightsResponse is Map && weightsResponse['success'] == false) ? null : weightsResponse,
        leaderboardResponse: (leaderboardResponse is Map && leaderboardResponse['success'] == false) ? null : leaderboardResponse,
      ));

      // Asynchronously trigger cross-check prints from raw UCN APIs
      _runRawDataCrossCheck(userId, user?['name']?.toString()?.toLowerCase()?.trim() ?? '');

    } catch (e) {
      print('DEV DEBUG - ScorecardBloc - Exception during fetching data (all possible ways catch block): $e');
      emit(ScorecardError(e.toString()));
    }
  }

  Future<void> _runRawDataCrossCheck(String currentUserId, String currentUserName) async {
    print('DEV DEBUG - ScorecardBloc [CROSS-CHECK] - Starting background fetch of raw UCN data for validation...');
    try {
      // FACE TO FACE
      final allMeetings = await FaceToFaceAPI.getAllFaceToFaceMeetings();
      final givenInvites = allMeetings.where((m) => m.createdUser != null && m.createdUser!['userId'] == currentUserId).toList();
      final receivedInvites = allMeetings.where((m) {
        if (m.invitedMember != null) return m.invitedMember!['userId'] == currentUserId;
        return m.memberName.toLowerCase().trim() == currentUserName;
      }).toList();
      int f2fGivenCompleted = givenInvites.where((m) => m.status.toLowerCase() == 'completed').length;
      int f2fReceivedCompleted = receivedInvites.where((m) => m.status.toLowerCase() == 'completed').length;
      print('DEV DEBUG - UCN Action Screen (FACE_TO_FACE) [SCORECARD CROSS-CHECK] - Given: ${givenInvites.length} (Completed: $f2fGivenCompleted) | Received: ${receivedInvites.length} (Completed: $f2fReceivedCompleted)');

      // LEADS
      final allLeads = await LeadAPI.getAllLeads();
      final givenLeads = allLeads.where((lead) => lead.createdUser != null && lead.createdUser!['userId'] == currentUserId).toList();
      final receivedLeads = allLeads.where((lead) => lead.memberName.toLowerCase().trim() == currentUserName).toList();
      int leadsGivenClosed = givenLeads.where((m) => m.status.toLowerCase() == 'closed' || m.status.toLowerCase() == 'converted').length;
      int leadsReceivedClosed = receivedLeads.where((m) => m.status.toLowerCase() == 'closed' || m.status.toLowerCase() == 'converted').length;
      print('DEV DEBUG - UCN Action Screen (LEAD_GIVEN) [SCORECARD CROSS-CHECK] - Given: ${givenLeads.length} (Closed/Converted: $leadsGivenClosed) | Received: ${receivedLeads.length} (Closed/Converted: $leadsReceivedClosed)');

      // GUESTS
      final guestRes = await GuestAPI.getAllGuests();
      if (guestRes != null && guestRes['success'] == true) {
         final data = guestRes['data'] as List? ?? [];
         var allGuests = data.where((g) => g['createdUser']?['userId'] == currentUserId).toList();
         int joinedGuests = allGuests.where((g) => g['status'].toString().toLowerCase() == 'joined').length;
         print('DEV DEBUG - UCN Action Screen (GUEST_BROUGHT/JOINED) [SCORECARD CROSS-CHECK] - Total Brought: ${allGuests.length} (Joined: $joinedGuests)');
      }

      // GRATITUDE
      final allSlips = await GratitudeAPI.getAllGratitudeSlips();
      final givenSlips = allSlips.where((s) => s.createdUser?.userId == currentUserId).toList();
      final receivedSlips = allSlips.where((s) => s.thankYouMember?.userId == currentUserId).toList();
      double totalGivenVal = givenSlips.fold(0, (sum, s) => sum + (s.businessValue ?? 0));
      double totalReceivedVal = receivedSlips.fold(0, (sum, s) => sum + (s.businessValue ?? 0));
      print('DEV DEBUG - UCN Action Screen (GRATITUDE_SLIP) [SCORECARD CROSS-CHECK] - Given: ${givenSlips.length} (₹$totalGivenVal) | Received: ${receivedSlips.length} (₹$totalReceivedVal)');
      
      print('DEV DEBUG - ScorecardBloc [CROSS-CHECK] - Completed raw data fetch validation.');
    } catch(e) {
      print('DEV DEBUG - ScorecardBloc [CROSS-CHECK] - Error during cross-check fetch: $e');
    }
  }
}

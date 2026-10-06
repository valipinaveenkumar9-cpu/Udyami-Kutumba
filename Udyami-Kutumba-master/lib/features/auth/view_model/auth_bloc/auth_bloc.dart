import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/api/auth/auth_api.dart';
import '../../../../core/api/api.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/utils/test_config.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String? _currentMobileNumber;

  AuthBloc() : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetAuthEvent>(_onResetAuth);
  }

  void _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    print(
      'DEV DEBUG - _onSendOtp - auth_bloc.dart - Sending OTP for: ${event.mobileNumber}',
    );
    emit(AuthLoading());

    // Check for test number to bypass OTP sending
    if (TestConfig.isTestNumber(event.mobileNumber)) {
      _currentMobileNumber = event.mobileNumber;
      print('DEV DEBUG - _onSendOtp - auth_bloc.dart - Test number detected, skipping sendOtp');
      emit(OtpSentState(event.mobileNumber, isTestMode: true));
      return;
    }

    try {
      final authApi = AuthAPI();
      final exists = await authApi.checkUserExists(event.mobileNumber);
      if (!exists) {
        emit(const AuthError('The given phone number is not registered.'));
        return;
      }

      final response = await authApi.sendOtp(event.mobileNumber, 'LOGIN');
      if (response != null && response['success'] == true) {
        _currentMobileNumber = event.mobileNumber;
        print(
          'DEV DEBUG - _onSendOtp - auth_bloc.dart - OTP sent successfully',
        );
        emit(OtpSentState(event.mobileNumber));
      } else {
        emit(AuthError(response?['message'] ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError('Failed to send OTP: $e'));
      return;
    }
  }

  void _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    print(
      'DEV DEBUG - _onVerifyOtp - auth_bloc.dart - Verifying OTP: ${event.otp}',
    );
    if (_currentMobileNumber == null) {
      print(
        'DEV DEBUG - _onVerifyOtp - auth_bloc.dart - Error: No mobile number found',
      );
      emit(const AuthError('Something went wrong, please try again.'));
      return;
    }

    emit(AuthLoading());
    try {
      final authApi = AuthAPI();

      dynamic response;

      // Check if it's the test number to bypass verifyOtp
      if (TestConfig.isTestNumber(_currentMobileNumber!)) {
        if (event.otp != '123456') {
          emit(OtpVerificationError('Invalid OTP for test number', _currentMobileNumber!));
          return;
        }
        // Call loginUser directly with testMode
        response = await authApi.login(
          _currentMobileNumber!,
          otp: event.otp,
          testMode: true,
        );
      } else {
        // 1. Verify real-time OTP first
        final verifyResponse = await authApi.verifyOtp(
          _currentMobileNumber!,
          event.otp,
          'LOGIN',
        );
        if (verifyResponse == null || verifyResponse['success'] != true) {
          final errorMsg = verifyResponse?['message'] ?? 'Invalid OTP';
          emit(OtpVerificationError(errorMsg, _currentMobileNumber!));
          return;
        }

        // 2. Call loginUser with OTP and verificationId to get token
        final verificationId = verifyResponse['verificationId']?.toString();
        final isTestMode = verifyResponse['testMode'] == true;
        response = await authApi.login(
          _currentMobileNumber!,
          otp: event.otp,
          verificationId: verificationId,
          testMode: isTestMode,
        );
      }

      if (response != null && response['success'] != false) {
        print(
          'DEV DEBUG - _onVerifyOtp - auth_bloc.dart - OTP verified via API successfully',
        );

        final token = response['accessToken'] as String?;
        final user = response['user'] as Map<String, dynamic>?;

        if (token != null && user != null) {
          final userModel = UserModel.fromJson(user);
          final roleNames = userModel.roles
              .map((r) => r.role ?? r.roleName)
              .join(', ');
          print(
            'DEV DEBUG - _onVerifyOtp - auth_bloc.dart - Logged in User Roles: $roleNames',
          );

          await SessionManager.saveSession(token, user);
          print(
            'DEV DEBUG - _onVerifyOtp - auth_bloc.dart - Session saved locally',
          );

          // Check for pending profile data and upload it
          final pendingProfile = SessionManager.pendingProfileData;
          if (pendingProfile != null) {
            print(
              'DEV DEBUG - _onVerifyOtp - Uploading pending profile data...',
            );
            try {
              final fieldsData = pendingProfile['fields'];
              final Map<String, String> fields = {};
              if (fieldsData != null && fieldsData is Map) {
                fieldsData.forEach(
                  (k, v) => fields[k.toString()] = v.toString(),
                );
              }

              final List<dynamic>? bImagePaths =
                  pendingProfile['businessImagePaths'];
              final profileImagePath = pendingProfile['profileImagePath'];

              final files = <http.MultipartFile>[];
              if (profileImagePath != null) {
                files.add(
                  await http.MultipartFile.fromPath(
                    'profileImage',
                    profileImagePath.toString(),
                  ),
                );
              }
              if (bImagePaths != null && bImagePaths.isNotEmpty) {
                for (var path in bImagePaths) {
                  files.add(
                    await http.MultipartFile.fromPath(
                      'businessImages',
                      path.toString(),
                    ),
                  );
                }
              }

              await ApiClient().postMultipart(
                '/userprofile/createUserProfile',
                fields: fields,
                files: files,
              );

              await SessionManager.clearPendingProfileData();
              print(
                'DEV DEBUG - _onVerifyOtp - Pending profile uploaded successfully',
              );
            } catch (e) {
              print('Error uploading pending profile: $e');
            }
          }
        }

        emit(OtpVerifiedState());
      } else {
        final errorMsg =
            response?['error'] ?? 'Login failed after OTP verification';
        print('DEV DEBUG - _onVerifyOtp - auth_bloc.dart - Error: $errorMsg');
        emit(OtpVerificationError(errorMsg, _currentMobileNumber!));
      }
    } catch (e) {
      emit(
        OtpVerificationError(
          'OTP verification failed: $e',
          _currentMobileNumber!,
        ),
      );
    }
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    print('DEV DEBUG - _onResetAuth - auth_bloc.dart - Resetting Auth state');
    _currentMobileNumber = null;
    emit(AuthInitial());
  }
}

import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String mobileNumber;
  final bool isTestMode;
  const OtpSentState(this.mobileNumber, {this.isTestMode = false});

  @override
  List<Object> get props => [mobileNumber, isTestMode];
}

class OtpVerifiedState extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class OtpVerificationError extends AuthState {
  final String message;
  final String mobileNumber;
  const OtpVerificationError(this.message, this.mobileNumber);

  @override
  List<Object> get props => [message, mobileNumber];
}

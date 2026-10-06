import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String mobileNumber;
  const SendOtpEvent(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;
  const VerifyOtpEvent(this.otp);

  @override
  List<Object> get props => [otp];
}

class ResetAuthEvent extends AuthEvent {}

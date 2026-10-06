class NetworkUtils {
  static const bool isProduction = true;
  static const bool usePhysical = false; // Set to true if testing on a real physical device
  
  static const String _liveApiURL = 'https://backend.udyamikutumba.com';
  static const String _emulatorApiURL = 'http://192.168.0.70:3000';
  static const String _physicalApiURL = 'http://192.168.0.70:3000';

  static const String _razorpayLiveKey = 'rzp_live_TRvLVjCWjNNUOs';
  static const String _razorpayTestKey = 'rzp_test_TM1R0RlEholgfI';

  static String get baseUrl { 
    if (isProduction) return _liveApiURL;
    return usePhysical ? _physicalApiURL : _emulatorApiURL;
  }
  
  static String get razorpayKey {
    return isProduction ? _razorpayLiveKey : _razorpayTestKey;
  }
}

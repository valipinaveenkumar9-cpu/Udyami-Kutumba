class TestConfig {
  static const List<String> testMobileNumbers = [
    '9999999999',
    '7339244560', //ms
    '6383436841', //essaki
    '9346234886', //naveen
    '9112768829', //suraj
    '7349625941', //Yashwanth
  ];

  static bool isTestNumber(String mobileNumber) {
    return testMobileNumbers.contains(mobileNumber);
  }
}

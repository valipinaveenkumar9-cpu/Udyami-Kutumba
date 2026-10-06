import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://backend.udyamikutumba.com/udyami-members/getAllUdyamiMembers?limit=10');
  try {
    final response = await http.get(url);
    print(response.body);
  } catch (e) {
    print(e);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://backend.udyamikutumba.com/ward/getAllWards?wardName=Mathikere'));
  print('getAllWards with search: ${res.statusCode} ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}');
  
  final res2 = await http.get(Uri.parse('https://backend.udyamikutumba.com/ward/map/Mathikere?type=ward'));
  print('getWardMap: ${res2.statusCode} ${res2.body.length > 200 ? res2.body.substring(0, 200) : res2.body}');
}

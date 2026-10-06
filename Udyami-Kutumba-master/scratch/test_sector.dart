import 'dart:convert';
import 'dart:io';
void main() async {
  final request = await HttpClient().getUrl(Uri.parse('https://backend.udyamikutumba.com/sector/getAllSectors'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final data = jsonDecode(responseBody);
  print(jsonEncode(data['data'][0]).substring(0, 500));
}

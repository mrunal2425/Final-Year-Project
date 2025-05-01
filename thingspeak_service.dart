import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  final String writeApiKey = 'J6MCP9CAN7O9NAMK';
  final String readApiKey = 'BNFGKF7OFXQSOPTE';
  final String channelId = '2892720';

  // Update lamp state (ON/OFF)
  Future<void> updateLampState(bool isLampOn) async {
    try {
      final int field1Value = isLampOn ? 1 : 0;
      final response = await http.get(
        Uri.parse(
            'https://api.thingspeak.com/update?api_key=$writeApiKey&field1=$field1Value'),
      );

      if (response.statusCode == 200) {
        print('Lamp state updated successfully');
      } else {
        print('Failed to update lamp state: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating lamp state: $e');
    }
  }

  // Read lamp state
  Future<bool> getLampState() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.thingspeak.com/channels/$channelId/fields/1.json?api_key=$readApiKey&results=1'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final field1 = jsonResponse['feeds'][0]['field1'];
        return field1 == '1';
      } else {
        print('Failed to read lamp state: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error reading lamp state: $e');
      return false;
    }
  }
}


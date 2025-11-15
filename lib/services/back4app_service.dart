import 'dart:convert';
import 'package:http/http.dart' as http;

class Back4AppService {
  static const String appId = "api_id";
  static const String apiKey = "api_key";
  static const String serverUrl = "https://parseapi.back4app.com";

  Map<String, String> get _baseHeaders => {
    "X-Parse-Application-Id": appId,
    "X-Parse-REST-API-Key": apiKey,
    "Content-Type": "application/json",
  };

  Future<Map<String, dynamic>?> signUp(String email, String password) async {
    final res = await http.post(
      Uri.parse("$serverUrl/users"),
      headers: _baseHeaders,
      body: jsonEncode({
        "username": email,
        "password": password,
        "email": email,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await http.get(
      Uri.parse(
        "$serverUrl/login?username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}",
      ),
      headers: _baseHeaders,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> createTask(
    String title,
    String description,
    String sessionToken,
    String userId,
  ) async {
    final headers = {..._baseHeaders, "X-Parse-Session-Token": sessionToken};
    final body = jsonEncode({
      "title": title,
      "description": description,
      "owner": {"__type": "Pointer", "className": "_User", "objectId": userId},
    });
    final res = await http.post(
      Uri.parse("$serverUrl/classes/Task"),
      headers: headers,
      body: body,
    );
    return res.statusCode == 201;
  }

  Future<List<dynamic>> getTasks(String sessionToken, String userId) async {
    final headers = {..._baseHeaders, "X-Parse-Session-Token": sessionToken};
    final where = jsonEncode({
      "owner": {"__type": "Pointer", "className": "_User", "objectId": userId},
    });
    final res = await http.get(
      Uri.parse("$serverUrl/classes/Task?where=${Uri.encodeComponent(where)}"),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body["results"] as List<dynamic>;
    }
    return [];
  }

  Future<bool> updateTask(
    String objectId,
    String title,
    String description,
    String sessionToken,
  ) async {
    final headers = {..._baseHeaders, "X-Parse-Session-Token": sessionToken};
    final body = jsonEncode({"title": title, "description": description});
    final res = await http.put(
      Uri.parse("$serverUrl/classes/Task/$objectId"),
      headers: headers,
      body: body,
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteTask(String objectId, String sessionToken) async {
    final headers = {..._baseHeaders, "X-Parse-Session-Token": sessionToken};
    final res = await http.delete(
      Uri.parse("$serverUrl/classes/Task/$objectId"),
      headers: headers,
    );
    return res.statusCode == 200;
  }
}

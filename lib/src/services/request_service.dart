import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/request.dart';
import 'request_notifier.dart'; // <-- 1. IMPORTER LE NOTIFICATEUR

class RequestService {
  static const String _key = "user_requests";

  static Future<List<Request>> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => Request.fromMap(json.decode(e))).toList();
  }

  static Future<void> addRequest(Request request) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(json.encode(request.toMap()));
    await prefs.setStringList(_key, data);

    requestNotifier.value++; // <-- 2. ENVOYER LE SIGNAL
  }

  static Future<void> updateStatus(String id, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    List<Request> requests = data.map((e) => Request.fromMap(json.decode(e))).toList();
    final index = requests.indexWhere((req) => req.id == id);

    if (index != -1) {
      requests[index] = requests[index].copyWith(status: newStatus);
    }

    final newData = requests.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_key, newData);

    requestNotifier.value++; // <-- 3. ENVOYER LE SIGNAL
  }
}
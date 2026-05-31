import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IbadahProvider extends ChangeNotifier {
String baseUrl = "https://taqwatrack.my.id/api";

  List ibadahList = [];
  bool isLoading = false;

  Future<void> ambilIbadah(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/ibadah"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token", //siapa pengguna minta yg data
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ibadahList = data["data"];
      }
    } catch (e) {
      print("Error ambil ibadah: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleIbadah({
    required String token,
    required int ibadahId,
  }) async {
    final tanggal = DateTime.now().toString().substring(0, 10);

    final index = ibadahList.indexWhere((item) => item["id"] == ibadahId);
    if (index == -1) return;

    final oldValue = ibadahList[index]["is_checked"];

    ibadahList[index]["is_checked"] = !oldValue;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ibadah/toggle"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "ibadah_id": ibadahId.toString(),
          "tanggal": tanggal,
        },
      );

      if (response.statusCode != 200) {
        ibadahList[index]["is_checked"] = oldValue;
        notifyListeners();
      }
    } catch (e) {
      ibadahList[index]["is_checked"] = oldValue;
      notifyListeners();
    }
  }
}
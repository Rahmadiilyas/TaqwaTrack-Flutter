import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taqwatrack/model/dzikir_model.dart';

class DzikirController {
  final String baseUrl = "https://taqwatrack.my.id/api/dzikir";

  Future<List<DzikirModel>> ambilDzikir() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Accept": "application/json",
      },
    );

    print("STATUS DZIKIR: ${response.statusCode}");
    print("BODY DZIKIR: ${response.body}");

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      List data = [];

      if (hasil is Map && hasil["data"] is List) {
        data = hasil["data"];
      } else if (hasil is List) {
        data = hasil;
      }

      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return DzikirModel.fromJson(item);
        }

        if (item is Map) {
          return DzikirModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        }

        return DzikirModel(
          id: 0,
          judul: "-",
          arab: "-",
          arti: "-",
        );
      }).toList();
    } else {
      throw Exception("Gagal mengambil data dzikir");
    }
  }
}
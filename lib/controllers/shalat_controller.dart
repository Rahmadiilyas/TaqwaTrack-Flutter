import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taqwatrack/model/shalat_model.dart';
import 'package:taqwatrack/service/notifikasi_service.dart';

class ShalatController {
  String tambahMenit(String waktu, int menitTambah) {
    if (waktu == "-" || !waktu.contains(":")) {
      return waktu;
    }

    final bagian = waktu.split(":");
    final jam = int.parse(bagian[0]);
    final menit = int.parse(bagian[1]);

    final hasil = DateTime(
      2026,
      1,
      1,
      jam,
      menit,
    ).add(Duration(minutes: menitTambah));

    final jamBaru = hasil.hour.toString().padLeft(2, '0');
    final menitBaru = hasil.minute.toString().padLeft(2, '0');

    return "$jamBaru:$menitBaru";
  }

  Future<ShalatModel?> ambilJadwalShalat(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        "https://api.aladhan.com/v1/timings"
        "?latitude=$latitude"
        "&longitude=$longitude"
        "&method=20",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShalatModel.fromJson(data);
      } else {
        print("Gagal mengambil jadwal shalat");
        return null;
      }
    } catch (e) {
      print("Error jadwal shalat: $e");
      return null;
    }
  }

  Future<void> aturNotifikasiShalat({
    required String subuh,
    required String dzuhur,
    required String ashar,
    required String maghrib,
    required String isya,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final aktif = prefs.getBool("notifikasi_aktif") ?? false;

    if (aktif) {
      await NotifikasiService.batalkanJadwalShalat();

      final notifSubuh = prefs.getBool("notif_subuh") ?? false;
      final notifDzuhur = prefs.getBool("notif_dzuhur") ?? false;
      final notifAshar = prefs.getBool("notif_ashar") ?? false;
      final notifMaghrib = prefs.getBool("notif_maghrib") ?? false;
      final notifIsya = prefs.getBool("notif_isya") ?? false;

      print("AKTIF GLOBAL: $aktif");
      print("NOTIF SUBUH: $notifSubuh");
      print("NOTIF DZUHUR: $notifDzuhur");
      print("NOTIF ASHAR: $notifAshar");
      print("NOTIF MAGHRIB: $notifMaghrib");
      print("NOTIF ISYA: $notifIsya");
      print("JAM SUBUH YANG DIJADWALKAN: $subuh");
      print("JAM DZUHUR YANG DIJADWALKAN: $dzuhur");
      print("JAM ASHAR YANG DIJADWALKAN: $ashar");
      print("JAM MAGHRIB YANG DIJADWALKAN: $maghrib");
      print("JAM ISYA YANG DIJADWALKAN: $isya");

      if (notifSubuh) {
        await NotifikasiService.jadwalkanNotifikasiShalat(
          namaShalat: "Subuh",
          jamShalat: subuh,
        );
      }

      if (notifDzuhur) {
        await NotifikasiService.jadwalkanNotifikasiShalat(
          namaShalat: "Dzuhur",
          jamShalat: dzuhur,
        );
      }

      if (notifAshar) {
        await NotifikasiService.jadwalkanNotifikasiShalat(
          namaShalat: "Ashar",
          jamShalat: ashar,
        );
      }

      if (notifMaghrib) {
        await NotifikasiService.jadwalkanNotifikasiShalat(
          namaShalat: "Maghrib",
          jamShalat: maghrib,
        );
      }

      if (notifIsya) {
        await NotifikasiService.jadwalkanNotifikasiShalat(
          namaShalat: "Isya",
          jamShalat: isya,
        );
      }

      await NotifikasiService.cekJadwalAktif();

      print("Notifikasi shalat pilihan berhasil dijadwalkan");
    }
  }

  Map<String, dynamic> hitungMundurShalat({
    required String subuh,
    required String dzuhur,
    required String ashar,
    required String maghrib,
    required String isya,
  }) {
    DateTime sekarang = DateTime.now();

    if (subuh == "-" ||
        dzuhur == "-" ||
        ashar == "-" ||
        maghrib == "-" ||
        isya == "-") {
      return {
        "shalatBerikutnya": "",
        "waktuShalatBerikutnya": "",
        "sisaWaktuShalat": Duration.zero,
      };
    }

    DateTime ubahJam(String waktu) {
      List<String> bagian = waktu.split(":");
      int jam = int.parse(bagian[0]);
      int menit = int.parse(bagian[1]);

      return DateTime(
        sekarang.year,
        sekarang.month,
        sekarang.day,
        jam,
        menit,
      );
    }

    Map<String, DateTime> jadwalShalat = {
      "Subuh": ubahJam(subuh),
      "Dzuhur": ubahJam(dzuhur),
      "Ashar": ubahJam(ashar),
      "Maghrib": ubahJam(maghrib),
      "Isya": ubahJam(isya),
    };

    for (var item in jadwalShalat.entries) {
      if (item.value.isAfter(sekarang)) {
        String jam = item.value.hour.toString().padLeft(2, '0');
        String menit = item.value.minute.toString().padLeft(2, '0');

        return {
          "shalatBerikutnya": item.key,
          "waktuShalatBerikutnya": "$jam:$menit",
          "sisaWaktuShalat": item.value.difference(sekarang),
        };
      }
    }

    DateTime subuhBesok = ubahJam(subuh).add(const Duration(days: 1));

    return {
      "shalatBerikutnya": "Subuh",
      "waktuShalatBerikutnya": subuh,
      "sisaWaktuShalat": subuhBesok.difference(sekarang),
    };
  }
}
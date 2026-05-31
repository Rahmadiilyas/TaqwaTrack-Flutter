import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  static const Color hijau = Color(0xff03715E);

  double? arahKiblat;
  String status = "Mengambil lokasi...";

  @override
  void initState() {
    super.initState();
    ambilLokasiDanHitungKiblat();
  }

  Future<void> ambilLokasiDanHitungKiblat() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          status = "GPS belum aktif. Aktifkan lokasi/GPS terlebih dahulu.";
        });
        return;
      }

      LocationPermission izin = await Geolocator.checkPermission();

      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }

      if (izin == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          status = "Izin lokasi ditolak.";
        });
        return;
      }

      if (izin == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          status =
              "Izin lokasi ditolak permanen. Aktifkan izin lokasi dari pengaturan aplikasi.";
        });
        return;
      }

      final posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final hasil = hitungArahKiblat(
        posisi.latitude,
        posisi.longitude,
      );

      if (!mounted) return;

      setState(() {
        arahKiblat = hasil;
        status = "Arah kiblat berhasil dihitung.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = "Gagal mengambil arah kiblat: $e";
      });
    }
  }

  double hitungArahKiblat(double lat, double lng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;

    final double latRad = lat * pi / 180;
    final double lngRad = lng * pi / 180;
    final double kaabaLatRad = kaabaLat * pi / 180;
    final double kaabaLngRad = kaabaLng * pi / 180;

    final double deltaLng = kaabaLngRad - lngRad;

    final double y = sin(deltaLng);
    final double x = cos(latRad) * tan(kaabaLatRad) -
        sin(latRad) * cos(deltaLng);

    double bearing = atan2(y, x) * 180 / pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF4FA),
      appBar: AppBar(
        backgroundColor: hijau,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Arah Kiblat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final double? arahKompas = snapshot.data?.heading;

          double sudutPanah = 0;

          if (arahKompas != null && arahKiblat != null) {
            sudutPanah = ((arahKiblat! - arahKompas) * pi / 180);
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Kompas Kiblat",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hijau.withOpacity(0.08),
                        border: Border.all(
                          color: hijau.withOpacity(0.35),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: sudutPanah,
                          child: const Icon(
                            Icons.navigation_rounded,
                            size: 120,
                            color: hijau,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      arahKiblat == null
                          ? "Arah kiblat belum tersedia"
                          : "Arah kiblat: ${arahKiblat!.toStringAsFixed(2)}°",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      arahKompas == null
                          ? "Kompas tidak tersedia / sensor belum terbaca"
                          : "Arah perangkat: ${arahKompas.toStringAsFixed(2)}°",
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 22),

                    if (arahKompas == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Sensor kompas belum terbaca. Pastikan menggunakan HP asli, bukan emulator, dan HP memiliki sensor magnetometer.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: hijau.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: hijau,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Kalibrasi kompas dengan menggerakkan HP seperti angka 8 agar arah lebih akurat.",
                                style: TextStyle(
                                  color: hijau,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
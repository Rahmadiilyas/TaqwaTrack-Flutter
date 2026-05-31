  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:hijri/hijri_calendar.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:geocoding/geocoding.dart';
  import 'package:analog_clock/analog_clock.dart';

  import 'package:taqwatrack/controllers/shalat_controller.dart';
  import 'package:taqwatrack/kiblat_page.dart';

  class HalamanShalat extends StatefulWidget {
    final VoidCallback onMenuTap;

    const HalamanShalat({super.key, required this.onMenuTap});

    @override
    State<HalamanShalat> createState() => _HalamanShalatState();
  }

  class _HalamanShalatState extends State<HalamanShalat> {
    Timer? timer;
    final ShalatController shalatController = ShalatController();

    String shubuh = "-";
    String dzuhur = "-";
    String ashar = "-";
    String magrib = "-";
    String isya = "-";

    String shalatBerikutnya = "";
    String waktuShalatBerikutnya = "";
    Duration sisaWaktuShalat = Duration.zero;

    String kabupaten = "";
    String Provinsi = "";
    String statusLokasi = "";

    DateTime waktuSekarang = DateTime.now();
    HijriCalendar hijri = HijriCalendar.now();

    @override
    void initState() {
      super.initState();

      getlokasi();
      hitungMundurShalat();

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;

        setState(() {
          waktuSekarang = DateTime.now();
          hitungMundurShalat();
        });
      });
    }

    @override
    void dispose() {
      timer?.cancel();
      super.dispose();
    }

    Future<void> ambilJadwalShalat(double latitude, double longitude) async {
      final hasil = await shalatController.ambilJadwalShalat(
        latitude,
        longitude,
      );

      if (hasil == null) return;
      if (!mounted) return;

      setState(() {
        shubuh = shalatController.tambahMenit(hasil.subuh, 3);
        dzuhur = shalatController.tambahMenit(hasil.dzuhur, 3);
        ashar = shalatController.tambahMenit(hasil.ashar, 3);
        magrib = shalatController.tambahMenit(hasil.maghrib, 3);
        isya = shalatController.tambahMenit(hasil.isya, 3);
      });

      await shalatController.aturNotifikasiShalat(
        subuh: shubuh,
        dzuhur: dzuhur,
        ashar: ashar,
        maghrib: magrib,
        isya: isya,
      );

      hitungMundurShalat();
    }

    Future<void> getlokasi() async {
      try {
        setState(() {
          statusLokasi = "Memuat lokasi...";
        });

        LocationPermission izin;

        izin = await Geolocator.checkPermission();

        if (izin == LocationPermission.denied) {
          izin = await Geolocator.requestPermission();
        }

        if (izin == LocationPermission.denied) {
          if (!mounted) return;

          setState(() {
            statusLokasi = "Gagal memuat lokasi";
          });
          return;
        }

        if (izin == LocationPermission.deniedForever) {
          if (!mounted) return;

          setState(() {
            statusLokasi = "Gagal memuat lokasi";
          });
          return;
        }

        Position posisi = await Geolocator.getCurrentPosition();

        List<Placemark> lokasi = await placemarkFromCoordinates(
          posisi.latitude,
          posisi.longitude,
        );

        Placemark tempat = lokasi.first;

        if (!mounted) return;

        setState(() {
          kabupaten = (tempat.subAdministrativeArea ?? '')
              .replaceFirst('Kabupaten ', '')
              .replaceFirst('Kota ', '');
          Provinsi = tempat.administrativeArea ?? '';
          statusLokasi = "";
        });

        ambilJadwalShalat(posisi.latitude, posisi.longitude);
      } catch (e) {
        if (!mounted) return;

        setState(() {
          statusLokasi = "Gagal memuat lokasi";
          kabupaten = "";
          Provinsi = "";
        });
      }
    }

    void hitungMundurShalat() {
      final hasil = shalatController.hitungMundurShalat(
        subuh: shubuh,
        dzuhur: dzuhur,
        ashar: ashar,
        maghrib: magrib,
        isya: isya,
      );

      shalatBerikutnya = hasil["shalatBerikutnya"];
      waktuShalatBerikutnya = hasil["waktuShalatBerikutnya"];
      sisaWaktuShalat = hasil["sisaWaktuShalat"];
    }

    Widget countdownShalat() {
      String jam = sisaWaktuShalat.inHours.toString().padLeft(2, '0');
      String menit = sisaWaktuShalat.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      String detik = sisaWaktuShalat.inSeconds
          .remainder(60)
          .toString()
          .padLeft(2, '0');

      return Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "$jam:$menit:$detik",
            maxLines: 1,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      );
    }

    Widget jamDigital() {
      String jam = waktuSekarang.hour.toString().padLeft(2, '0');
      String menit = waktuSekarang.minute.toString().padLeft(2, '0');
      String detik = waktuSekarang.second.toString().padLeft(2, '0');

      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "$jam : $menit : $detik",
          maxLines: 1,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 31,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget cardAtas() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: widget.onMenuTap,
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                "TaqwaTrack",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KiblatPage(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore_rounded,
            size: 16,
            color: Color(0xff03715E),
          ),
          SizedBox(width: 5),
          Text(
            "Kiblat",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xff03715E),
            ),
          ),
        ],
      ),
    ),
  ),
          ],
        ),
      );
    }

    Widget cardkedua() {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 3,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColor.hijau, size: 42),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "TaqwaTrack",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    Text(
                      "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Container(width: 2, height: 48, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        statusLokasi.isNotEmpty ? statusLokasi : kabupaten,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      Text(
                        statusLokasi.isNotEmpty ? "" : Provinsi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
    }

    Widget jamSekarang() {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 132,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Image.asset("img/gambar1.png", fit: BoxFit.cover),
                ),
                Container(color: Colors.black.withOpacity(0.5)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      AnalogClock(
                        width: 112,
                        height: 112,
                        isLive: true,
                        showSecondHand: true,
                        showTicks: true,
                        showNumbers: true,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xffD8C3A5),
                            width: 7,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        numberColor: Colors.blue,
                        hourHandColor: Colors.black,
                        minuteHandColor: Colors.black,
                        secondHandColor: Colors.grey,
                        textScaleFactor: 1.1,
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Jam Sekarang",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          jamDigital(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget Cardketiga() {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 190,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset("img/gambar2.png", fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.5)),
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    children: [
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "MENUJU WAKTU SHALAT BERIKUTNYA",
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            height: 112,
                            width: MediaQuery.of(context).size.width * 0.46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(11),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 19,
                                        backgroundColor: Colors.black,
                                        child: Icon(
                                          Icons.hourglass_bottom,
                                          color: Colors.white,
                                          size: 21,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      countdownShalat(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Expanded(
                                    child: Text(
                                      "Bersiaplah untuk menunaikan shalat yah",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    shalatBerikutnya.toUpperCase(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 27,
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    waktuShalatBerikutnya,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 27,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget itemJadwal(String gambar, String nama, String jam) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Image.asset(gambar, width: 24, height: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 1,
              child: Text(
                ":",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                jam,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    Widget jadwalShalat() {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 2,
                color: Colors.grey,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 22, right: 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff03715E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      color: AppColor.hijau,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Jadwal Shalat",
                          maxLines: 1,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff03715E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                itemJadwal("img/shubuh.png", "Shubuh", shubuh),
                itemJadwal("img/dzuhur.png", "Dzuhur", dzuhur),
                itemJadwal("img/ashar.png", "Ashar", ashar),
                itemJadwal("img/magrib.png", "Magrib", magrib),
                itemJadwal("img/isya.png", "Isya", isya),
              ],
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffEEF4FA),
          body: Stack(
            children: [
              Container(height: 145, color: const Color(0xff03715E)),
              SafeArea(
                child: Column(
                  children: [

                    cardAtas(),
                    
                    cardkedua(),
                    jamSekarang(),
                    Cardketiga(),
                    jadwalShalat(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class AppColor {
    static const hijau = Color(0xff03715E);
  }
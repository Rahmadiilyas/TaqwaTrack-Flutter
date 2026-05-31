import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifikasiService {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // WITA / Sulawesi
    tz.setLocalLocation(tz.getLocation('Asia/Makassar'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notif.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'STOP_ADZAN') {
          await _notif.cancel(response.id ?? 0);
        }
      },
    );
  }

  static Future<bool> mintaIzinNotifikasi() async {
    final androidPlugin = _notif.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final hasil = await androidPlugin?.requestNotificationsPermission();

    return hasil ?? true;
  }

  static int getIdShalat(String namaShalat) {
    final nama = namaShalat.toLowerCase();

    if (nama == 'subuh' || nama == 'shubuh') return 101;
    if (nama == 'dzuhur') return 102;
    if (nama == 'ashar') return 103;
    if (nama == 'maghrib' || nama == 'magrib') return 104;
    if (nama == 'isya') return 105;

    return 999;
  }

  // NOTIFIKASI SUBUH - suara khusus
  static const AndroidNotificationDetails androidSubuhDetails =
      AndroidNotificationDetails(
    'channel_adzan_shubuh_stop_v3',
    'Adzan Subuh',
    channelDescription: 'Notifikasi waktu Subuh dengan suara adzan Subuh',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('adzan_shubuh'),
    autoCancel: false,
    ongoing: true,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'STOP_ADZAN',
        'Stop',
        cancelNotification: true,
      ),
    ],
  );

  static const NotificationDetails subuhNotificationDetails =
      NotificationDetails(
    android: androidSubuhDetails,
  );

  // NOTIFIKASI SHALAT LAIN - suara biasa
  static const AndroidNotificationDetails androidShalatDetails =
      AndroidNotificationDetails(
    'channel_adzan_biasa_stop_v3',
    'Adzan Shalat',
    channelDescription: 'Notifikasi waktu shalat dengan suara adzan biasa',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('adzan'),
    autoCancel: false,
    ongoing: true,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'STOP_ADZAN',
        'Stop',
        cancelNotification: true,
      ),
    ],
  );

  static const NotificationDetails shalatNotificationDetails =
      NotificationDetails(
    android: androidShalatDetails,
  );

  static Future<void> tampilkanTesNotifikasi() async {
    await _notif.show(
      99,
      'Tes Notifikasi',
      'Jika ini muncul, notifikasi sudah aktif.',
      shalatNotificationDetails,
    );
  }

  static Future<void> tesNotifikasiSubuh() async {
    await _notif.show(
      100,
      'Tes Adzan Subuh',
      'Ini contoh suara khusus Subuh.',
      subuhNotificationDetails,
    );
  }

static Future<void> tesNotifikasiBiasa() async {
  await _notif.show(
    2001,
    'Tes Adzan Biasa',
    'Ini contoh suara adzan biasa.',
    shalatNotificationDetails,
  );
}

  static Future<void> tesAdzanSubuhLangsung() async {
    await _notif.show(
      1001,
      'Tes Adzan Subuh',
      'Ini suara khusus untuk adzan Subuh.',
      subuhNotificationDetails,
    );
  }

  static Future<void> tesAdzanBiasaLangsung() async {
    await _notif.show(
      1002,
      'Tes Adzan Biasa',
      'Ini suara adzan untuk Dzuhur, Ashar, Maghrib, dan Isya.',
      shalatNotificationDetails,
    );
  }

  static Future<void> jadwalkanNotifikasiShalat({
    required String namaShalat,
    required String jamShalat,
  }) async {
    if (jamShalat == '-' || !jamShalat.contains(':')) {
      print("JAM $namaShalat tidak valid: $jamShalat");
      return;
    }

    final bagian = jamShalat.split(':');

    final int jam = int.parse(bagian[0]);
    final int menit = int.parse(bagian[1]);

    final sekarang = tz.TZDateTime.now(tz.local);

    var jadwal = tz.TZDateTime(
      tz.local,
      sekarang.year,
      sekarang.month,
      sekarang.day,
      jam,
      menit,
    );

    if (jadwal.isBefore(sekarang)) {
      jadwal = jadwal.add(const Duration(days: 1));
    }

    final namaLower = namaShalat.toLowerCase();
    final int id = getIdShalat(namaShalat);

    final bool isSubuh = namaLower == 'subuh' || namaLower == 'shubuh';

    final detailNotif =
        isSubuh ? subuhNotificationDetails : shalatNotificationDetails;

    String judulNotif = '';
    String isiNotif = '';

    if (isSubuh) {
      judulNotif = 'Waktu Subuh';
      isiNotif = 'Sudah masuk waktu Subuh. Yuk bangun dan shalat Subuh.';
    } else if (namaLower == 'dzuhur') {
      judulNotif = 'Waktu Dzuhur';
      isiNotif =
          'Sudah masuk waktu Dzuhur. Istirahat sejenak dan tunaikan shalat.';
    } else if (namaLower == 'ashar') {
      judulNotif = 'Waktu Ashar';
      isiNotif =
          'Sudah masuk waktu Ashar. Jangan lupa shalat sebelum sore berlalu.';
    } else if (namaLower == 'maghrib' || namaLower == 'magrib') {
      judulNotif = 'Waktu Maghrib';
      isiNotif =
          'Sudah masuk waktu Maghrib. Saatnya shalat setelah matahari terbenam.';
    } else if (namaLower == 'isya') {
      judulNotif = 'Waktu Isya';
      isiNotif = 'Sudah masuk waktu Isya. Tutup harimu dengan shalat Isya.';
    } else {
      judulNotif = 'Waktu Shalat';
      isiNotif = 'Sudah masuk waktu shalat. Yuk shalat tepat waktu.';
    }

    // Batalkan jadwal lama untuk salat yang sama dulu
    await _notif.cancel(id);

    print("MENJADWALKAN $namaShalat");
    print("ID: $id");
    print("JAM INPUT: $jamShalat");
    print("JADWAL FINAL: $jadwal");

    await _notif.zonedSchedule(
      id,
      judulNotif,
      isiNotif,
      jadwal,
      detailNotif,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("$namaShalat berhasil dijadwalkan");
  }

  static Future<void> jadwalkanSemuaShalat({
    required String shubuh,
    required String dzuhur,
    required String ashar,
    required String magrib,
    required String isya,
  }) async {
    await batalkanJadwalShalat();

    await jadwalkanNotifikasiShalat(
      namaShalat: 'Subuh',
      jamShalat: shubuh,
    );

    await jadwalkanNotifikasiShalat(
      namaShalat: 'Dzuhur',
      jamShalat: dzuhur,
    );

    await jadwalkanNotifikasiShalat(
      namaShalat: 'Ashar',
      jamShalat: ashar,
    );

    await jadwalkanNotifikasiShalat(
      namaShalat: 'Maghrib',
      jamShalat: magrib,
    );

    await jadwalkanNotifikasiShalat(
      namaShalat: 'Isya',
      jamShalat: isya,
    );

    await cekJadwalAktif();
  }

  static Future<void> batalkanJadwalShalat() async {
    await _notif.cancel(101); // Subuh
    await _notif.cancel(102); // Dzuhur
    await _notif.cancel(103); // Ashar
    await _notif.cancel(104); // Maghrib
    await _notif.cancel(105); // Isya
  }

  static Future<void> batalkanSemuaNotifikasi() async {
    await _notif.cancelAll();
  }

  static Future<void> batalkanNotifikasiById(int id) async {
    await _notif.cancel(id);
  }

  static Future<void> batalkanNotifikasiShalat(String namaShalat) async {
    final id = getIdShalat(namaShalat);
    await _notif.cancel(id);
  }

  static Future<void> cekJadwalAktif() async {
    final pending = await _notif.pendingNotificationRequests();

    print("===== JADWAL NOTIFIKASI AKTIF =====");

    if (pending.isEmpty) {
      print("Tidak ada jadwal notifikasi aktif");
    }

    for (final item in pending) {
      print("ID: ${item.id}");
      print("TITLE: ${item.title}");
      print("BODY: ${item.body}");
      print("-----------------------------");
    }

    print("===================================");
  }

  static Future<void> tesNotifikasiSatuMenit() async {
    final jadwal = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 1),
    );

    print("TES 1 MENIT DIJADWALKAN PADA: $jadwal");

    await _notif.zonedSchedule(
      999,
      'Tes Notifikasi Azan',
      'Ini tes notifikasi 1 menit.',
      jadwal,
      shalatNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("TES 1 MENIT SELESAI DIJADWALKAN");
  }
static Future<void> resetSemuaNotifikasiUntukTes() async {
  await _notif.cancelAll();

  print("SEMUA NOTIFIKASI LAMA DIBATALKAN");

  final pending = await _notif.pendingNotificationRequests();
  print("SISA JADWAL SETELAH RESET: ${pending.length}");
}
}
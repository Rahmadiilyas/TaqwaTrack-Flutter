import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taqwatrack/view/Alquran.dart';
import 'package:taqwatrack/view/Ibadah.dart';
import 'package:taqwatrack/view/dzikir.dart';
import 'package:taqwatrack/navigasi.dart';
import 'package:taqwatrack/auth/register.dart';
import 'package:taqwatrack/view/shalat.dart';

import 'package:taqwatrack/provider/auth_provider.dart';
import 'package:taqwatrack/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taqwatrack/service/notifikasi_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedMenu = 0;

  // Ini dipakai untuk memaksa halaman Shalat dibuat ulang
  // supaya getlokasi() dan ambilJadwalShalat() jalan otomatis.
  int refreshShalatKey = 0;

  bool notifikasiAktif = false;
  bool notifSubuh = false;
  bool notifDzuhur = false;
  bool notifAshar = false;
  bool notifMaghrib = false;
  bool notifIsya = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadStatusNotifikasi();
  }

  Future<void> loadStatusNotifikasi() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notifSubuh = prefs.getBool("notif_subuh") ?? false;
      notifDzuhur = prefs.getBool("notif_dzuhur") ?? false;
      notifAshar = prefs.getBool("notif_ashar") ?? false;
      notifMaghrib = prefs.getBool("notif_maghrib") ?? false;
      notifIsya = prefs.getBool("notif_isya") ?? false;

      notifikasiAktif =
          notifSubuh || notifDzuhur || notifAshar || notifMaghrib || notifIsya;
    });
  }

  Future<void> simpanStatusNotifikasi() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("notif_subuh", notifSubuh);
    await prefs.setBool("notif_dzuhur", notifDzuhur);
    await prefs.setBool("notif_ashar", notifAshar);
    await prefs.setBool("notif_maghrib", notifMaghrib);
    await prefs.setBool("notif_isya", notifIsya);

    final aktif =
        notifSubuh || notifDzuhur || notifAshar || notifMaghrib || notifIsya;

    await prefs.setBool("notifikasi_aktif", aktif);

    if (!mounted) return;

    setState(() {
      notifikasiAktif = aktif;
    });
  }

  Future<bool> pastikanIzinNotifikasi() async {
    final izin = await NotifikasiService.mintaIzinNotifikasi();

    if (!izin) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Izin notifikasi ditolak. Aktifkan izin notifikasi agar azan bisa muncul.",
          ),
        ),
      );

      return false;
    }

    return true;
  }

  void refreshHalamanShalat() {
    setState(() {
      selectedMenu = 0;
      refreshShalatKey++;
    });
  }

  Future<void> ubahSemuaNotifikasi(bool value) async {
    if (value) {
      final izin = await pastikanIzinNotifikasi();

      if (!izin) {
        setState(() {
          notifikasiAktif = false;
        });
        return;
      }
    }

    setState(() {
      notifSubuh = value;
      notifDzuhur = value;
      notifAshar = value;
      notifMaghrib = value;
      notifIsya = value;
      notifikasiAktif = value;
    });

    await simpanStatusNotifikasi();

    if (!value) {
      await NotifikasiService.batalkanSemuaNotifikasi();
    }

    // Setelah switch berubah, halaman Shalat otomatis dibuat ulang.
    // Jadi user tidak perlu tekan Perbarui lagi.
    refreshHalamanShalat();
  }

  Future<void> ubahSatuNotifikasi({
    required String nama,
    required bool value,
    required void Function(bool value) updateState,
  }) async {
    if (value) {
      final izin = await pastikanIzinNotifikasi();

      if (!izin) {
        return;
      }
    }

    setState(() {
      updateState(value);
      notifikasiAktif =
          notifSubuh || notifDzuhur || notifAshar || notifMaghrib || notifIsya;
    });

    await simpanStatusNotifikasi();

    if (!value) {
      // Ini yang benar.
      // Jangan pakai ID 1,2,3,4,5 karena ID shalat di NotifikasiService adalah 101-105.
      await NotifikasiService.batalkanNotifikasiShalat(nama);
    }

    // Setelah salah satu switch berubah, otomatis refresh halaman Shalat
    // supaya jadwal azan dibuat ulang sesuai status terbaru.
    refreshHalamanShalat();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: selectedMenu == 0 || selectedMenu == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (selectedMenu != 0 && selectedMenu != 1) {
          setState(() {
            selectedMenu = 0;
          });
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xff03715E),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Color(0xff03715E),
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          auth.isLogin
                              ? (auth.userName ?? "User")
                              : "Belum Login",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.isLogin
                              ? (auth.userEmail ?? "")
                              : "TaqwaTrack",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!auth.isLogin)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text("Login"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),

                if (!auth.isLogin)
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text("Register"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                  ),

                if (auth.isLogin)
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    onTap: () async {
                      await auth.logout();

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
                  ),

                const Divider(),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications),
                        title: const Text("Semua Notifikasi Azan"),
                        subtitle: Text(
                          notifikasiAktif
                              ? "Ada notifikasi aktif"
                              : "Semua notifikasi mati",
                        ),
                        value: notifikasiAktif,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSemuaNotifikasi(value);
                        },
                      ),

                      const Divider(),

                      SwitchListTile(
                        secondary: const Icon(Icons.wb_twilight),
                        title: const Text("Azan Subuh"),
                        value: notifSubuh,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSatuNotifikasi(
                            nama: "Subuh",
                            value: value,
                            updateState: (v) {
                              notifSubuh = v;
                            },
                          );
                        },
                      ),

                      SwitchListTile(
                        secondary: const Icon(Icons.sunny),
                        title: const Text("Azan Dzuhur"),
                        value: notifDzuhur,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSatuNotifikasi(
                            nama: "Dzuhur",
                            value: value,
                            updateState: (v) {
                              notifDzuhur = v;
                            },
                          );
                        },
                      ),

                      SwitchListTile(
                        secondary: const Icon(Icons.wb_sunny_outlined),
                        title: const Text("Azan Ashar"),
                        value: notifAshar,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSatuNotifikasi(
                            nama: "Ashar",
                            value: value,
                            updateState: (v) {
                              notifAshar = v;
                            },
                          );
                        },
                      ),

                      SwitchListTile(
                        secondary: const Icon(Icons.nightlight_round),
                        title: const Text("Azan Maghrib"),
                        value: notifMaghrib,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSatuNotifikasi(
                            nama: "Maghrib",
                            value: value,
                            updateState: (v) {
                              notifMaghrib = v;
                            },
                          );
                        },
                      ),

                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text("Azan Isya"),
                        value: notifIsya,
                        activeColor: const Color(0xff03715E),
                        onChanged: (value) async {
                          await ubahSatuNotifikasi(
                            nama: "Isya",
                            value: value,
                            updateState: (v) {
                              notifIsya = v;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          body: IndexedStack(
            index: selectedMenu,
            children: [
              HalamanShalat(
                key: ValueKey(refreshShalatKey),
                onMenuTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              Alquran(
                onMenuTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              Dzikir(
                onMenuTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              Ibadah(
                onMenuTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),

          bottomNavigationBar: Navigasi(
            selectedIndex: selectedMenu,
            onTap: (index) {
              setState(() {
                selectedMenu = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
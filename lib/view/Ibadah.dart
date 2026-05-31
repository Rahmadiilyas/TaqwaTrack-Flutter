import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taqwatrack/auth/login_page.dart';
import 'package:taqwatrack/provider/auth_provider.dart';
import 'package:taqwatrack/provider/ibadah_provider.dart';
import 'package:taqwatrack/controllers/ibadah_controllers.dart';

class Ibadah extends StatefulWidget {
  final VoidCallback onMenuTap;

  const Ibadah({
    super.key,
    required this.onMenuTap,
  });

  @override
  State<Ibadah> createState() => _IbadahState();
}

class _IbadahState extends State<Ibadah> {
  static const Color hijau = Color(0xff03715E);
  static const Color background = Color(0xffEEF4FA);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final ibadah = context.read<IbadahProvider>();

      final controller = IbadahController(
        auth: auth,
        ibadah: ibadah,
      );

      controller.ambilDataAwal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ibadah = context.watch<IbadahProvider>();

    final controller = IbadahController(
      auth: auth,
      ibadah: ibadah,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: hijau,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuTap,
        ),
        title: const Text(
          "Ceklis Ibadah",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          headerIbadah(auth, controller),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
            child: Row(
              children: [
                const Text(
                  "Daftar Ibadah",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (auth.isLogin)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: hijau.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${controller.selesai}/${controller.total}",
                      style: const TextStyle(
                        color: hijau,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: !auth.isLogin
                ? halamanBelumLogin(auth, ibadah, controller)
                : ibadah.isLoading
                    ? loadingCard()
                    : ibadah.ibadahList.isEmpty
                        ? emptyState(controller)
                        : halamanCeklisIbadah(auth, ibadah, controller),
          ),
        ],
      ),
    );
  }

  Widget headerIbadah(AuthProvider auth, IbadahController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: hijau.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: hijau,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ibadah Harian",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.isLogin
                        ? "${controller.selesai} dari ${controller.total} ibadah selesai hari ini"
                        : "Login untuk mencatat ibadah harianmu",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget halamanBelumLogin(
    AuthProvider auth,
    IbadahProvider ibadah,
    IbadahController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
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
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: hijau.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 46,
                  color: hijau,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Login Diperlukan",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: hijau,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login terlebih dahulu untuk menggunakan fitur ceklis ibadah harian.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijau,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    "Login Sekarang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );

                    await controller.ambilDataAwal();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget halamanCeklisIbadah(
    AuthProvider auth,
    IbadahProvider ibadah,
    IbadahController controller,
  ) {
    return RefreshIndicator(
      color: hijau,
      onRefresh: () async {
        await controller.refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
        itemCount: ibadah.ibadahList.length,
        itemBuilder: (context, index) {
          final item = ibadah.ibadahList[index];

          final int id = item["id"];
          final String nama = (item["nama"] ?? "Tanpa Nama").toString();
          final String deskripsi =
              (item["deskripsi"] ?? "Tidak ada keterangan").toString();
          final bool isChecked = item["is_checked"] == true;

          return ibadahCard(
            id: id,
            nama: nama,
            deskripsi: deskripsi,
            isChecked: isChecked,
            controller: controller,
          );
        },
      ),
    );
  }

  Widget ibadahCard({
    required int id,
    required String nama,
    required String deskripsi,
    required bool isChecked,
    required IbadahController controller,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        controller.toggle(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isChecked ? hijau.withOpacity(0.45) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isChecked ? hijau : hijau.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isChecked
                    ? Icons.check_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isChecked ? Colors.white : hijau,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isChecked ? hijau : Colors.black87,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deskripsi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: isChecked
                    ? hijau.withOpacity(0.10)
                    : Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isChecked ? "Selesai" : "Belum",
                style: TextStyle(
                  color: isChecked ? hijau : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyState(IbadahController controller) {
    return RefreshIndicator(
      color: hijau,
      onRefresh: () async {
        await controller.refreshData();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.checklist_rtl_rounded,
                    size: 72,
                    color: hijau,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Data Ibadah Belum Ada",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Tarik layar ke bawah untuk memuat ulang data.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
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

  Widget loadingCard() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              skeletonBox(width: 48, height: 48, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    skeletonBox(
                      width: double.infinity,
                      height: 16,
                      radius: 10,
                    ),
                    const SizedBox(height: 10),
                    skeletonBox(
                      width: 220,
                      height: 13,
                      radius: 10,
                    ),
                    const SizedBox(height: 8),
                    skeletonBox(
                      width: 160,
                      height: 13,
                      radius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
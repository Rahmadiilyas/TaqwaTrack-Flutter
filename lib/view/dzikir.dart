import 'package:flutter/material.dart';
import 'package:taqwatrack/controllers/dzikir_controller.dart';
import 'package:taqwatrack/model/dzikir_model.dart';

class Dzikir extends StatefulWidget {
  final VoidCallback onMenuTap;

  const Dzikir({
    super.key,
    required this.onMenuTap,
  });

  @override
  State<Dzikir> createState() => _DzikirState();
}

class _DzikirState extends State<Dzikir> {
  static const Color hijau = Color(0xff03715E);
  static const Color background = Color(0xffEEF4FA);

  final DzikirController dzikirController = DzikirController();

  List<DzikirModel> dataDzikir = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ambilDzikir();
  }

  Future<void> ambilDzikir() async {
    try {
      if (!mounted) return;

      setState(() {
        isLoading = true;
      });

      final hasil = await dzikirController.ambilDzikir();

      if (!mounted) return;

      setState(() {
        dataDzikir = hasil;
        isLoading = false;
      });

      print("Berhasil mengambil data dzikir: ${dataDzikir.length}");
    } catch (e) {
      if (!mounted) return;

      setState(() {
        dataDzikir = [];
        isLoading = false;
      });

      print("Error Dzikir: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Dzikir",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          headerDzikir(),
          Expanded(
            child: isLoading
                ? loadingCard()
                : dataDzikir.isEmpty
                    ? emptyState()
                    : RefreshIndicator(
                        color: hijau,
                        onRefresh: ambilDzikir,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                          itemCount: dataDzikir.length,
                          itemBuilder: (context, index) {
                            final item = dataDzikir[index];

                            return dzikirCard(item, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget headerDzikir() {
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
                Icons.auto_awesome_rounded,
                color: hijau,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dzikir Harian",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Kumpulan bacaan dzikir beserta arti",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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

  Widget dzikirCard(DzikirModel item, int index) {
    final judul = item.judul;
    final arab = item.arab;
    final arti = item.arti;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: hijau,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    judul.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: hijau,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hijau.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                arab,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Artinya:",
                    style: TextStyle(
                      color: hijau,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    arti,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
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

  Widget emptyState() {
    return RefreshIndicator(
      color: hijau,
      onRefresh: ambilDzikir,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
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
                    Icons.inbox_rounded,
                    size: 70,
                    color: hijau,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Data Dzikir Belum Ada",
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  skeletonBox(width: 38, height: 38, radius: 100),
                  const SizedBox(width: 10),
                  Expanded(
                    child: skeletonBox(
                      width: double.infinity,
                      height: 18,
                      radius: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: skeletonBox(
                  width: 240,
                  height: 30,
                  radius: 12,
                ),
              ),
              const SizedBox(height: 12),
              skeletonBox(
                width: double.infinity,
                height: 16,
                radius: 10,
              ),
              const SizedBox(height: 8),
              skeletonBox(
                width: 230,
                height: 16,
                radius: 10,
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
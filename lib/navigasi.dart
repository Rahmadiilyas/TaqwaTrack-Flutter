import 'package:flutter/material.dart';

class Navigasi extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navigasi({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<Navigasi> createState() => _NavigasiState();
}

class _NavigasiState extends State<Navigasi> {
  final Color warnaAktif = const Color(0xff03715E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        height: 59,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              spreadRadius: 2,
              color: Colors.black.withOpacity(0.5),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            itemMenu(0, "Salat", Icons.mosque),
            itemMenu(1, "Alquran", Icons.menu_book),
            itemMenu(2, "Tasbih", Icons.circle_outlined),
            itemMenu(3, "Ibadah", Icons.checklist),
          ],
        ),
      ),
    );
  }

  Widget itemMenu(int index, String nama, IconData icon) {
    bool aktif = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        widget.onTap(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: aktif ? warnaAktif : Colors.black,
            size: 22,
          ),
          Text(
            nama,
            style: TextStyle(
              color: aktif ? warnaAktif : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
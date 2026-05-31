class ShalatModel {
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  ShalatModel({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory ShalatModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];

    return ShalatModel(
      subuh: timings['Fajr'] ?? '-',
      dzuhur: timings['Dhuhr'] ?? '-',
      ashar: timings['Asr'] ?? '-',
      maghrib: timings['Maghrib'] ?? '-',
      isya: timings['Isha'] ?? '-',
    );
  }
}
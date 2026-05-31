class DzikirModel {
  final int id;
  final String judul;
  final String arab;
  final String arti;

  DzikirModel({
    required this.id,
    required this.judul,
    required this.arab,
    required this.arti,
  });

  factory DzikirModel.fromJson(Map<String, dynamic> json) {
    return DzikirModel(
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      judul: json["judul"]?.toString() ?? "-",
      arab: json["arab"]?.toString() ?? "-",
      arti: json["arti"]?.toString() ?? "-",
    );
  }
}
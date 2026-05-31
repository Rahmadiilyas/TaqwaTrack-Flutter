class IbadahModel {
  final int id;
  final String nama;
  final String deskripsi;
  final bool isChecked;

  IbadahModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.isChecked,
  });

  factory IbadahModel.fromJson(Map<String, dynamic> json) {
    return IbadahModel(
      id: json['id'],
      nama: json['nama'] ?? 'Tanpa Nama',
      deskripsi: json['deskripsi'] ?? 'Tidak ada keterangan',
      isChecked: json['is_checked'] == true,
    );
  }
}
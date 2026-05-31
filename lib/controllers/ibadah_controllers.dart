import 'package:taqwatrack/provider/auth_provider.dart';
import 'package:taqwatrack/provider/ibadah_provider.dart';

class IbadahController {
  final AuthProvider auth;
  final IbadahProvider ibadah;

  IbadahController({
    required this.auth,
    required this.ibadah,
  });

  Future<void> ambilDataAwal() async {
    if (auth.token != null) {
      await ibadah.ambilIbadah(auth.token!);
    }
  }

  Future<void> refreshData() async {
    if (auth.token != null) {
      await ibadah.ambilIbadah(auth.token!);
    }
  }

  Future<void> toggle(int id) async {
    if (auth.token != null) {
      await ibadah.toggleIbadah(
        token: auth.token!,
        ibadahId: id,
      );
    }
  }

  int get total => ibadah.ibadahList.length;

  int get selesai {
    return ibadah.ibadahList
        .where((item) => item["is_checked"] == true)
        .length;
  }
}
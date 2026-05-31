import 'package:quran/quran.dart' as quran;
import 'package:taqwatrack/model/alquran_model.dart';

class AlquranController {
  List<int> getDaftarJuz() {
    return List.generate(30, (index) => index + 1);
  }

  List<AyatJuzModel> getIsiJuz(int nomorJuz) {
    final List<AyatJuzModel> ayatJuz = [];

    for (int surah = 1; surah <= 114; surah++) {
      final jumlahAyat = quran.getVerseCount(surah);

      for (int ayat = 1; ayat <= jumlahAyat; ayat++) {
        if (quran.getJuzNumber(surah, ayat) == nomorJuz) {
          ayatJuz.add(
            AyatJuzModel(
              surah: surah,
              ayat: ayat,
            ),
          );
        }
      }
    }

    return ayatJuz;
  }

  String getNamaSurah(int surah) {
    return quran.getSurahName(surah);
  }

  String getAyatArab(int surah, int ayat) {
    return quran.getVerse(
      surah,
      ayat,
      verseEndSymbol: true,
    );
  }

  String getTerjemahan(int surah, int ayat) {
    return quran.getVerseTranslation(
      surah,
      ayat,
      translation: quran.Translation.indonesian,
    );
  }
}
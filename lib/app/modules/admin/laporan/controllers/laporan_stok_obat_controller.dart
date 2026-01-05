import 'package:get/get.dart';
import '../../../../data/services/firestore/obat_firestore_service.dart';
import '../../../../data/models/obat_model.dart';

/// Controller untuk Laporan Stok Obat - data real dari Firestore
class LaporanStokObatController extends GetxController {
  final ObatFirestoreService _obatService = ObatFirestoreService();

  // Loading state
  final isLoading = true.obs;

  // Summary stats
  final stokAman = 0.obs;
  final stokMenipis = 0.obs;
  final expiredSoon = 0.obs;
  final totalItem = 0.obs;

  // Obat lists
  final obatStokMenipis = <ObatModel>[].obs;
  final obatExpiredSoon = <ObatModel>[].obs;
  final obatStokAman = <ObatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      final stats = await _obatService.getStatistikStok();
      final allObat = await _obatService.getAllObat();
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      totalItem.value = stats['total'] ?? 0;
      stokAman.value = stats['aman'] ?? 0;
      stokMenipis.value = (stats['hampirHabis'] ?? 0) + (stats['kritis'] ?? 0);
      expiredSoon.value = stats['kadaluarsa'] ?? 0;

      // Separate obat by category
      obatStokMenipis.value = allObat
          .where((obat) => obat.isStokKritis || obat.isStokHampirHabis)
          .toList()
        ..sort((a, b) => a.stok.compareTo(b.stok)); // Sort by stok ascending

      obatExpiredSoon.value = allObat.where((obat) {
        if (obat.tanggalKadaluarsa == null) return false;
        return obat.tanggalKadaluarsa!.isBefore(thirtyDaysFromNow) &&
               obat.tanggalKadaluarsa!.isAfter(now);
      }).toList()
        ..sort((a, b) => a.tanggalKadaluarsa!.compareTo(b.tanggalKadaluarsa!));

      obatStokAman.value = allObat
          .where((obat) => obat.isStokAman)
          .toList()
        ..sort((a, b) => b.stok.compareTo(a.stok)); // Sort by stok descending

    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get remaining days until expiry
  int getDaysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return 999;
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Format days remaining
  String formatDaysRemaining(DateTime? expiryDate) {
    final days = getDaysUntilExpiry(expiryDate);
    if (days <= 0) return 'Sudah Expired';
    if (days == 1) return '1 hari';
    return '$days hari';
  }
}

import 'package:get/get.dart';
import '../../../../data/services/admin/admin_statistics_service.dart';
import 'package:intl/intl.dart';

/// Controller untuk Laporan Keuangan - data real dari Firestore
/// Hanya menghitung pendapatan dari penjualan obat (tidak ada pengeluaran)
class LaporanKeuanganController extends GetxController {
  final AdminStatisticsService _statisticsService = AdminStatisticsService();

  // Loading state
  final isLoading = true.obs;

  // Summary stats
  final totalPendapatan = 0.obs;
  final pendapatanBPJS = 0.obs;
  final pendapatanUmum = 0.obs;
  final totalResep = 0.obs;

  // Formatted currency
  final totalPendapatanFormatted = ''.obs;
  final pendapatanBPJSFormatted = ''.obs;
  final pendapatanUmumFormatted = ''.obs;

  // Percentages
  final persentaseBPJS = ''.obs;
  final persentaseUmum = ''.obs;

  // Transaksi terakhir
  final transaksiTerakhir = <Map<String, dynamic>>[].obs;

  // Currency formatter
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      final stats = await _statisticsService.getKeuanganStatistics();

      totalPendapatan.value = stats['totalPendapatanObat'] ?? 0;
      pendapatanBPJS.value = stats['pendapatanBPJS'] ?? 0;
      pendapatanUmum.value = stats['pendapatanUmum'] ?? 0;
      totalResep.value = stats['totalResepDiproses'] ?? 0;

      // Format currency
      totalPendapatanFormatted.value = _currencyFormatter.format(totalPendapatan.value);
      pendapatanBPJSFormatted.value = _currencyFormatter.format(pendapatanBPJS.value);
      pendapatanUmumFormatted.value = _currencyFormatter.format(pendapatanUmum.value);

      // Calculate percentages
      if (totalPendapatan.value > 0) {
        final bpjsPercent = (pendapatanBPJS.value / totalPendapatan.value * 100).toStringAsFixed(1);
        final umumPercent = (pendapatanUmum.value / totalPendapatan.value * 100).toStringAsFixed(1);
        persentaseBPJS.value = '$bpjsPercent%';
        persentaseUmum.value = '$umumPercent%';
      } else {
        persentaseBPJS.value = '0%';
        persentaseUmum.value = '0%';
      }

      // Process transaksi terakhir
      final transaksiData = stats['transaksiTerakhir'] as List<Map<String, dynamic>>? ?? [];
      transaksiTerakhir.value = transaksiData.map((t) {
        return {
          ...t,
          'totalFormatted': _currencyFormatter.format(t['total'] ?? 0),
          'tanggalFormatted': _formatTanggal(t['tanggal'] as String?),
        };
      }).toList();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final parts = tanggal.split('-');
      if (parts.length != 3) return tanggal;
      
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  Future<void> refresh() async {
    await loadStatistics();
  }
}

import 'package:get/get.dart';
import '../../../../utils/auth_helper.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../data/services/firestore/poli_firestore_service.dart';
import '../../../../data/services/firestore/ruangan_firestore_service.dart';
import '../../../../data/services/firestore/antrian_firestore_service.dart';
import '../../../../data/services/firestore/obat_firestore_service.dart';

class AdminDashboardController extends GetxController {
  final StorageService _storage = StorageService();
  final PoliFirestoreService _poliService = PoliFirestoreService();
  final RuanganFirestoreService _ruanganService = RuanganFirestoreService();
  final AntrianFirestoreService _antrianService = AntrianFirestoreService();
  final ObatFirestoreService _obatService = ObatFirestoreService();
  
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = 'Administrator'.obs;
  
  final totalPengguna = 0.obs;
  final totalPoli = 0.obs;
  final totalRuangan = 0.obs;
  final isLoadingStats = true.obs;
  
  // Quick stats for hero section
  final pasienHariIni = 0.obs;
  final antrianAktif = 0.obs;
  final totalDokter = 0.obs;
  final stokMenipis = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadStatistics();
    loadQuickStats();
  }
  
  Future<void> loadQuickStats() async {
    try {
      // Pasien hari ini
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final allAntrian = await _antrianService.getAllAntrian();
      pasienHariIni.value = allAntrian.where((a) => a['tanggal'] == todayStr).length;
      
      // Antrian aktif (menunggu/dilayani)
      antrianAktif.value = allAntrian.where((a) => 
        a['tanggal'] == todayStr && 
        (a['status'] == 'menunggu' || a['status'] == 'dilayani' || a['status'] == 'pending')
      ).length;
      
      // Total dokter
      final users = await _storage.getAllUsers();
      totalDokter.value = users.where((u) => u['role'] == 'dokter').length;
      
      // Stok menipis
      final obatStats = await _obatService.getStatistikStok();
      stokMenipis.value = (obatStats['kritis'] ?? 0) + (obatStats['hampirHabis'] ?? 0);
    } catch (e) {
    }
  }
  
  Future<void> loadUserData() async {
    final userData = await AuthHelper.currentUserData;
    if (userData != null) {
      userName.value = userData['namaLengkap'] ?? 'Admin';
      userEmail.value = userData['email'] ?? '-';
      userRole.value = _getRoleDisplay(userData['role']);
    }
  }
  
  Future<void> loadStatistics() async {
    isLoadingStats.value = true;
    try {
      // Load total pengguna
      final users = await _storage.getAllUsers();
      totalPengguna.value = users.length;
      
      // Load total poli
      final poli = await _poliService.getAllPoli();
      totalPoli.value = poli.length;
      
      // Load total ruangan
      final ruangan = await _ruanganService.getAllRuangan();
      totalRuangan.value = ruangan.length;
    } catch (e) {
    } finally {
      isLoadingStats.value = false;
    }
  }
  
  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'dokter':
        return 'Dokter';
      case 'perawat':
        return 'Perawat';
      case 'apoteker':
        return 'Apoteker';
      default:
        return 'User';
    }
  }
}

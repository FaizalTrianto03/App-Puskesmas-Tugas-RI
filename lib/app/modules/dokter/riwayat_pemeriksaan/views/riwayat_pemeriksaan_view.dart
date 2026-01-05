import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';
import '../../pemeriksaan/views/detail_pemeriksaan_view.dart';

class DokterRiwayatPemeriksaanView
    extends GetView<DokterRiwayatPemeriksaanController> {
  const DokterRiwayatPemeriksaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF02B1BA)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF02B1BA),
          onRefresh: () => controller.refreshData(),
          child: Column(
            children: [
              _buildStatistikCard(),
              _buildSearchAndFilter(),
              Expanded(child: _buildRiwayatList()),
            ],
          ),
        );
      }),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF02B1BA),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Riwayat Pemeriksaan',
        style: TextStyle(
          color: Color(0xFF02B1BA),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Color(0xFF02B1BA)),
          onPressed: () => controller.exportSummary(),
          tooltip: 'Export PDF',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF02B1BA)),
          onPressed: () => controller.refreshData(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Widget Statistik Card
  Widget _buildStatistikCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.medical_services,
              label: 'Total',
              value: controller.totalPemeriksaan.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.calendar_month,
              label: 'Bulan Ini',
              value: controller.pemeriksaanBulanIni.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Hari Ini',
              value: controller.pemeriksaanHariIni.value.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  /// Widget Search and Filter
  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 12),
          _buildFilterButton(),
        ],
      ),
    );
  }

  /// Build Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Cari pasien, No. RM, diagnosa...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF02B1BA)),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchQuery.value = '';
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
        },
      ),
    );
  }

  /// Build Filter Button
  Widget _buildFilterButton() {
    return Obx(() {
      final hasActiveFilter =
          controller.selectedFilter.value != 'semua' ||
          controller.selectedStatus.value != null ||
          controller.selectedPoli.value != 'Semua';

      return Container(
        decoration: BoxDecoration(
          color: hasActiveFilter ? const Color(0xFF02B1BA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showFilterModal(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    color:
                        hasActiveFilter
                            ? Colors.white
                            : const Color(0xFF02B1BA),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color:
                          hasActiveFilter
                              ? Colors.white
                              : const Color(0xFF02B1BA),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (hasActiveFilter) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Color(0xFF02B1BA),
                        size: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Show Filter Modal
  void _showFilterModal() async {
    await controller.loadPoliList();

    String tempPeriod = controller.selectedFilter.value;
    String? tempStatus = controller.selectedStatus.value;
    String tempPoli = controller.selectedPoli.value;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: Get.width * 0.9,
              constraints: BoxConstraints(maxHeight: Get.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterModalHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPeriodeFilter(setState, tempPeriod, (value) {
                            setState(() => tempPeriod = value);
                          }),
                          const SizedBox(height: 16),
                          _buildStatusFilter(setState, tempStatus, (value) {
                            setState(() => tempStatus = value);
                          }),
                          const SizedBox(height: 16),
                          _buildPoliFilter(setState, tempPoli, (value) {
                            setState(() => tempPoli = value);
                          }),
                        ],
                      ),
                    ),
                  ),
                  _buildFilterModalFooter(
                    onReset: () {
                      setState(() {
                        tempPeriod = 'semua';
                        tempStatus = null;
                        tempPoli = 'Semua';
                      });
                    },
                    onApply: () {
                      controller.selectedFilter.value = tempPeriod;
                      controller.selectedStatus.value = tempStatus;
                      controller.selectedPoli.value = tempPoli;
                      Get.back();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build Filter Modal Header
  Widget _buildFilterModalHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF02B1BA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Filter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  /// Build Periode Filter Section
  Widget _buildPeriodeFilter(
    StateSetter setState,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B4D3B),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _buildPeriodeOptions(currentValue, onChanged)),
        ),
      ],
    );
  }

  List<Widget> _buildPeriodeOptions(
    String currentValue,
    Function(String) onChanged,
  ) {
    final options = [
      {'label': 'Semua', 'value': 'semua'},
      {'label': 'Hari Ini', 'value': 'hari_ini'},
      {'label': 'Minggu Ini', 'value': 'minggu_ini'},
      {'label': 'Bulan Ini', 'value': 'bulan_ini'},
      {'label': 'Tahun Ini', 'value': 'tahun_ini'},
    ];

    return options.map((option) {
      final isSelected = currentValue == option['value'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(option['label']!),
          selected: isSelected,
          onSelected: (_) => onChanged(option['value']!),
          selectedColor: const Color(0xFF02B1BA),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.grey[100],
          side: BorderSide(
            color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade300,
          ),
        ),
      );
    }).toList();
  }

  /// Build Status Filter Section
  Widget _buildStatusFilter(
    StateSetter setState,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B4D3B),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip(
                'Semua',
                null,
                currentValue == null,
                () => onChanged(null),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                'Selesai',
                'selesai',
                currentValue == 'selesai',
                () => onChanged('selesai'),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                'Dibatalkan',
                'dibatalkan',
                currentValue == 'dibatalkan',
                () => onChanged('dibatalkan'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    String label,
    String? value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF02B1BA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build Poli Filter Section
  Widget _buildPoliFilter(
    StateSetter setState,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Poli',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B4D3B),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  controller.poliList.map((poli) {
                    final isSelected = currentValue == poli;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(poli),
                        selected: isSelected,
                        onSelected: (_) => onChanged(poli),
                        selectedColor: const Color(0xFF02B1BA),
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF02B1BA),
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(
                          color:
                              isSelected
                                  ? const Color(0xFF02B1BA)
                                  : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Filter Modal Footer
  Widget _buildFilterModalFooter({
    required VoidCallback onReset,
    required VoidCallback onApply,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF02B1BA)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Color(0xFF02B1BA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02B1BA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Terapkan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Riwayat List
  Widget _buildRiwayatList() {
    return Obx(() {
      if (controller.filteredRiwayatList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada riwayat pemeriksaan',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredRiwayatList.length,
        itemBuilder: (context, index) {
          final riwayat = controller.filteredRiwayatList[index];
          return _buildRiwayatCard(riwayat);
        },
      );
    });
  }

  /// Build Riwayat Card - Desain mirip dengan Dashboard Dokter
  Widget _buildRiwayatCard(Map<String, dynamic> riwayat) {
    final status = riwayat['status']?.toString().toLowerCase() ?? '';
    final isDibatalkan = status == 'dibatalkan';
    
    // Ambil diagnosa dari root level (struktur baru) atau dokterData (struktur lama)
    final dokterData = riwayat['dokterData'] as Map<String, dynamic>? ?? {};
    final diagnosa = riwayat['diagnosa'] ?? dokterData['diagnosa'] ?? '-';

    Color statusColor;
    String statusText;

    if (isDibatalkan) {
      statusColor = const Color(0xFFF44336);
      statusText = 'Dibatalkan';
    } else if (status == 'selesai' ||
        status == 'selesai_diperiksa' ||
        status == 'siap_ambil_obat') {
      statusColor = const Color(0xFF4CAF50);
      statusText = 'Selesai';
    } else {
      statusColor = const Color(0xFF2196F3);
      statusText = 'Dalam Proses';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row - sama seperti dashboard
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF02B1BA),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riwayat['namaLengkap'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. RM: ${riwayat['noRekamMedis'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info Row - sama seperti dashboard
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrian',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      riwayat['queueNumber'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4242),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keluhan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      riwayat['keluhan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Diagnosa Section (jika ada)
          if (!isDibatalkan && diagnosa != '-' && diagnosa.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnosa',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diagnosa.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          // Alasan Pembatalan (jika dibatalkan)
          if (isDibatalkan && riwayat['alasanPembatalan'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alasan Pembatalan',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    riwayat['alasanPembatalan'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Button Lihat Detail
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => DetailPemeriksaanView(pasienData: riwayat));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02B1BA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.visibility, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

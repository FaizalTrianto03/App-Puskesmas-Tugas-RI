import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';
import '../../../../utils/confirmation_dialog.dart';

class RiwayatPemeriksaanView extends GetView<RiwayatPemeriksaanController> {
  const RiwayatPemeriksaanView({Key? key}) : super(key: key);

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
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: () => controller.exportSummary(),
          tooltip: 'Export PDF',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
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
              label: 'Minggu Ini',
              value: controller.pemeriksaanMingguIni.value.toString(),
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
          hintText: 'Cari pasien, No. RM, keluhan...',
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
          child: Row(children: _buildStatusOptions(currentValue, onChanged)),
        ),
      ],
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
        Row(
          children: [
            const Text(
              'Poli',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B4D3B),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                '(${controller.poliList.length - 1})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(children: _buildPoliOptions(currentValue, onChanged)),
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
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Terapkan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Periode Options
  List<Widget> _buildPeriodeOptions(
    String currentValue,
    Function(String) onChanged,
  ) {
    final options = [
      {'label': 'Semua', 'value': 'semua', 'icon': Icons.all_inclusive},
      {'label': 'Hari Ini', 'value': 'hari_ini', 'icon': Icons.today},
      {
        'label': 'Minggu Ini',
        'value': 'minggu_ini',
        'icon': Icons.calendar_today,
      },
      {
        'label': 'Bulan Ini',
        'value': 'bulan_ini',
        'icon': Icons.calendar_month,
      },
      {
        'label': 'Tahun Ini',
        'value': 'tahun_ini',
        'icon': Icons.calendar_view_month,
      },
    ];

    return options.map((option) {
      final isSelected = currentValue == option['value'];
      return _buildFilterChip(
        label: option['label'] as String,
        icon: option['icon'] as IconData,
        isSelected: isSelected,
        onTap: () => onChanged(option['value'] as String),
      );
    }).toList();
  }

  /// Build Status Options
  List<Widget> _buildStatusOptions(
    String? currentValue,
    Function(String?) onChanged,
  ) {
    final options = [
      {'label': 'Semua', 'value': null, 'color': Colors.grey},
      {
        'label': 'Terverifikasi',
        'value': 'terverifikasi',
        'color': const Color(0xFF4CAF50),
      },
      {
        'label': 'Dibatalkan',
        'value': 'dibatalkan',
        'color': const Color(0xFFF44336),
      },
    ];

    return options.map((option) {
      final isSelected = currentValue == option['value'];
      return _buildFilterChip(
        label: option['label'] as String,
        isSelected: isSelected,
        selectedColor: option['color'] as Color,
        onTap: () => onChanged(option['value'] as String?),
      );
    }).toList();
  }

  /// Build Poli Options
  List<Widget> _buildPoliOptions(
    String currentValue,
    Function(String) onChanged,
  ) {
    if (controller.poliList.isEmpty || controller.poliList.length == 1) {
      return [_buildLoadingPoliChip()];
    }

    return controller.poliList.map((poli) {
      final isSelected = currentValue == poli;
      return _buildFilterChip(
        label: poli,
        isSelected: isSelected,
        onTap: () => onChanged(poli),
      );
    }).toList();
  }

  /// Build Filter Chip (Reusable)
  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    Color? selectedColor,
    required VoidCallback onTap,
  }) {
    final color = selectedColor ?? const Color(0xFF02B1BA);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF02B1BA),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : const Color(0xFF0B4D3B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Loading Poli Chip
  Widget _buildLoadingPoliChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Memuat data poli...',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Riwayat List
  Widget _buildRiwayatList() {
    return Obx(() {
      if (controller.filteredRiwayatList.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredRiwayatList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final antrian = controller.filteredRiwayatList[index];
          return _buildAntrianCard(antrian);
        },
      );
    });
  }

  /// Build Antrian Card
  Widget _buildAntrianCard(Map<String, dynamic> antrian) {
    final status = antrian['status'] as String;
    final borderColor = controller.getBorderColor(status);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAntrianHeader(antrian, borderColor),
          const SizedBox(height: 6),
          _buildAntrianInfo(antrian, borderColor),
          if (status == 'dibatalkan') ...[
            const SizedBox(height: 6),
            _buildCancellationInfo(antrian),
          ],
          const SizedBox(height: 6),
          _buildAntrianActions(antrian, status),
        ],
      ),
    );
  }

  /// Build Antrian Header
  Widget _buildAntrianHeader(Map<String, dynamic> antrian, Color borderColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: borderColor,
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                antrian['namaLengkap'] ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'RM: ${antrian['noRekamMedis'] ?? '-'}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              if (antrian['tanggal'] != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      controller.formatTimestamp(antrian['tanggal']),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            antrian['queueNumber'] ?? '-',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build Antrian Info
  Widget _buildAntrianInfo(Map<String, dynamic> antrian, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital, size: 12, color: borderColor),
              const SizedBox(width: 4),
              Text(
                antrian['jenisLayanan'] ?? '-',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            antrian['keluhan'] ?? '-',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build Cancellation Info
  Widget _buildCancellationInfo(Map<String, dynamic> antrian) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 12, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(
                'Dibatalkan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          if (antrian['waktuPembatalan'] != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.access_time, size: 10, color: Colors.grey.shade600),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    'Dibatalkan: ${controller.formatTimestamp(antrian['waktuPembatalan'])}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (antrian['dibatalkanOleh'] != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  antrian['dibatalkanOleh'] == 'perawat'
                      ? Icons.medical_services
                      : Icons.person,
                  size: 10,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    antrian['dibatalkanOleh'] == 'perawat'
                        ? 'Oleh: Perawat${antrian['dibatalkanOlehNama'] != null ? ' (${antrian['dibatalkanOlehNama']})' : ''}'
                        : 'Oleh: Pasien',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build Antrian Actions
  Widget _buildAntrianActions(Map<String, dynamic> antrian, String status) {
    if (status == 'menunggu' || status == 'menunggu_verifikasi') {
      return _buildVerifikasiActions(antrian);
    } else if (status == 'menunggu_dokter' || status == 'sedang_dilayani' || status == 'dilayani_dokter') {
      return _buildLihatDetailAction(antrian);
    } else if (status == 'dilewati') {
      return _buildLanjutkanVerifikasiAction(antrian);
    } else if (status == 'dibatalkan') {
      return _buildLihatPembatalanAction(antrian);
    } else if (status == 'selesai' || status == 'selesai_diperiksa' || status == 'siap_ambil_obat' || status == 'menunggu_apoteker' || status == 'dilayani_apoteker') {
      return _buildLihatDetailSelesaiAction(antrian);
    }
    return const SizedBox.shrink();
  }

  /// Build Verifikasi Actions
  Widget _buildVerifikasiActions(Map<String, dynamic> antrian) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => controller.navigateToFormRekamMedis(antrian),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B1BA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Verifikasi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleLewatiAntrian(antrian),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Lewati',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildBatalkanButton(antrian),
      ],
    );
  }

  /// Build Lihat Detail Action
  Widget _buildLihatDetailAction(Map<String, dynamic> antrian) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.navigateToFormRekamMedis(antrian),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: const Text(
          'Lihat Detail',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Build Lanjutkan Verifikasi Action
  Widget _buildLanjutkanVerifikasiAction(Map<String, dynamic> antrian) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.navigateToFormRekamMedis(antrian),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Lanjutkan Verifikasi',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildBatalkanButton(antrian),
      ],
    );
  }

  /// Build Lihat Pembatalan Action
  Widget _buildLihatPembatalanAction(Map<String, dynamic> antrian) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showCancellationDetail(antrian),
        icon: const Icon(Icons.info_outline, size: 16),
        label: const Text(
          'Lihat Detail Pembatalan',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  /// Build Lihat Detail Selesai Action
  Widget _buildLihatDetailSelesaiAction(Map<String, dynamic> antrian) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.navigateToFormRekamMedis(antrian),
        icon: const Icon(Icons.visibility, size: 16),
        label: const Text(
          'Lihat Detail',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
      ),
    );
  }

  /// Build Batalkan Button
  Widget _buildBatalkanButton(Map<String, dynamic> antrian) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _handleBatalkanAntrian(antrian),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'Batalkan Antrian',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Handle Lewati Antrian
  Future<void> _handleLewatiAntrian(Map<String, dynamic> antrian) async {
    final confirm = await ConfirmationDialog.show(
      title: 'Lewati Sementara?',
      message:
          'Pasien ${antrian['namaLengkap']} akan dilewati dan dapat dilayani setelah antrian aktif selesai.',
      type: ConfirmationType.warning,
      confirmText: 'Ya, Lewati',
      cancelText: 'Tidak',
    );

    if (confirm == true) {
      await controller.lewatiAntrian(antrian['id']);
    }
  }

  /// Handle Batalkan Antrian
  Future<void> _handleBatalkanAntrian(Map<String, dynamic> antrian) async {
    final confirm = await ConfirmationDialog.show(
      title: 'Batalkan Antrian?',
      message:
          'Apakah Anda yakin ingin membatalkan antrian ${antrian['queueNumber']}?',
      type: ConfirmationType.danger,
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
    );

    if (confirm == true) {
      await _showBatalkanModal(antrian);
    }
  }

  /// Show Cancellation Detail
  void _showCancellationDetail(Map<String, dynamic> antrian) {
    Get.snackbar(
      'Antrian Dibatalkan',
      antrian['alasanPembatalan'] != null
          ? 'Alasan: ${antrian['alasanPembatalan']}'
          : 'Antrian ini telah dibatalkan',
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade900,
      icon: Icon(Icons.info_outline, color: Colors.red.shade700),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show modal untuk input alasan pembatalan
  Future<void> _showBatalkanModal(Map<String, dynamic> antrian) async {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final alasan = await Get.dialog<String>(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBatalkanModalHeader(antrian),
                _buildBatalkanModalContent(alasanController, formKey),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (alasan != null && alasan.isNotEmpty) {
      await controller.batalkanAntrian(antrian, alasan);
    }
  }

  /// Build Batalkan Modal Header
  Widget _buildBatalkanModalHeader(Map<String, dynamic> antrian) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Batalkan Antrian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No. ${antrian['queueNumber']} - ${antrian['namaLengkap']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Batalkan Modal Content
  Widget _buildBatalkanModalContent(
    TextEditingController alasanController,
    GlobalKey<FormState> formKey,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alasan Pembatalan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B4D3B),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: alasanController,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan pembatalan...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF02B1BA),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alasan pembatalan harus diisi';
              }
              if (value.trim().length < 10) {
                return 'Alasan minimal 10 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Get.back(result: alasanController.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Batalkan Antrian',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada riwayat pemeriksaan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return Column(
                children: [
                  Text(
                    'Tidak ditemukan hasil untuk "${controller.searchQuery.value}"',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.clearFilters(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Reset Pencarian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Text(
              'Belum ada data pemeriksaan',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            );
          }),
        ],
      ),
    );
  }
}

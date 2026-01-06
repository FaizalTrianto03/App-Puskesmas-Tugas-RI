import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/antrian_model.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../controllers/resep_obat_controller.dart';
import 'detail_resep_view.dart';

class ResepObatView extends GetView<ResepObatController> {
  const ResepObatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
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
          'Resep Obat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: QuarterCircleBackground(
              child: Column(
                children: [
                  _buildStatistikHeader(),
                  const SizedBox(height: 16),
                  _buildSearchAndFilterBar(),
                  const SizedBox(height: 12),
                  _buildFilterTabs(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildResepList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikHeader() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Menunggu',
              value: controller.countMenunggu.toString(),
              icon: Icons.pending_actions,
              color: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Selesai',
              value: controller.countSelesai.toString(),
              icon: Icons.check_circle,
              color: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Obx(() => TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pasien, no. RM...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF02B1BA)),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: controller.clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              )),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Obx(() {
      final hasActiveFilter = controller.selectedPeriode.value != 'Semua' ||
          controller.selectedFilter.value != 'Semua';

      return Container(
        decoration: BoxDecoration(
          color: hasActiveFilter ? const Color(0xFF02B1BA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasActiveFilter ? const Color(0xFF02B1BA) : Colors.grey.shade300,
          ),
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
                    color: hasActiveFilter ? Colors.white : const Color(0xFF02B1BA),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: hasActiveFilter ? Colors.white : const Color(0xFF02B1BA),
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

  void _showFilterModal() {
    String tempPeriode = controller.selectedPeriode.value;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: Get.width * 0.9,
              constraints: BoxConstraints(maxHeight: Get.height * 0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
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
                        const Expanded(
                          child: Text(
                            'Filter Resep',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Periode Waktu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.periodeOptions.map((periode) {
                            final isSelected = periode == tempPeriode;
                            return GestureDetector(
                              onTap: () => setState(() => tempPeriode = periode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  periode,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => tempPeriode = 'Semua');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              controller.changePeriode(tempPeriode);
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02B1BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: controller.filterOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final filter = entry.value;
          final isSelected = controller.selectedFilter.value == filter;
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < controller.filterOptions.length - 1 ? 8 : 0,
              ),
              child: _FilterChip(
                label: filter,
                isSelected: isSelected,
                onTap: () => controller.changeFilter(filter),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
  Widget _buildResepList() {
    return Obx(() {
      final antrianList = controller.filteredAntrian;
      
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (antrianList.isEmpty) {
        return _buildEmptyState();
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshResep,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: antrianList.length,
          itemBuilder: (context, index) {
            final antrian = antrianList[index];
            return _ResepCard(antrian: antrian, index: index);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final isSearching = controller.searchQuery.value.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Tidak ditemukan' : 'Tidak ada resep',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'Coba kata kunci lain'
                : 'Belum ada resep untuk kategori ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Hapus pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF02B1BA)
                : (_isHovered ? Colors.grey.shade200 : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF02B1BA)
                  : (_isHovered ? Colors.grey.shade400 : Colors.grey.shade300),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResepCard extends StatefulWidget {
  final AntrianModel antrian;
  final int index;

  const _ResepCard({
    required this.antrian,
    required this.index,
  });

  @override
  State<_ResepCard> createState() => _ResepCardState();
}

class _ResepCardState extends State<_ResepCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine status color
    Color statusColor;
    if (widget.antrian.status == 'selesai_diperiksa') {
      statusColor = const Color(0xFFFF9800); // Orange for waiting
    } else if (widget.antrian.status == 'siap_ambil_obat') {
      statusColor = const Color(0xFF4CAF50); // Green for ready
    } else {
      statusColor = const Color(0xFF02B1BA); // Teal for completed
    }

    // Format tanggal
    final tanggalStr = DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
        .format(widget.antrian.createdAt);

    // Get jumlah jenis obat
    final jumlahObat = widget.antrian.resepObat?.length ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          Get.to(() => DetailResepView(antrian: widget.antrian));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isPressed || _isHovered)
                    ? const Color(0xFF02B1BA)
                    : Colors.grey.shade300,
                width: (_isPressed || _isHovered) ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.antrian.queueNumber,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusLabel(widget.antrian.status),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.antrian.namaLengkap,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No. RM: ${widget.antrian.noRekamMedis}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.antrian.jenisLayanan} • ${widget.antrian.dokterNama ?? "Dokter"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tanggalStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02B1BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        size: 18,
                        color: Color(0xFF02B1BA),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$jumlahObat jenis obat',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF02B1BA),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF02B1BA),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'selesai_diperiksa':
        return 'Menunggu';
      case 'siap_ambil_obat':
        return 'Siap Diambil';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/obat_model.dart';
import '../controllers/stok_obat_controller.dart';

class StokObatView extends GetView<StokObatController> {
  const StokObatView({super.key});

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
          onRefresh: controller.refreshObat,
          child: Column(
            children: [
              _buildStatistikCard(),
              _buildSearchAndFilter(),
              Expanded(child: _buildObatList()),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.goToTambahObat(),
        backgroundColor: const Color(0xFF02B1BA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Obat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
        'Stok Obat',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.refreshObat(),
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
              icon: Icons.inventory_2,
              label: 'Total',
              value: controller.totalObat.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.check_circle,
              label: 'Aman',
              value: controller.stokAman.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.warning,
              label: 'Kritis',
              value: controller.stokKritis.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.event_busy,
              label: 'KDL',
              value: controller.obatKadaluarsa.value.toString(),
            ),
            _buildDivider(),
            _buildStatItem(
              icon: Icons.cancel,
              label: 'Habis',
              value: controller.stokHabis.value.toString(),
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
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
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

  /// Search Bar dan Filter
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
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
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari nama obat atau kategori...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF02B1BA)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Obx(() => SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: controller.filterOptions.map((filter) {
                final isSelected = controller.selectedFilter.value == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.setFilter(filter);
                      }
                    },
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF02B1BA),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF02B1BA)
                          : Colors.grey.shade300,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                    pressElevation: 0,
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Obat List
  Widget _buildObatList() {
    return Obx(() {
      if (controller.filteredObatList.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra bottom padding for FAB
        itemCount: controller.filteredObatList.length,
        itemBuilder: (context, index) {
          final obat = controller.filteredObatList[index];
          return _buildObatCard(obat);
        },
      );
    });
  }

  /// Obat Card
  Widget _buildObatCard(ObatModel obat) {
    Color statusColor;
    Color statusBgColor;
    
    if (obat.stok == 0) {
      statusColor = const Color(0xFFFF4242);
      statusBgColor = const Color(0xFFFFEBEE);
    } else if (obat.isStokKritis) {
      statusColor = const Color(0xFFFF9800);
      statusBgColor = const Color(0xFFFFF3E0);
    } else if (obat.isStokHampirHabis) {
      statusColor = const Color(0xFF9C27B0);
      statusBgColor = const Color(0xFFF3E5F5);
    } else {
      statusColor = const Color(0xFF4CAF50);
      statusBgColor = const Color(0xFFE8F5E9);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.goToDetailObat(obat),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat.namaObat,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${obat.kategori} • ${obat.jenisObat}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              obat.statusStok,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (obat.tanggalKadaluarsa != null &&
                              (obat.tanggalKadaluarsa!.isBefore(
                                    DateTime.now().add(const Duration(days: 30))
                                  ) ||
                                  obat.tanggalKadaluarsa!.isAtSameMomentAs(
                                    DateTime.now().add(const Duration(days: 30))
                                  ))) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE91E63),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event_busy,
                                    size: 12,
                                    color: Color(0xFFE91E63),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'KDL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFE91E63),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${obat.stok} ${obat.satuan}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada data obat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tambahkan obat dengan menekan tombol\n"Tambah Obat" di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

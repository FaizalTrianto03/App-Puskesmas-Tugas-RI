import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_pemeriksaan_controller.dart';
import '../widgets/timeline_item_widget.dart';

class RiwayatPemeriksaanView extends GetView<RiwayatPemeriksaanController> {
  const RiwayatPemeriksaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF02B1BA),
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF02B1BA),
          onRefresh: () => controller.refreshData(),
          child: Column(
            children: [
              _buildStatistikCard(),
              _buildSearchAndFilter(),
              Expanded(
                child: _buildRiwayatList(),
              ),
            ],
          ),
        );
      }),
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
      child: Obx(() => Row(
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
      )),
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
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

  /// Widget Search and Filter
  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          SearchBar(
            controller: TextEditingController(text: controller.searchQuery.value),
            hintText: 'Cari pasien, No. RM, keluhan...',
            leading: const Icon(Icons.search, color: Color(0xFF02B1BA)),
            backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
            trailing: [
              Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.searchQuery.value = '';
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  value: 'semua',
                  icon: Icons.all_inclusive,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Minggu Ini',
                  value: 'minggu_ini',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Bulan Ini',
                  value: 'bulan_ini',
                  icon: Icons.calendar_month,
                ),
                const SizedBox(width: 8),
                if (controller.searchQuery.value.isNotEmpty || 
                    controller.selectedFilter.value != 'semua')
                  TextButton.icon(
                    onPressed: () => controller.clearFilters(),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF02B1BA),
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          controller.selectedFilter.value = value;
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF02B1BA),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF02B1BA),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      );
    });
  }

  /// Widget Riwayat List
  Widget _buildRiwayatList() {
    return Obx(() {
      if (controller.filteredRiwayatList.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredRiwayatList.length,
        itemBuilder: (context, index) {
          final riwayat = controller.filteredRiwayatList[index];
          return TimelineItemWidget(
            riwayat: riwayat,
            isLast: index == controller.filteredRiwayatList.length - 1,
            onTap: () => controller.navigateToDetail(riwayat),
          );
        },
      );
    });
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            );
          }),
        ],
      ),
    );
  }
}

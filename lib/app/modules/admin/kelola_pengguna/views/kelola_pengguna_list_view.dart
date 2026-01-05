import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pengguna_controller.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../../../routes/app_pages.dart';

class KelolaPenggunaListView extends GetView<KelolaPenggunaController> {
  const KelolaPenggunaListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
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
          'Kelola Pengguna',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: Column(
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadUsers();
                },
                color: const Color(0xFF02B1BA),
                child: Column(
                  children: [
                    // Compact Statistics & Search Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF02B1BA), Color(0xFF4DD4DB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF02B1BA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Statistics Row - Compact
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Obx(() {
                            final stats = controller.getUserStatistics();
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    _buildCompactStat('Total', stats['total'] ?? 0, Icons.groups),
                                    const SizedBox(width: 8),
                                    _buildCompactStat('Admin', stats['admin'] ?? 0, Icons.admin_panel_settings),
                                    const SizedBox(width: 8),
                                    _buildCompactStat('Dokter', stats['dokter'] ?? 0, Icons.medical_services),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildCompactStat('Perawat', stats['perawat'] ?? 0, Icons.local_hospital),
                                    const SizedBox(width: 8),
                                    _buildCompactStat('Apoteker', stats['apoteker'] ?? 0, Icons.medication),
                                    const SizedBox(width: 8),
                                    _buildCompactStat('Pasien', stats['pasien'] ?? 0, Icons.person),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ),
                        
                        // Search Bar
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: controller.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Cari nama, email, atau NIK...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    onPressed: () => controller.onSearchChanged(''),
                                  )
                                : const SizedBox.shrink(),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Filter
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: controller.roleFilters.map((filter) {
                          final isSelected = controller.selectedRoleFilter.value == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                controller.selectedRoleFilter.value = filter;
                                controller.applyFilters();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF02B1BA) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  
                  // User List
                  Expanded(
                    child: Obx(() {
                      if (controller.filteredUserList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada pengguna',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Klik tombol + untuk menambah pengguna',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: controller.filteredUserList.length,
                        itemBuilder: (context, index) {
                          final user = controller.filteredUserList[index];
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
                      child: Stack(
                        children: [
                          // Card content - clickable to edit
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                controller.populateFormForEdit(user);
                                Get.toNamed(
                                  Routes.adminTambahPengguna,
                                  arguments: {
                                    'isEdit': true,
                                    'userId': user['id'],
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (user['namaLengkap']?.toString() ?? 'U')[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['namaLengkap']?.toString() ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF02B1BA),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  (user['role']?.toString() ?? '-').toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF02B1BA),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (user['nik'] != null && user['nik'].isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'NIK: ${user['nik'].toString().substring(0, 6)}...',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade700,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            user['email']?.toString() ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 80), // Space for buttons
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Reset Password button
                          Positioned(
                            right: 56,
                            top: 8,
                            bottom: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA726).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.lock_reset,
                                  color: Color(0xFFFFA726),
                                  size: 20,
                                ),
                                onPressed: () => controller.resetPassword(
                                  userId: user['id'] ?? '',
                                  email: user['email']?.toString() ?? '',
                                  nama: user['namaLengkap']?.toString() ?? '',
                                ),
                                tooltip: 'Reset Password',
                              ),
                            ),
                          ),

                          // Delete button
                          Positioned(
                            right: 8,
                            top: 8,
                            bottom: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4242).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFFF4242),
                                  size: 20,
                                ),
                                onPressed: () => controller.deleteUser(
                                  user['id'] ?? '',
                                  user['namaLengkap']?.toString() ?? '-',
                                ),
                                tooltip: 'Hapus',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
                  ),
            ],
          ),
        ),
      ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      controller.clearForm();
      Get.toNamed(Routes.adminTambahPengguna);
    },
    backgroundColor: const Color(0xFF02B1BA),
    child: const Icon(Icons.add, color: Colors.white),
  ),
);
  }

  Widget _buildCompactStat(String label, int count, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

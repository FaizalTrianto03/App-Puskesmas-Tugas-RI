import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  _buildFilterSection(),
                  const SizedBox(height: 16),
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
              title: 'Selesai Hari Ini',
              value: controller.countSelesaiHariIni.toString(),
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

  Widget _buildFilterSection() {
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
      final resepList = controller.filteredResep;
      
      if (resepList.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resepList.length,
        itemBuilder: (context, index) {
          final resep = resepList[index];
          return _ResepCard(resep: resep, index: index);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada resep',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada resep untuk kategori ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
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
  final Map<String, dynamic> resep;
  final int index;

  const _ResepCard({
    required this.resep,
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          Get.to(
            () => DetailResepView(resep: widget.resep),
            transition: Transition.rightToLeft,
          );
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
                        color: widget.resep['statusColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.resep['id'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.resep['statusColor'],
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
                        color: widget.resep['statusColor'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.resep['status'],
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
                        widget.resep['namaPasien'],
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
                      'No. Antrean: ${widget.resep['noAntrean']}',
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
                      '${widget.resep['poli']} • ${widget.resep['dokter']}',
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
                      widget.resep['tanggal'],
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
                        '${widget.resep['jumlahObat']} jenis obat',
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
}

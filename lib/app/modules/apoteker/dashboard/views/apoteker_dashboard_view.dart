import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';
import '../../settings/views/apoteker_settings_view.dart';
import '../../peringatan_obat/views/peringatan_obat_view.dart';
import '../../resep_obat/views/resep_obat_view.dart';
import '../../resep_obat/bindings/resep_obat_binding.dart';
import 'package:get/get.dart';

class ApotekerDashboardView extends StatefulWidget {
  const ApotekerDashboardView({Key? key}) : super(key: key);

  @override
  State<ApotekerDashboardView> createState() => _ApotekerDashboardViewState();
}

class _ApotekerDashboardViewState extends State<ApotekerDashboardView> {
  bool _isHoverProfileCard = false;
  bool _isPressedProfileCard = false;
  bool _isHoverLihatDetail = false;
  bool _isPressedLihatDetail = false;
  int? _hoveredStokIndex;
  int? _hoveredObatIndex;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Dashboard Apoteker',
            style: TextStyle(
              color: Color(0xFF02B1BA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildMenuUtama(context),
                      const SizedBox(height: 16),
                      _buildAlertSection(context),
                      const SizedBox(height: 24),
                      _buildStatusStokSection(),
                      const SizedBox(height: 24),
                      _buildObatSeringDiresepkan(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoverProfileCard = true),
      onExit: (_) => setState(() => _isHoverProfileCard = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressedProfileCard = true),
        onTapUp: (_) => setState(() => _isPressedProfileCard = false),
        onTapCancel: () => setState(() => _isPressedProfileCard = false),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ApotekerSettingsView()),
          );
        },
        child: AnimatedScale(
          scale:
              _isPressedProfileCard ? 0.97 : (_isHoverProfileCard ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Color(0xFF02B1BA)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'apt. Aditama, S. Farm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Apoteker',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuUtama(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                context: context,
                icon: Icons.medication,
                title: 'Resep Obat',
                subtitle: 'Kelola resep masuk',
                color: const Color(0xFF02B1BA),
                onTap: () {
                  ResepObatBinding().dependencies();
                  Get.to(
                    () => const ResepObatView(),
                    transition: Transition.rightToLeft,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMenuCard(
                context: context,
                icon: Icons.inventory_2,
                title: 'Stok Obat',
                subtitle: 'Manajemen persediaan',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  // TODO: Navigate to Stok Obat
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _MenuCardWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildAlertSection(BuildContext context) {
    return Container(
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
          // Stok Kritis Alert
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4242).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF4242),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STOK KRITIS!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4242),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '5 obat hampir habis dan perlu segera direstock',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Peringatan Kedaluwarsa
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peringatan Kedaluwarsa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3 obat akan kedaluwarsa dalam 30 hari',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoverLihatDetail = true),
            onExit: (_) => setState(() => _isHoverLihatDetail = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressedLihatDetail = true),
              onTapUp: (_) => setState(() => _isPressedLihatDetail = false),
              onTapCancel: () => setState(() => _isPressedLihatDetail = false),
              child: AnimatedScale(
                scale:
                    _isPressedLihatDetail
                        ? 0.95
                        : (_isHoverLihatDetail ? 1.03 : 1.0),
                duration: const Duration(milliseconds: 150),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PeringatanObatView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: _isHoverLihatDetail ? 4 : 0,
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStokSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Stok Obat Real-Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF02B1BA),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStokCard(
                value: '245',
                label: 'Stok Aman',
                color: const Color(0xFF4CAF50),
                backgroundColor: const Color(0xFFE8F5E9),
                index: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStokCard(
                value: '12',
                label: 'Stok Hampir',
                color: const Color(0xFF9C27B0),
                backgroundColor: const Color(0xFFF3E5F5),
                index: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStokCard(
                value: '5',
                label: 'Stok Kritis',
                color: const Color(0xFFFF4242),
                backgroundColor: const Color(0xFFFFEBEE),
                index: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStokCard(
                value: '3',
                label: 'Segera Expired',
                color: const Color(0xFFFF9800),
                backgroundColor: const Color(0xFFFFF3E0),
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStokCard({
    required String value,
    required String label,
    required Color color,
    required Color backgroundColor,
    int? index,
  }) {
    final isHovered = _hoveredStokIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredStokIndex = index),
      onExit: (_) => setState(() => _hoveredStokIndex = null),
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObatSeringDiresepkan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Obat Sering Diresepkan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF02B1BA),
          ),
        ),
        const SizedBox(height: 12),
        _buildObatItem(
          namaObat: 'Paracetamol',
          jumlahResep: '175 Resep/Bulan',
          icon: Icons.medication,
          index: 0,
        ),
        const SizedBox(height: 12),
        _buildObatItem(
          namaObat: 'Vitamin C',
          jumlahResep: '105 Resep/Bulan',
          icon: Icons.medication,
          index: 1,
        ),
        const SizedBox(height: 12),
        _buildObatItem(
          namaObat: 'Amoxicillin',
          jumlahResep: '98 Resep/Bulan',
          icon: Icons.medication,
          index: 2,
        ),
      ],
    );
  }

  Widget _buildObatItem({
    required String namaObat,
    required String jumlahResep,
    required IconData icon,
    int? index,
  }) {
    final isHovered = _hoveredObatIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredObatIndex = index),
      onExit: (_) => setState(() => _hoveredObatIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(isHovered ? 4 : 0, 0, 0),
        child: Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF02B1BA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF02B1BA), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaObat,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jumlahResep,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCardWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCardWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuCardWidget> createState() => _MenuCardWidgetState();
}

class _MenuCardWidgetState extends State<_MenuCardWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.color, widget.color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
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

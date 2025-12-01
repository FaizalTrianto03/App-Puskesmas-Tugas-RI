import 'package:flutter/material.dart';

import '../../../../widgets/quarter_circle_background.dart';
import '../../bpjs/views/info_bpjs_view.dart';
import '../../lokasi/views/lokasi_puskesmas_view.dart';

class LayananLainnyaView extends StatefulWidget {
  final bool hasActiveQueue;
  const LayananLainnyaView({super.key, this.hasActiveQueue = false});

  @override
  State<LayananLainnyaView> createState() => _LayananLainnyaViewState();
}

class _LayananLainnyaViewState extends State<LayananLainnyaView> {
  bool _isHoverLokasi = false;
  bool _isHoverBPJS = false;
  bool _isPressedLokasi = false;
  bool _isPressedBPJS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Layanan Lainnya',
          style: TextStyle(
            color: Color(0xFF02B1BA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: QuarterCircleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuButton(
                context,
                icon: Icons.location_on,
                title: 'Lokasi Puskesmas',
                isHover: _isHoverLokasi,
                isPressed: _isPressedLokasi,
                onHoverChange: (hover) {
                  setState(() {
                    _isHoverLokasi = hover;
                  });
                },
                onPressedChange: (pressed) {
                  setState(() {
                    _isPressedLokasi = pressed;
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LokasiPuskesmasView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                icon: Icons.shield,
                title: 'Info BPJS',
                isHover: _isHoverBPJS,
                isPressed: _isPressedBPJS,
                onHoverChange: (hover) {
                  setState(() {
                    _isHoverBPJS = hover;
                  });
                },
                onPressedChange: (pressed) {
                  setState(() {
                    _isPressedBPJS = pressed;
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoBpjsView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isHover,
    required bool isPressed,
    required Function(bool) onHoverChange,
    required Function(bool) onPressedChange,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => onPressedChange(true),
        onTapUp: (_) => onPressedChange(false),
        onTapCancel: () => onPressedChange(false),
        onTap: onTap,
        child: Transform.scale(
          scale: isPressed ? 0.95 : (isHover ? 1.02 : 1.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHover
                    ? [const Color(0xFF00959F), const Color(0xFF5FD8D1)]
                    : [const Color(0xFF02B1BA), const Color(0xFF84F3EE)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isHover
                      ? const Color(0xFF02B1BA).withOpacity(0.6)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isHover ? 16 : 4,
                  offset: Offset(0, isHover ? 6 : 2),
                ),
              ],
            ),
            child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isHover ? 0.5 : 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../widgets/quarter_circle_background.dart';

class LaporanKeuanganView extends StatelessWidget {
  const LaporanKeuanganView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF02B1BA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(
            color: Color(0xFF02B1BA),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Balance
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF02B1BA), Color(0xFF84F3EE)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pendapatan Bulan Ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rp 125.450.000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rp 145.200.000',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rp 19.750.000',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Pendapatan per Kategori
                    const Text(
                      'Pendapatan per Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIncomeCard(
                      'Pelayanan Kesehatan',
                      'Rp 85.500.000',
                      '58.9%',
                      const Color(0xFF02B1BA),
                    ),
                    const SizedBox(height: 8),
                    _buildIncomeCard(
                      'Penjualan Obat',
                      'Rp 42.300.000',
                      '29.1%',
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 8),
                    _buildIncomeCard(
                      'Tindakan Medis',
                      'Rp 12.400.000',
                      '8.5%',
                      const Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 8),
                    _buildIncomeCard(
                      'Lain-lain',
                      'Rp 5.000.000',
                      '3.5%',
                      const Color(0xFF3F51B5),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Pengeluaran
                    const Text(
                      'Pengeluaran Bulan Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4242),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseCard(
                      'Pembelian Obat & Alkes',
                      'Rp 12.500.000',
                      Icons.medical_services,
                      const Color(0xFFFFA726),
                    ),
                    const SizedBox(height: 8),
                    _buildExpenseCard(
                      'Gaji Pegawai',
                      'Rp 5.200.000',
                      Icons.people,
                      const Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 8),
                    _buildExpenseCard(
                      'Operasional',
                      'Rp 1.550.000',
                      Icons.business,
                      const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 8),
                    _buildExpenseCard(
                      'Pemeliharaan',
                      'Rp 500.000',
                      Icons.build,
                      const Color(0xFF00BCD4),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Transaksi Terakhir
                    const Text(
                      'Transaksi Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionCard(
                      'Pembayaran Konsultasi',
                      '24 Jan 2025, 14:30',
                      'Rp 50.000',
                      true,
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionCard(
                      'Pembelian Obat',
                      '24 Jan 2025, 13:15',
                      'Rp 125.000',
                      true,
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionCard(
                      'Pembelian Alat Kesehatan',
                      '24 Jan 2025, 10:00',
                      'Rp 2.500.000',
                      false,
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionCard(
                      'Tindakan Medis',
                      '23 Jan 2025, 16:45',
                      'Rp 200.000',
                      true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(String title, String amount, String percentage, Color color) {
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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(String title, String amount, IconData icon, Color color) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.remove_circle,
            color: Color(0xFFFF4242),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(String title, String date, String amount, bool isIncome) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFFF4242).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.add : Icons.remove,
              color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFFF4242),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFFF4242),
            ),
          ),
        ],
      ),
    );
  }
}

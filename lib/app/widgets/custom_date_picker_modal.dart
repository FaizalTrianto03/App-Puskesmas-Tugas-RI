import 'package:flutter/material.dart';

/// Custom Date Picker Modal yang informatif untuk ibu-ibu
/// Menampilkan tanggal dengan format yang mudah dipahami
class CustomDatePickerModal {
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final selectedDate = initialDate ?? now;
    final minDate = firstDate ?? DateTime(1900);
    final maxDate = lastDate ?? now;

    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DatePickerBottomSheet(
        initialDate: selectedDate,
        firstDate: minDate,
        lastDate: maxDate,
      ),
    );
  }
}

class _DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  final List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day;
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;

    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    yearController = FixedExtentScrollController(
      initialItem: widget.lastDate.year - selectedYear,
    );
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getAgeText() {
    final now = DateTime.now();
    final birthDate = DateTime(selectedYear, selectedMonth, selectedDay);
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age > 0 ? '$age tahun' : '0 tahun';
  }

  @override
  Widget build(BuildContext context) {
    final maxDays = getDaysInMonth(selectedYear, selectedMonth);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Tanggal Lahir',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02B1BA),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02B1BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        color: Color(0xFF02B1BA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedDay.toString().padLeft(2, '0')} ${monthNames[selectedMonth - 1]} $selectedYear',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02B1BA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Umur: ${_getAgeText()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Picker labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Tanggal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Bulan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Tahun',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Pickers
          Expanded(
            child: Stack(
              children: [
                // Selection highlight
                Center(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02B1BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF02B1BA).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Pickers
                Row(
                  children: [
                    // Day picker
                    Expanded(
                      flex: 2,
                      child: ListWheelScrollView.useDelegate(
                        controller: dayController,
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedDay = (index % maxDays) + 1;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final day = (index % maxDays) + 1;
                            final isSelected = day == selectedDay;
                            return Center(
                              child: Text(
                                day.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: isSelected ? 24 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF02B1BA)
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          },
                          childCount: maxDays * 100,
                        ),
                      ),
                    ),

                    // Month picker
                    Expanded(
                      flex: 3,
                      child: ListWheelScrollView.useDelegate(
                        controller: monthController,
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMonth = (index % 12) + 1;
                            // Adjust day if it exceeds max days in new month
                            final maxDaysInMonth =
                                getDaysInMonth(selectedYear, selectedMonth);
                            if (selectedDay > maxDaysInMonth) {
                              selectedDay = maxDaysInMonth;
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final month = (index % 12) + 1;
                            final isSelected = month == selectedMonth;
                            return Center(
                              child: Text(
                                monthNames[month - 1],
                                style: TextStyle(
                                  fontSize: isSelected ? 20 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF02B1BA)
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          },
                          childCount: 12 * 100,
                        ),
                      ),
                    ),

                    // Year picker
                    Expanded(
                      flex: 2,
                      child: ListWheelScrollView.useDelegate(
                        controller: yearController,
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedYear = widget.lastDate.year - index;
                            // Adjust day if it exceeds max days in new month/year
                            final maxDaysInMonth =
                                getDaysInMonth(selectedYear, selectedMonth);
                            if (selectedDay > maxDaysInMonth) {
                              selectedDay = maxDaysInMonth;
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final year = widget.lastDate.year - index;
                            final isSelected = year == selectedYear;
                            return Center(
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 24 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF02B1BA)
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          },
                          childCount: widget.lastDate.year - widget.firstDate.year + 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geser untuk memilih tanggal, bulan, dan tahun',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedDateTime =
                          DateTime(selectedYear, selectedMonth, selectedDay);
                      Navigator.pop(context, selectedDateTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02B1BA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

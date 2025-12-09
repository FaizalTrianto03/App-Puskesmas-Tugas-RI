import 'package:get_storage/get_storage.dart';

class AntreanService {
  static final AntreanService _instance = AntreanService._internal();
  factory AntreanService() => _instance;
  AntreanService._internal();

  final GetStorage _box = GetStorage();

  // CREATE
  Future<void> saveAntrean(Map<String, dynamic> antreanData) async {
    final antreanList = getAntreanList();
    antreanList.add(antreanData);
    await _box.write('antrean_list', antreanList);
    
    // Save active queue for current user
    await _box.write('active_queue', antreanData);
  }

  // READ
  List<Map<String, dynamic>> getAntreanList() {
    final list = _box.read('antrean_list') as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? getActiveQueue() {
    final queue = _box.read('active_queue');
    if (queue == null) return null;
    return Map<String, dynamic>.from(queue);
  }

  List<Map<String, dynamic>> getAntreanByPoli(String poli) {
    final list = getAntreanList();
    return list.where((antrean) => antrean['poli'] == poli).toList();
  }

  List<Map<String, dynamic>> getAntreanByDate(String tanggal) {
    final list = getAntreanList();
    return list.where((antrean) => antrean['tanggal'] == tanggal).toList();
  }

  // UPDATE
  Future<bool> updateAntreanStatus(String antreanId, String status) async {
    final list = getAntreanList();
    final index = list.indexWhere((antrean) => antrean['id'] == antreanId);
    
    if (index == -1) return false;
    
    list[index]['status'] = status;
    await _box.write('antrean_list', list);
    return true;
  }

  // DELETE
  Future<void> clearActiveQueue() async {
    await _box.remove('active_queue');
  }

  Future<void> clearAllAntrean() async {
    await _box.remove('antrean_list');
  }
}

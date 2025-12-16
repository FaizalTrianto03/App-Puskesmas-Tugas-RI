import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/services/firestore/user_profile_firestore_service.dart';
import '../../../../utils/snackbar_helper.dart';

class KelolaDataDiriController extends GetxController {
  final UserProfileFirestoreService _profileService = UserProfileFirestoreService();
  
  final isLoading = false.obs;
  
  // Form controllers
  late TextEditingController namaController;
  late TextEditingController nikController;
  late TextEditingController alamatController;
  late TextEditingController noHpController;
  late TextEditingController emailController;
  
  final jenisKelamin = 'P'.obs;
  final tanggalLahir = '09/09/2003'.obs;

  @override
  void onInit() {
    super.onInit();
    namaController = TextEditingController();
    nikController = TextEditingController();
    alamatController = TextEditingController();
    noHpController = TextEditingController();
    emailController = TextEditingController();
    
    loadUserData();
  }

  @override
  void onClose() {
    namaController.dispose();
    nikController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      print('KelolaDataDiriController: loadUserData() start');
      isLoading.value = true;
      final profile = await _profileService.getUserProfile();
      
      if (profile != null) {
        print('KelolaDataDiriController: Profile loaded - ${profile.namaLengkap}');
        namaController.text = profile.namaLengkap;
        nikController.text = profile.nik ?? '';
        alamatController.text = profile.alamat ?? '';
        noHpController.text = profile.noHp ?? '';
        emailController.text = profile.email;
        
        if (profile.jenisKelamin != null) {
          jenisKelamin.value = profile.jenisKelamin!;
        }
        if (profile.tanggalLahir != null) {
          tanggalLahir.value = profile.tanggalLahir!;
        }
        
        print('KelolaDataDiriController: Fields populated');
        print('  Nama: ${namaController.text}');
        print('  NIK: ${nikController.text}');
        print('  Alamat: ${alamatController.text}');
        print('  No HP: ${noHpController.text}');
        print('  Email: ${emailController.text}');
        print('  Jenis Kelamin: ${jenisKelamin.value}');
        print('  Tanggal Lahir: ${tanggalLahir.value}');
      } else {
        print('KelolaDataDiriController: Profile is null');
      }
    } catch (e) {
      print('KelolaDataDiriController: Error loading user data: $e');
    } finally {
      isLoading.value = false;
      print('KelolaDataDiriController: loadUserData() finished');
    }
  }

  Future<void> updateDataDiri() async {
    try {
      isLoading.value = true;
      
      await _profileService.updateDataDiri(
        namaLengkap: namaController.text.trim(),
        nik: nikController.text.trim(),
        noHp: noHpController.text.trim(),
        alamat: alamatController.text.trim(),
        jenisKelamin: jenisKelamin.value,
        tanggalLahir: tanggalLahir.value,
      );
      
      SnackbarHelper.showSuccess('Data berhasil diperbarui');
      Get.back();
    } catch (e) {
      print('Error updating data diri: $e');
      SnackbarHelper.showError('Gagal memperbarui data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

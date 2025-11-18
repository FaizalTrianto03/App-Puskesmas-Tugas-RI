import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ConfirmationType {
  confirmation,
  danger,
  warning,
  info,
}

class ConfirmationDialogConfig {
  final Color iconBgColor;
  final Color iconColor;
  final Color confirmBgColor;
  final IconData icon;

  const ConfirmationDialogConfig({
    required this.iconBgColor,
    required this.iconColor,
    required this.confirmBgColor,
    required this.icon,
  });
}

class ConfirmationDialog {
  static const Map<ConfirmationType, ConfirmationDialogConfig> _typeConfigs = {
    ConfirmationType.confirmation: ConfirmationDialogConfig(
      iconBgColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF2563EB),
      confirmBgColor: Color(0xFF2563EB),
      icon: Icons.help_outline,
    ),
    ConfirmationType.danger: ConfirmationDialogConfig(
      iconBgColor: Color(0xFFFFE4E6),
      iconColor: Color(0xFFDC2626),
      confirmBgColor: Color(0xFFDC2626),
      icon: Icons.warning_amber_rounded,
    ),
    ConfirmationType.warning: ConfirmationDialogConfig(
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      confirmBgColor: Color(0xFFD97706),
      icon: Icons.warning_outlined,
    ),
    ConfirmationType.info: ConfirmationDialogConfig(
      iconBgColor: Color(0xFFF1F5F9),
      iconColor: Color(0xFF475569),
      confirmBgColor: Color(0xFF475569),
      icon: Icons.info_outline,
    ),
  };

  static Future<bool?> show({
    required String title,
    required String message,
    ConfirmationType type = ConfirmationType.confirmation,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? customContent,
    bool requireDoubleConfirm = false,
    String? doubleConfirmText,
  }) async {
    final config = _typeConfigs[type] ?? _typeConfigs[ConfirmationType.confirmation]!;
    final RxBool isLoading = false.obs;
    final RxString doubleConfirmInput = ''.obs;
    final effectiveDoubleConfirmText = doubleConfirmText ?? 'Saya Setuju';

    return await Get.dialog<bool>(
      PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop && !isLoading.value) {
            Get.back(result: false);
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: config.iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          config.icon,
                          color: config.iconColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Message
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Custom Content
                      if (customContent != null) ...[
                        const SizedBox(height: 16),
                        customContent,
                      ],
                    ],
                  ),
                ),

                // Double Confirm Input (if required)
                if (requireDoubleConfirm)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                            children: [
                              const TextSpan(text: 'Ketik '),
                              TextSpan(
                                text: effectiveDoubleConfirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const TextSpan(text: ' untuk melakukan konfirmasi.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextField(
                            onChanged: (value) => doubleConfirmInput.value = value,
                            enabled: !isLoading.value,
                            decoration: InputDecoration(
                              hintText: 'Ketik $effectiveDoubleConfirmText',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6B7C93),
                                  width: 2,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              filled: isLoading.value,
                              fillColor: isLoading.value ? const Color(0xFFF1F5F9) : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Obx(
                    () {
                      final bool isConfirmDisabled = isLoading.value ||
                          (requireDoubleConfirm &&
                              doubleConfirmInput.value.trim().toLowerCase() !=
                                  effectiveDoubleConfirmText.trim().toLowerCase());

                      return Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading.value
                                  ? null
                                  : () {
                                      onCancel?.call();
                                      Get.back(result: false);
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledForegroundColor: const Color(0xFF94A3B8),
                              ),
                              child: Text(
                                cancelText ?? 'Batal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Confirm Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isConfirmDisabled
                                  ? null
                                  : () async {
                                      if (onConfirm != null) {
                                        isLoading.value = true;
                                        try {
                                          onConfirm();
                                          // Small delay to show loading state
                                          await Future.delayed(
                                            const Duration(milliseconds: 100),
                                          );
                                        } finally {
                                          isLoading.value = false;
                                        }
                                      }
                                      Get.back(result: true);
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: config.confirmBgColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: config.confirmBgColor.withValues(alpha: 0.5),
                                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      confirmText ?? 'Confirm',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

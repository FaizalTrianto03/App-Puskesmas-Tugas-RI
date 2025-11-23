import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FormFieldType {
  text,
  email,
  password,
  textarea,
  dropdown,
  switchToggle,
  number,
}

class FormFieldConfig {
  final String label;
  final FormFieldType type;
  final TextEditingController? controller;
  final IconData? icon;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final bool? switchValue;
  final Function(String)? onDropdownChanged;
  final Function(bool)? onSwitchChanged;
  final String? hint;
  final int? maxLines;
  final bool required;
  final TextInputType? keyboardType;
  final RxBool? obscureText;
  final VoidCallback? onToggleVisibility;

  FormFieldConfig({
    required this.label,
    required this.type,
    this.controller,
    this.icon,
    this.dropdownItems,
    this.dropdownValue,
    this.switchValue,
    this.onDropdownChanged,
    this.onSwitchChanged,
    this.hint,
    this.maxLines,
    this.required = true,
    this.keyboardType,
    this.obscureText,
    this.onToggleVisibility,
  });
}

class FormModal {
  static void show({
    required String title,
    required List<FormFieldConfig> fields,
    required VoidCallback onSubmit,
    VoidCallback? onCancel,
    String submitText = 'Simpan',
    String cancelText = 'Batal',
    IconData? titleIcon,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive width calculation
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth - 32;
            
            // Dynamic max height based on screen size
            final maxBodyHeight = screenHeight * 0.55;
            
            return Container(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: screenHeight * 0.80,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF02B1BA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (titleIcon != null) ...[
                          Icon(titleIcon, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () {
                            onCancel?.call();
                            Get.back();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Body with flexible height
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: maxBodyHeight),
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...fields.asMap().entries.map((entry) {
                              final index = entry.key;
                              final field = entry.value;
                              return Column(
                                children: [
                                  if (index > 0) const SizedBox(height: 16),
                                  _buildFormField(field),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 24),
                            // Buttons with responsive layout
                            LayoutBuilder(
                              builder: (context, buttonConstraints) {
                                // Stack buttons vertically if width is too small
                                final useVerticalLayout = buttonConstraints.maxWidth < 300;
                                
                                if (useVerticalLayout) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton(
                                        onPressed: onSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF02B1BA),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          submitText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () {
                                          onCancel?.call();
                                          Get.back();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF02B1BA),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          cancelText,
                                          style: const TextStyle(
                                            color: Color(0xFF02B1BA),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                
                                return Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          onCancel?.call();
                                          Get.back();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF02B1BA),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          cancelText,
                                          style: const TextStyle(
                                            color: Color(0xFF02B1BA),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: onSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF02B1BA),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          submitText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildFormField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.number:
        return _buildTextField(field);
      
      case FormFieldType.password:
        return _buildPasswordField(field);
      
      case FormFieldType.textarea:
        return _buildTextArea(field);
      
      case FormFieldType.dropdown:
        return _buildDropdown(field);
      
      case FormFieldType.switchToggle:
        return _buildSwitch(field);
    }
  }

  static Widget _buildTextField(FormFieldConfig field) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF02B1BA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: field.controller,
        keyboardType: field.keyboardType ?? 
          (field.type == FormFieldType.email ? TextInputType.emailAddress :
           field.type == FormFieldType.number ? TextInputType.number :
           TextInputType.text),
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w500,
          ),
          hintText: field.hint,
          prefixIcon: field.icon != null 
            ? Icon(
                field.icon,
                color: Colors.grey,
                size: 20,
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF02B1BA),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F9FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  static Widget _buildPasswordField(FormFieldConfig field) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF02B1BA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: field.controller,
        obscureText: field.obscureText?.value ?? true,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w500,
          ),
          hintText: field.hint,
          prefixIcon: field.icon != null 
            ? Icon(
                field.icon,
                color: Colors.grey,
                size: 20,
              )
            : null,
          suffixIcon: IconButton(
            icon: Icon(
              (field.obscureText?.value ?? true)
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: field.onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF02B1BA),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F9FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
      ),
    ));
  }

  static Widget _buildTextArea(FormFieldConfig field) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: field.controller,
        maxLines: field.maxLines ?? 4,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
          hintText: field.hint,
          alignLabelWithHint: true,
          prefixIcon: field.icon != null 
            ? Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Icon(field.icon, color: Colors.grey),
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF1F9FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  static Widget _buildDropdown(FormFieldConfig field) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: field.dropdownValue,
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF02B1BA),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: field.icon != null 
            ? Icon(field.icon, color: Colors.grey)
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF1F9FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: field.dropdownItems?.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) field.onDropdownChanged?.call(value);
        },
      ),
    );
  }

  static Widget _buildSwitch(FormFieldConfig field) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (field.icon != null) ...[
            Icon(field.icon, color: const Color(0xFF02B1BA)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              field.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Switch(
            value: field.switchValue ?? false,
            onChanged: field.onSwitchChanged,
            activeColor: const Color(0xFF02B1BA),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.suffix,
    this.prefixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? suffix;
  final IconData? prefixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffix: suffix,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
    );
  }
}

class NumericTextField extends StatelessWidget {
  const NumericTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.suffixText,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint ?? '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      suffix: suffixText != null
          ? Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                suffixText!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : null,
    );
  }
}

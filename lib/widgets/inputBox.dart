import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'package:flutter/services.dart';

class InputBox extends StatefulWidget {
  final String? label;
  final String hintText;
  final bool obscure;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool isNumber;

  const InputBox({
    super.key,
    this.label,
    required this.hintText,
    required this.obscure,
    this.controller,
    this.onChanged,
    this.isNumber = false,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTheme.textStyle1.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.paddingSmall),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          keyboardType: widget.isNumber ? TextInputType.numberWithOptions(decimal: true) : null,
          inputFormatters: widget.isNumber
              ? [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*'))]
              : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTheme.textStyle2
                .copyWith(color: AppTheme.textColor1.withValues(alpha: .7)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

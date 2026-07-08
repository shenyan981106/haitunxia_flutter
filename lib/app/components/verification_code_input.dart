import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const VerificationCodeInput({
    Key? key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.textStyle,
    this.fillColor = const Color(0xFFF8F9FA),
    this.borderColor = const Color(0xFFE8E8E8),
    this.focusedBorderColor = const Color(0xFF3C7EFF),
    this.borderRadius = 8.0,
    this.width = 48.0,
    this.height = 56.0,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late String _code;

  @override
  void initState() {
    super.initState();
    _initVariables();
  }

  void _initVariables() {
    _code = '';
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );

    // 为第一个输入框设置焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });

    // 添加焦点监听
    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => _buildInputBox(index),
      ),
    );
  }

  Widget _buildInputBox(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        boxShadow: widget.boxShadow,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 1,
          textAlign: TextAlign.center,
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: widget.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius!),
              borderSide: BorderSide(
                color: _focusNodes[index].hasFocus
                    ? widget.focusedBorderColor!
                    : widget.borderColor!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius!),
              borderSide: BorderSide(
                color: widget.focusedBorderColor!,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) {
            _onInputChanged(index, value);
          },
          onSubmitted: (value) {
            _onInputChanged(index, value);
          },
          onEditingComplete: () {
            _onEditingComplete(index);
          },
        ),
      ),
    );
  }

  void _onInputChanged(int index, String value) {
    if (value.isNotEmpty) {
      _code = _code.substring(0, index) + value + _code.substring(index + 1);
      if (index < widget.length - 1) {
        // 自动聚焦到下一个输入框
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // 输入完成
        _onCompleted();
      }
    } else {
      _code = _code.substring(0, index) + _code.substring(index + 1);
    }

    // 通知父组件代码变�?    if (widget.onChanged != null) {
      widget.onChanged!(_code);
    }
  }

  void _onEditingComplete(int index) {
    if (index == widget.length - 1) {
      _onCompleted();
    }
  }

  void _onCompleted() {
    if (_code.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(_code);
    }
  }

  // 获取当前输入的验证码
  String getCode() {
    return _code;
  }
}

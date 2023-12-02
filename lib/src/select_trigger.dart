// Copyright (c) 2023 Yang,Zhong
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SelectedBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  Function(T item) unselect,
);

class SelectDropdownTrigger<T> extends StatefulWidget {
  final Function(bool hasFocus) onFucusChanged;
  final SelectedBuilder<T> selectedBuilder;
  final Function()? onBackspace;
  final List<T> selected;
  final Function(T item) unselect;
  final FocusNode focusNode;
  final Function(String input)? onInput;
  final InputDecoration? decoration;
  final BoxDecoration? prefixDecoration;
  final Function(TextEditingController)? onEnter;
  const SelectDropdownTrigger({
    super.key,
    required this.onFucusChanged,
    required this.selectedBuilder,
    required this.selected,
    required this.unselect,
    required this.focusNode,
    this.decoration,
    this.onInput,
    this.onBackspace,
    this.onEnter,
    this.prefixDecoration,
  });

  @override
  State<StatefulWidget> createState() => _StateSelectDropdownTrigger<T>();
}

class _StateSelectDropdownTrigger<T> extends State<SelectDropdownTrigger<T>> {
  TextEditingController controller = TextEditingController();

  Timer? _debounce;

  FocusNode _keyFocusNode = FocusNode();

  String _lastInput = "1";

  @override
  void initState() {
    widget.focusNode.addListener(_onFocusChanged);
    controller.addListener(_onInput);
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    controller.removeListener(_onInput);
    super.dispose();
  }

  _onInput() {
    if (widget.onInput != null) {
      widget.onInput!(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    var decoration = widget.decoration ?? InputDecoration();
    return RawKeyboardListener(
      focusNode: _keyFocusNode,
      autofocus: true,
      onKey: _onKey,
      child: TextField(
        focusNode: widget.focusNode,
        controller: controller,
        decoration: decoration.copyWith(prefixIcon: _buildSelected()),
      ),
    );
  }

  _onKey(RawKeyEvent key) {
    if (_debounce != null) {
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (_lastInput == "" &&
          key.logicalKey == LogicalKeyboardKey.backspace &&
          widget.onBackspace != null) {
        widget.onBackspace!();
      }
      _lastInput = controller.text;

      if (widget.onEnter != null &&
          key.logicalKey == LogicalKeyboardKey.enter) {
        widget.onEnter!(controller);
      }
      _debounce = null;
    });
  }

  _buildSelected() {
    return LayoutBuilder(builder: (builder, constraints) {
      if (kDebugMode) {
        print(constraints);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
        child: Container(
          decoration: widget.prefixDecoration,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widget.selected
                .map((e) => widget.selectedBuilder(context, e, widget.unselect))
                .toList(),
          ),
        ),
      );
    });
  }

  _onFocusChanged() {
    widget.onFucusChanged(widget.focusNode.hasFocus);
  }
}

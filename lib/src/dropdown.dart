// Copyright (c) 2023 Yang,Zhong
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'package:flutter/widgets.dart';

typedef TriggerBuilder = Function(
  BuildContext context,
  bool opened,
  BoxConstraints constraints,
  Function(bool opened) setOpened,
);

typedef DropdownBuilder = Function(
  BuildContext context,
  BoxConstraints constraints,
);

class MockingbirdDropdown extends StatefulWidget {
  final TriggerBuilder triggerBuilder;
  final DropdownBuilder dropdownBuilder;
  final Function(bool)? onOpenChanged;
  final VoidCallback? onDropdownRepaint;

  const MockingbirdDropdown({
    super.key,
    required this.triggerBuilder,
    required this.dropdownBuilder,
    this.onOpenChanged,
    this.onDropdownRepaint,
  });
  @override
  State<StatefulWidget> createState() => _StateMockingbirdDropdown();
}

class _StateMockingbirdDropdown extends State<MockingbirdDropdown> {
  bool _opened = false;
  BoxConstraints? _constraints;
  OverlayEntry? _entry;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_opened) {
        _showOverlay(context);
      } else {
        _entry?.remove();
        _entry = null;
      }
    });
    return LayoutBuilder(builder: (context, constraints) {
      _constraints = constraints;
      return Container(
        child: widget.triggerBuilder(
          context,
          _opened,
          constraints,
          setOpened,
        ),
      );
    });
  }

  setOpened(bool opened) {
    if (opened == _opened) {
      return;
    }
    setState(() {
      _opened = opened;
      if (widget.onOpenChanged != null) {
        widget.onOpenChanged!(_opened);
      }
    });
  }

  void _showOverlay(BuildContext context) async {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    var size = renderBox?.size ?? Size.zero;
    var offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    var maxHeight =
        MediaQuery.of(context).size.height - offset.dy - size.height;
    if (maxHeight < 0) {
      maxHeight = 10;
    }
    _entry = OverlayEntry(builder: (context) {
      return Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        child: _constraints == null
            ? Container()
            : widget.dropdownBuilder(
                context,
                BoxConstraints(
                  maxWidth: _constraints!.maxWidth,
                  maxHeight: maxHeight,
                ),
              ),
      );
    });
    Overlay.of(context).insert(_entry!);
    if (widget.onDropdownRepaint != null) {
      Future.delayed(const Duration(milliseconds: 10)).then((value) {
        widget.onDropdownRepaint!();
      });
    }
  }
}

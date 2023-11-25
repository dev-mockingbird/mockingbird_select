// Copyright (c) 2023 Yang,Zhong
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'package:flutter/material.dart';
import 'package:mockingbird_select/src/dropdown.dart';
import 'package:mockingbird_select/src/select_trigger.dart';

typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
  Function(T item, bool select) select,
);

class MockingbirdSelect<T> extends StatefulWidget {
  final SelectedBuilder<T> selectedBuilder;
  final ItemBuilder<T> itemBuilder;
  final Function(String)? onInput;
  final InputDecoration? inputDecoration;
  final BoxDecoration? selectedDecoration;
  final Function(TextEditingController)? onEnter;
  final Function(List<T> selected)? onSelectedChanged;
  final List<T> items;
  final Color? dropdownBgColor;
  final double dropdownElevation;
  final double dropdownHeight;

  const MockingbirdSelect({
    super.key,
    required this.selectedBuilder,
    required this.itemBuilder,
    required this.dropdownHeight,
    required this.items,
    this.inputDecoration,
    this.onInput,
    this.dropdownBgColor,
    this.dropdownElevation = 0.0,
    this.selectedDecoration,
    this.onEnter,
    this.onSelectedChanged,
  });
  @override
  State<StatefulWidget> createState() => _StateMockingbirdSelect<T>();
}

class _StateMockingbirdSelect<T> extends State<MockingbirdSelect<T>> {
  final List<T> selected = [];
  bool _inputFocused = false;
  bool _itemClicked = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MockingbirdDropdown(
      triggerBuilder: (context, opened, constraints, setOpened) {
        return SelectDropdownTrigger(
          focusNode: _focusNode,
          onInput: widget.onInput,
          decoration: widget.inputDecoration,
          onEnter: widget.onEnter,
          onFucusChanged: (focus) {
            _inputFocused = focus;
            shouldToggleDropdown(setOpened);
          },
          onBackspace: () {
            if (selected.isNotEmpty) {
              setState(() {
                selected.removeLast();
              });
            }
          },
          selectedBuilder: widget.selectedBuilder,
          selected: selected,
          unselect: unselect,
        );
      },
      dropdownBuilder: (context, constraints) {
        var items = widget.items
            .map(
              (v) => widget.itemBuilder(
                context,
                v,
                selected.contains(v),
                select,
              ),
            )
            .toList();
        return _SelectDropdown(
          constraints: constraints,
          items: items,
          bgColor: widget.dropdownBgColor,
          elevation: widget.dropdownElevation,
        );
      },
    );
  }

  shouldToggleDropdown(setOpened) {
    if (_inputFocused) {
      setOpened(true);
      return;
    }
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      if (!_itemClicked) {
        setOpened(false);
      }
    });
  }

  unselect(T item) {
    selected.remove(item);
    if (widget.onSelectedChanged != null) {
      widget.onSelectedChanged!(selected);
    }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 50)).then(
      (value) => _focusNode.requestFocus(),
    );
  }

  select(T item, bool select) {
    _setItemClick();
    if (!select) {
      selected.remove(item);
      if (widget.onSelectedChanged != null) {
        widget.onSelectedChanged!(selected);
      }
      return;
    }
    if (!selected.contains(item)) {
      selected.add(item);
      if (widget.onSelectedChanged != null) {
        widget.onSelectedChanged!(selected);
      }
    }
    setState(() {});
  }

  _setItemClick() {
    _itemClicked = true;
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      _itemClicked = false;
      _focusNode.requestFocus();
    });
  }
}

class _SelectDropdown extends StatefulWidget {
  final BoxConstraints constraints;
  final Color? bgColor;
  final double elevation;
  final List<Widget> items;
  const _SelectDropdown({
    required this.constraints,
    required this.items,
    this.bgColor,
    this.elevation = 0.0,
  });
  @override
  State<StatefulWidget> createState() => _SelectDropdownState();
}

class _SelectDropdownState extends State<_SelectDropdown> {
  double _dropdownHeight = 0;
  final List<GlobalKey> _globalkeys = [];
  double _currentScrollOffset = 0;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    for (var i = 0; i < widget.items.length; i++) {
      _globalkeys.add(GlobalKey());
    }
    scrollController.addListener(_recordDropdownOffset);
    super.initState();
  }

  @override
  dispose() {
    scrollController.removeListener(_recordDropdownOffset);
    super.dispose();
  }

  _recordDropdownOffset() {
    _currentScrollOffset = scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      double height = 0;
      for (var key in _globalkeys) {
        var size = key.currentContext?.size;
        if (size == null) {
          continue;
        }
        height += size.height;
      }
      if (_dropdownHeight != height) {
        setState(() {
          _dropdownHeight = height;
        });
        return;
      }
      scrollController.jumpTo(_currentScrollOffset);
    });
    List<Widget> items = [];
    for (var i = 0; i < widget.items.length; i++) {
      items.add(Container(key: _globalkeys[i], child: widget.items[i]));
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.constraints.maxWidth,
        maxHeight: _dropdownHeight < widget.constraints.maxHeight
            ? _dropdownHeight
            : widget.constraints.maxHeight,
      ),
      child: Material(
        color: widget.bgColor,
        elevation: widget.elevation,
        child: ListView(
          controller: scrollController,
          children: items,
        ),
      ),
    );
  }
}

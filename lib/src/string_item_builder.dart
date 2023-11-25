// Copyright (c) 2023 Yang,Zhong
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'package:flutter/material.dart';

Widget buildStringDropdownItem(
  BuildContext context,
  String item,
  bool isSelected,
  Function(String item, bool select) select,
) {
  return GestureDetector(
    onTap: () {
      select(item, true);
    },
    child: ListTile(
      title: Text(item),
      trailing: isSelected
          ? IconButton(
              onPressed: () {
                select(item, false);
              },
              icon: const Icon(Icons.close),
            )
          : null,
    ),
  );
}

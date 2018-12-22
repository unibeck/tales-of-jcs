import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/CircleButton.dart';

class VerticalOriginList {
  List<List<Widget>> _stack = [[], [], []];
  int originIndex = 1;

  VerticalOriginList();

  List<List<Widget>> get stack {
    return _stack;
  }

  List<List<Widget>> get aboveChildren {
    return _stack.sublist(originIndex + 1);
  }

  void addRowToAboveChildren(List<Widget> row) {
    _stack.add(row);
  }

  List<Widget> get originRow {
    return _stack[originIndex];
  }

  List<List<Widget>> get belowChildren {
    return _stack.sublist(0, originIndex);
  }

  void addRowToBelowChildren(List<Widget> row) {
    originIndex++;
    _stack.insert(0, row);
  }

  List<Container> get buildRowStack {
    List<Container> rowStack = [];

    rowStack.add(Container(
        padding: originRow.length % 2 == 0
            ? const EdgeInsets.only(left: CircleButton.defaultSize)
            : EdgeInsets.zero,
        child: Row(
          children: originRow,
      )
    ));

    List<List<Widget>> aboveRows = aboveChildren;
    for (int i = 0; i < aboveRows.length; i++) {
      EdgeInsets padding = EdgeInsets.zero;
      if (i % 2 == 0 && aboveRows[i].length % 2 == 1) {
        padding = const EdgeInsets.only(right: CircleButton.defaultSize);
      } else if (i % 2 == 1 && aboveRows[i].length % 2 == 0) {
        padding = const EdgeInsets.only(left: CircleButton.defaultSize);
      }

      rowStack.insert(0, Container(
          padding: padding,
          child: Row(
            children: aboveRows[i],
          )
      ));
    }

    List<List<Widget>> belowRows = belowChildren.reversed.toList();
    for (int i = 0; i < belowRows.length; i++) {
      EdgeInsets padding = EdgeInsets.zero;
      if (i % 2 == 0 && belowRows[i].length % 2 == 1) {
        padding = const EdgeInsets.only(right: CircleButton.defaultSize);
      } else if (i % 2 == 1 && belowRows[i].length % 2 == 0) {
        padding = const EdgeInsets.only(left: CircleButton.defaultSize);
      }

      rowStack.add(Container(
          padding: padding,
          child: Row(
            children: belowRows[i],
          )
      ));
    }

    return rowStack;
  }
}

import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/custom_widgets/hex_child_widget.dart';

class VerticalOriginList<T extends HexChildWidget> {
  double _hexChildWidgetSize = 0;
  List<List<T>> _stack = [[], [], []];
  int originIndex = 1;

  VerticalOriginList(T hexChildWidget) {
    _stack[1].add(hexChildWidget);
    _hexChildWidgetSize = hexChildWidget.size;
  }

  List<List<T>> get stack {
    return _stack;
  }

  List<List<T>> get aboveChildren {
    return _stack.sublist(originIndex + 1);
  }

  List<T> get originRow {
    return _stack[originIndex];
  }

  List<List<T>> get belowChildren {
    return _stack.sublist(0, originIndex);
  }

  void addRowToAboveChildren(List<T> row) {
    _stack.add(row);
  }

  void addRowToBelowChildren(List<T> row) {
    originIndex++;
    _stack.insert(0, row);
  }

  List<Container> get buildRowStack {
    List<Container> rowStack = [];

    rowStack.add(Container(
        padding: originRow.length % 2 == 0
            ? EdgeInsets.only(left: _hexChildWidgetSize)
            : EdgeInsets.zero,
        child: Row(
          children: originRow,
      )
    ));

    List<List<T>> aboveRows = aboveChildren;
    for (int i = 0; i < aboveRows.length; i++) {
      EdgeInsets padding = EdgeInsets.zero;
      if (i % 2 == 0 && aboveRows[i].length % 2 == 1) {
        padding = EdgeInsets.only(right: _hexChildWidgetSize);
      } else if (i % 2 == 1 && aboveRows[i].length % 2 == 0) {
        padding = EdgeInsets.only(left: _hexChildWidgetSize);
      }

      rowStack.insert(0, Container(
          padding: padding,
          child: Row(
            children: aboveRows[i],
          )
      ));
    }

    List<List<T>> belowRows = belowChildren.reversed.toList();
    for (int i = 0; i < belowRows.length; i++) {
      EdgeInsets padding = EdgeInsets.zero;
      if (i % 2 == 0 && belowRows[i].length % 2 == 1) {
        padding = EdgeInsets.only(right: _hexChildWidgetSize);
      } else if (i % 2 == 1 && belowRows[i].length % 2 == 0) {
        padding = EdgeInsets.only(left: _hexChildWidgetSize);
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

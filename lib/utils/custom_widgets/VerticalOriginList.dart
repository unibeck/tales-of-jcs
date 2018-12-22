import 'package:flutter/material.dart';
import 'package:tales_of_jcs/utils/IndexOutOfBoundsException.dart';
import 'package:tales_of_jcs/utils/custom_widgets/CircleButton.dart';

class VerticalOriginList {
  List<List<Widget>> aboveChildren = [[]];
  List<Widget> originRow = [];
  List<List<Widget>> belowChildren = [[]];

  VerticalOriginList();

  //One List of all children and origin lists stacked from bottom (zeroth index)
  // to top (length of all children index)
  List<List<Widget>> get stack {
    List stack = []..addAll(belowChildren.reversed);
    stack.add(originRow);
    return stack..addAll(aboveChildren);
  }

  List<Container> get buildStack {
    List<Container> stack = [];

    stack.add(Container(
        padding: EdgeInsets.zero,
        child: Row(
          children: originRow,
      )
    ));

    for (int i = 0; i < aboveChildren.length; i++) {
      stack.insert(0, Container(
          padding: EdgeInsets.zero,
          child: Row(
            children: aboveChildren[i],
          )
      ));
    }

    for (int i = 0; i < belowChildren.length; i++) {
      stack.insert(stack.length, Container(
          padding: EdgeInsets.zero,
          child: Row(
            children: belowChildren[i],
          )
      ));
    }

    return stack;
  }

  //Count of all rows
  int get height {
    return 1 + aboveChildren.length + belowChildren.length;
  }

  //Count of all rows
  int get originIndexOnStack {
    return belowChildren.length;
  }

  void addToStack(int rowIndex, Widget widget) {
    int height = this.height;

    //TODO: Probably have to subtract two from height for zero based index
    if (rowIndex > height) {
      throw IndexOutOfBoundsException("Index [$rowIndex] is greater than the total stack height of [$height]");
    }

    if (rowIndex < this.originIndexOnStack) {
      if (aboveChildren[rowIndex].length % 2 == 0) {
        aboveChildren[rowIndex].insert(0, widget);
      } else {
        aboveChildren[rowIndex].add(widget);
      }
    } else if (rowIndex == this.originIndexOnStack) {
      if (originRow.length % 2 == 0) {
        originRow.add(widget);
      } else {
        originRow.insert(0, widget);
      }
    } else { //index < this.originIndexOnStack
      if (belowChildren[rowIndex - this.originIndexOnStack - 1].length % 2 == 0) {
        belowChildren[rowIndex - this.originIndexOnStack - 1].insert(0, widget);
      } else {
        belowChildren[rowIndex - this.originIndexOnStack - 1].add(widget);
      }
    }
  }
}

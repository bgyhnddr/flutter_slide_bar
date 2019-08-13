library slide_bar;

import 'dart:async';

import 'package:flutter/material.dart';

import 'size_change_notifier.dart';

class ActionItems extends Object {
  ActionItems(
      {@required this.icon,
      @required this.onPress,
      this.backgroudColor: Colors.grey}) {
    assert(icon != null);
    assert(onPress != null);
  }

  final Widget icon;
  final Function onPress;
  final Color backgroudColor;
}

/// A SlideBar.
class SlideBar extends StatefulWidget {
  SlideBar(
      {Key key,
      @required this.items,
      @required this.child,
      this.backgroundColor: Colors.white})
      : super(key: key) {
    assert(items.length <= 6);
  }

  final List<ActionItems> items;
  final Widget child;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _SlideBarState();
}

class _SlideBarState extends State<SlideBar> {
  ScrollController controller = ScrollController();
  bool isOpen = false;

  Size childSize;

  @override
  void initState() {
    super.initState();
  }

  bool _handleScrollNotification(dynamic notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= (widget.items.length * 70.0 / 2) &&
          notification.metrics.pixels < widget.items.length * 70) {
        scheduleMicrotask(() {
          controller.animateTo(widget.items.length * 60.0,
              duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        });
      } else if (notification.metrics.pixels > 0.0 &&
          notification.metrics.pixels < (widget.items.length * 70 / 2)) {
        scheduleMicrotask(() {
          controller.animateTo(0.0,
              duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        });
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (childSize == null) {
      return NotificationListener(
        child: LayoutSizeChangeNotifier(
          child: widget.child,
        ),
        onNotification: (LayoutSizeChangeNotification notification) {
          childSize = notification.newSize;
          scheduleMicrotask(() {
            setState(() {});
          });
          return true;
        },
      );
    }

    List<Widget> above = <Widget>[
      new Container(
        width: childSize.width,
        height: childSize.height,
        color: widget.backgroundColor,
        child: widget.child,
      ),
    ];
    List<Widget> under = <Widget>[];

    for (ActionItems item in widget.items) {
      under.add(new Container(
        alignment: Alignment.center,
        color: item.backgroudColor,
        width: 60.0,
        height: childSize.height,
        child: item.icon,
      ));

      above.add(new InkWell(
          child: new Container(
            alignment: Alignment.center,
            width: 60.0,
            height: childSize.height,
          ),
          onTap: () {
            var result = item.onPress();
            if (result is Future) {
              result.then((val) {
                controller.jumpTo(2.0);
              });
            } else {
              controller.jumpTo(2.0);
            }
          }));
    }

    Widget items = new Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: under,
      ),
    );

    Widget scrollview = new NotificationListener(
      child: new ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above,
      ),
      onNotification: _handleScrollNotification,
    );

    return new Stack(
      children: <Widget>[
        items,
        new Positioned(
          child: scrollview,
          left: 0.0,
          bottom: 0.0,
          right: 0.0,
          top: 0.0,
        )
      ],
    );
  }
}

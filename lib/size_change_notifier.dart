import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void SizeChangedCallBack(Size newSize);

class LayoutSizeChangeNotification extends LayoutChangedNotification{
    LayoutSizeChangeNotification(this.newSize):super();
    Size newSize;
}

class LayoutSizeChangeNotifier extends SingleChildRenderObjectWidget {
    /// Creates a [SizeChangedLayoutNotifier] that dispatches layout changed
    /// notifications when [child] changes layout size.
    const LayoutSizeChangeNotifier({
        Key key,
        Widget child
    }) : super(key: key, child: child);

    @override
    _SizeChangeRenderWithCallback createRenderObject(BuildContext context) {
        return new _SizeChangeRenderWithCallback(
            onLayoutChangedCallback: (size) {
                new LayoutSizeChangeNotification(size).dispatch(context);
            }
        );
    }
}

class _SizeChangeRenderWithCallback extends RenderProxyBox {
    _SizeChangeRenderWithCallback({
        RenderBox child,
        @required this.onLayoutChangedCallback
    }) : assert(onLayoutChangedCallback != null),
            super(child);

    // There's a 1:1 relationship between the _RenderSizeChangedWithCallback and
    // the `context` that is captured by the closure created by createRenderObject
    // above to assign to onLayoutChangedCallback, and thus we know that the
    // onLayoutChangedCallback will never change nor need to change.

    final SizeChangedCallBack onLayoutChangedCallback;

    Size _oldSize;

    @override
    void performLayout() {
        super.performLayout();
        // Don't send the initial notification, or this will be SizeObserver all
        // over again!
        if (size != _oldSize)
            onLayoutChangedCallback(size);
        _oldSize = size;
    }
}
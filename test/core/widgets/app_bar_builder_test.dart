import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';

void main() {
  testWidgets('insets toolbar controls and preserves full-size touch targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBarBuilder(
              title: 'صفحه آزمایشی',
              leading: IconButton(
                onPressed: _noop,
                icon: Icon(Icons.account_circle_outlined),
              ),
              actions: [
                IconButton(
                  onPressed: _noop,
                  icon: Icon(Icons.notifications_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.leadingWidth, 64);
    expect(appBar.actionsPadding, const EdgeInsetsDirectional.only(end: 8));

    final leadingButton = find.ancestor(
      of: find.byIcon(Icons.account_circle_outlined),
      matching: find.byType(IconButton),
    );
    final actionButton = find.ancestor(
      of: find.byIcon(Icons.notifications_outlined),
      matching: find.byType(IconButton),
    );
    final leadingRect = tester.getRect(leadingButton);
    final actionRect = tester.getRect(actionButton);

    expect(leadingRect.width, greaterThanOrEqualTo(48));
    expect(leadingRect.height, greaterThanOrEqualTo(48));
    expect(actionRect.width, greaterThanOrEqualTo(48));
    expect(actionRect.height, greaterThanOrEqualTo(48));
    expect(400 - leadingRect.right, greaterThanOrEqualTo(8));
    expect(actionRect.left, greaterThanOrEqualTo(8));
  });
}

void _noop() {}

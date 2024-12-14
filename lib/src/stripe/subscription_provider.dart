import 'package:flutter/material.dart';

class SubscriptionProvider extends InheritedWidget {
  final Stream<String> subscriptionStatus;
  final String currentStatus;

  const SubscriptionProvider({
    Key? key,
    required this.subscriptionStatus,
    required this.currentStatus,
    required Widget child,
  }) : super(key: key, child: child);

  static SubscriptionProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SubscriptionProvider>();
  }

  @override
  bool updateShouldNotify(SubscriptionProvider oldWidget) {
    return oldWidget.currentStatus != currentStatus;
  }
}

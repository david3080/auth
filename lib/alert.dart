import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'myexception.dart';

class Keys {
  static const String alertDefault = 'alertDefault';
  static const String alertCancel = 'alertCancel';
}

class MyAlertDialog extends StatelessWidget {
  MyAlertDialog({
    @required this.title,
    @required this.content,
    this.cancelActionText,
    @required this.defaultActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMaterialWidget(context);
  }

  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        MyAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      MyAlertDialogAction(
        child: Text(
          defaultActionText,
          key: Key(Keys.alertDefault),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
    return actions;
  }
}

class MyAlertDialogAction extends StatelessWidget {
  MyAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final ui.VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return buildMaterialWidget(context);
  }
  
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}

class MyExceptionAlertDialog extends MyAlertDialog {
  MyExceptionAlertDialog(
      {@required String title, @required MyException exception})
      : super(
          title: title,
          content: exception.message,
          defaultActionText: 'OK',
        );
}
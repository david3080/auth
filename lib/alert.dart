import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class Keys {
  static const String alertDefault = 'alertDefault';
  static const String alertCancel = 'alertCancel';
}

abstract class PlatformWidget extends StatelessWidget {
  Widget buildMaterialWidget(BuildContext context);
  @override
  Widget build(BuildContext context) {
    return buildMaterialWidget(context);
  }
}

class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
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
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
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

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final ui.VoidCallback onPressed;

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog(
      {@required String title, @required PlatformException exception})
      : super(
          title: title,
          content: message(exception),
          defaultActionText: 'OK',
        );

  static String message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      if (exception.code == 'Code 7') {
        return 'This operation could not be completed due to a server error';
      }
      return exception.details;
    }
    return errors[exception.code] ?? exception.message;
  }

  static Map<String, String> errors = {
    'ERROR_WEAK_PASSWORD': 'パスワードは8文字以上である必要があります。再入力してください。',
    'ERROR_INVALID_CREDENTIAL': 'ログインする権限がありません。',
    'ERROR_EMAIL_ALREADY_IN_USE': 'このメールアドレスはすでに登録されています。',
    'ERROR_INVALID_EMAIL': 'メールアドレスのフォーマットに誤りがあります。再入力してください。',
    'ERROR_WRONG_PASSWORD': 'パスワードが異なります。',
    'ERROR_USER_NOT_FOUND': 'メールアドレスが登録されていません。',
    'ERROR_TOO_MANY_REQUESTS': 'このデバイスからのアクセスはブロックされています。時間をおいてから試してください。',
    'ERROR_OPERATION_NOT_ALLOWED': 'ログインする権限がありません。',
  };
}
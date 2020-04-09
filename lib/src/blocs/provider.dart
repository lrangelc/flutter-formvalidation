import 'package:flutter/material.dart';

import 'package:formavalidation/src/blocs/login_bloc.dart';
export 'package:formavalidation/src/blocs/login_bloc.dart';

class Provider extends InheritedWidget {
  Provider({Key key, Widget child}) : super(key: key, child: child);

  final loginBloc = LoginBloc();

  static LoginBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

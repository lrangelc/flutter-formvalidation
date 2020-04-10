import 'package:flutter/material.dart';

import 'package:formavalidation/src/blocs/login_bloc.dart';
export 'package:formavalidation/src/blocs/login_bloc.dart';

class Provider extends InheritedWidget {
  // Provider({Key key, Widget child}) : super(key: key, child: child);

  static Provider _instancia;

  factory Provider({Key key, Widget child}) {
    if (_instancia == null) {
      _instancia = new Provider._internal(key: key, child: child);
    }

    return _instancia;
  }

  Provider._internal({Key key, Widget child}) : super(key: key, child: child);

  final loginBloc = LoginBloc();

  static LoginBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

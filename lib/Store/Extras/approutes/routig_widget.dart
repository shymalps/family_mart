import 'package:flutter/material.dart';
import 'package:get/get.dart';

//?====================> App routes Constants
const _defaultTransition = Transition.fadeIn;
const _defaultDuration = Duration(milliseconds: 500);

//?====================> Dynamic Routing Widget
GetPage getPage(
  String name,
  Widget page,
  List<Bindings> bindings, [
  Transition transition = _defaultTransition,
  Duration transitionDuration = _defaultDuration,
]) {
  return GetPage(
    name: name,
    page: () => page,
    bindings: bindings,
    transition: transition,
    transitionDuration: transitionDuration,
  );
}

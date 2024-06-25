import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void clearAndNavigate(BuildContext context, String path) {
  while (context.canPop() == true) {
    context.pop();
  }
  context.pushReplacement(path);
}
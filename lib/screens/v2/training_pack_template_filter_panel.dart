import 'dart:core' as core;

import 'dart:core';
import 'package:flutter/material.dart' as m;

extension ColorExt on m.Color {
  m.Color withValues({
    core.int? red,
    core.int? green,
    core.int? blue,
    core.int? alpha,
  }) => this;
}

// ignore: unused_element
mixin _TplListFilterPanelMixin on m.State<m.StatefulWidget> {}

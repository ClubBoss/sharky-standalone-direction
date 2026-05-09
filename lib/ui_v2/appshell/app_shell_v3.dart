import 'package:flutter/material.dart';

import '../app_root.dart';

class AppShellV3 extends StatelessWidget {
  const AppShellV3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFFF0F0F0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: true,
                  child: TextButton(
                    onPressed: appRoot.toggleV4Preview,
                    child: const Text('V4'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          Container(
            width: double.infinity,
            height: 0,
            color: const Color(0x00000000),
          ),
        ],
      ),
    );
  }
}

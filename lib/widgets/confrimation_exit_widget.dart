import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmationExitWidget extends StatelessWidget {
  const ConfirmationExitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Yakin ingin keluar?"),
      content:
          const Text("Semua data dan progress yang dilakukan akan hilang!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Tidak"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("Ya"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog(
      {super.key,
      required this.applicationName,
      required this.applicationVersion,
      required this.applicationIcon,
      required this.applicationLegalese,
      required this.applicationDeveloper,
      this.children,
      required this.applicationSnapName});

  final String applicationName;
  final String applicationVersion;
  final Widget applicationIcon;
  final String applicationLegalese;
  final String applicationDeveloper;
  final List<Widget>? children;
  final String applicationSnapName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              applicationIcon,
              const SizedBox(
                width: 10,
              ),
              Text(applicationName)
            ],
          ),
          Row(
            children: [
              const Text("Snap name:"),
              const SizedBox(
                width: 10,
              ),
              Text(applicationSnapName)
            ],
          ),
          Row(
            children: [
              const Text("Version:"),
              const SizedBox(
                width: 10,
              ),
              Text(applicationVersion)
            ],
          ),
          Row(
            children: [
              const Text("Developed by:"),
              const SizedBox(
                width: 10,
              ),
              Text(applicationDeveloper)
            ],
          ),
          Row(
            children: [
              const Text("License:"),
              const SizedBox(
                width: 10,
              ),
              Text(applicationLegalese)
            ],
          ),
          if (children != null) ...children!,
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

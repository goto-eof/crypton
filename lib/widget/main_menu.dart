import 'package:flutter/material.dart';

enum MainMenuItem { newTask }

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.showNewTaskForm});

  final Function() showNewTaskForm;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MainMenuItem>(
      icon: const Icon(Icons.add),
      position: PopupMenuPosition.under,
      onSelected: (MainMenuItem item) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MainMenuItem>>[
        PopupMenuItem<MainMenuItem>(
          value: MainMenuItem.newTask,
          onTap: showNewTaskForm,
          child: const Row(
            children: [
              Icon(
                Icons.task,
                color: Color.fromARGB(178, 0, 0, 0),
              ),
              SizedBox(
                width: 10,
              ),
              Text('New Task')
            ],
          ),
        ),
      ],
    );
  }
}

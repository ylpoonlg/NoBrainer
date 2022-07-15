import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';
import 'package:nobrainer/src/TodoPage/TodoItem.dart';

class TodoNotifyScreen extends StatefulWidget {
  final TodoItem item;
  const TodoNotifyScreen({Key? key, required this.item}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TodoNotifyScreen();
}

class _TodoNotifyScreen extends State<TodoNotifyScreen> {
  @override
  Widget build(BuildContext context) {
    String title = widget.item.title;
    String desc = widget.item.desc;
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(desc),
              const SizedBox(height: 50),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Return to task
                  //SystemNavigator.pop(animated: true);
                },
                child: const Text("DONE"),
                minWidth: 80,
                height: 80,
                shape: const CircleBorder(),
                color: AppTheme.color["green"],
                textColor: AppTheme.color["white"],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

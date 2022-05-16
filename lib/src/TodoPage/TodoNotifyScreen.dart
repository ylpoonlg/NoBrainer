import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class TodoNotifyScreen extends StatefulWidget {
  Map todoItem;
  TodoNotifyScreen({Key? key, required this.todoItem}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TodoNotifyScreen();
}

class _TodoNotifyScreen extends State<TodoNotifyScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String title = widget.todoItem["title"] ?? "Todo Item";
    String desc = widget.todoItem["desc"] ?? "";
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
                  //SystemNavigator.pop(animated: true);
                },
                child: const Text("DONE"),
                minWidth: 80,
                height: 80,
                shape: CircleBorder(),
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

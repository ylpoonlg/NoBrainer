import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobrainer/res/Theme/AppTheme.dart';

class TodoItemDetails extends StatefulWidget {
  Map data;
  Function onUpdate;

  TodoItemDetails({required this.data, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TodoItemsDetailsState(new Map.from(data));
}

class _TodoItemsDetailsState extends State<TodoItemDetails> {
  final Map data;
  _TodoItemsDetailsState(this.data);

  void _onSelectDeadline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DatePickerDialog(
        initialDate: DateTime.parse(data["deadline"]),
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialCalendarMode: DatePickerMode.day,
      ),
    ).then((date) {
      setState(() {
        // Pick Time
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(DateTime.parse(data["deadline"])),
        ).then((time) {
          setState(() {
            if (time != null) {
              data["deadline"] = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              ).toString();
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.color["appbar-background"],
        title: const Text("Todo Task"),
        actions: [
          MaterialButton(
            onPressed: () {
              widget.onUpdate(data);
              Navigator.of(context).pop();
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["title"]),
              onChanged: (text) {
                data["title"] = text;
              },
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "Enter the title of the task",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: TextEditingController(text: data["desc"]),
              onChanged: (text) {
                data["desc"] = text;
              },
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Describe the task",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                const Text("Deadline"),
                const Spacer(),
                MaterialButton(
                  onPressed: () {
                    _onSelectDeadline(context);
                  },
                  child: Text(dateFormat(DateTime.parse(data["deadline"]))),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String dateFormat(DateTime date) {
  String YYYY = date.year.toString();
  String MM = date.month.toString();
  String DD = date.day.toString();

  String hh = date.hour.toString();
  String mm = date.minute.toString();

  if (MM.length < 2) MM = "0" + MM;
  if (DD.length < 2) DD = "0" + DD;
  if (hh.length < 2) hh = "0" + hh;
  if (mm.length < 2) mm = "0" + mm;
  return "$YYYY-$MM-$DD $hh:$mm";
}

import 'package:flutter/material.dart';
import 'package:nobrainer/src/TodoPage/TodoPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> getToolList() {
    return [
      ToolItem(
        title: "Todo List",
        color: Color.fromARGB(255, 12, 144, 196),
        page: TodoPage(),
      ),
      ToolItem(title: "Shopping List", color: Color.fromARGB(255, 14, 168, 8)),
      ToolItem(title: "Clipboard", color: Color.fromARGB(255, 204, 32, 132)),
      ToolItem(title: "Timer", color: Color.fromARGB(255, 202, 95, 7))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "No Brainer",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: getToolList(),
        ),
      ),
    );
  }
}

class ToolItem extends StatelessWidget {
  var title, color, page;

  ToolItem({title, color, page}) : super() {
    this.title = title;
    this.color = color;
    this.page = page;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
          onTap: () {
            print("Go to $page");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => page));
          },
          child: Text(title)),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}

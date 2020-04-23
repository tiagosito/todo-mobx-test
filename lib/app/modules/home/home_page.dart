import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:todo_open_mind/app/shared/models/todo_model.dart';
import 'package:todo_open_mind/app/shared/services/local_storage_service.dart';

import 'components/item/item_widget.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key key, this.title = "Todo List"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController(Modular.get<LocalStorageService>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Observer(
            builder: (_) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "${controller.itemsTotal}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "/",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Observer(
            builder: (_) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "${controller.itemsTotalCheck}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        leading: Observer(builder: (_) {
          return IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: controller != null && controller.itemsTotal == 0 ? 20 : 30,
              color:
                  controller != null && controller.itemsTotal == 0 ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(1),
            ),
            onPressed: controller != null && controller.itemsTotal == 0
                ? null
                : () {
                    _showConfirmDeletDialog(context);
                  },
          );
        }),
        title: Text(widget.title),
      ),
      body: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: controller.list.length,
            itemBuilder: (_, index) {
              TodoModel model = controller.list[index];
              return ItemWidget(
                model: model,
                controller: controller,
                onPressed: () {
                  _showDialog(model);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showDialog();
        },
      ),
    );
  }

  _showDialog([TodoModel model]) {
    model = model ?? TodoModel();
    String titleCache = model.title;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(model.id != null ? "Edit" : "New"),
          content: TextFormField(
            autofocus: true,
            initialValue: model.title,
            //maxLines: 5,
            onChanged: (v) {
              model.title = v;
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                model.title = titleCache;
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Save"),
              onPressed: () {
                if (model.id != null) {
                  controller.update(model);
                } else {
                  controller.add(model);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeletDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Delete"),
          content: new Text("Are you sure you want to delete all items?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                controller.cleanAll();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

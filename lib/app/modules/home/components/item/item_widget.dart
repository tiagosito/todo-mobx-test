import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:todo_open_mind/app/shared/models/todo_model.dart';

import '../../home_controller.dart';

class ItemWidget extends StatelessWidget {
  final TodoModel model;
  final Function onPressed;
  final HomeController controller;

  const ItemWidget({Key key, this.model, this.onPressed, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return ListTile(
          onTap: onPressed,
          leading: IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onPressed: () {
              _showConfirmDeletDialog(model, context);
            },
          ),
          title: Text(model.title),
          trailing: Checkbox(
            value: model.check,
            onChanged: (bool value) {
              model.check = value;
            },
          ),
        );
      },
    );
  }

  void _showConfirmDeletDialog(TodoModel todoModel, BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Delete"),
          content: new Text("Are you sure you want to delete the item [ ${todoModel.title} ] ?"),
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
                if (todoModel.id > -1) {
                  controller.remove(todoModel.id);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

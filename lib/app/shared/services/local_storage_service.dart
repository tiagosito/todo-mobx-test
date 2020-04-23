import 'dart:async';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:todo_open_mind/app/shared/models/todo_model.dart';

class LocalStorageService extends Disposable {
  Completer<Box> completer = Completer<Box>();

  LocalStorageService() {
    _initDB("open_mind_todo");
  }

  _initDB(String boxName) async {
    try {
      var box = await _openBox(boxName);
      if (box != null) {
        completer.complete(box);
      } else {
        final directory = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(directory.path);
        box = await Hive.openBox(boxName);
        if (!completer.isCompleted) {
          completer.complete(box);
          print('OPENING THE ${box.name} HIVE - BOX');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Box> _openBox(String boxName) async {
    try {
      var box = Hive.box(boxName);
      print('TAKING THE ${box.name} HIVE - BOX ALREADY OPEN');
      return box;
    } catch (e) {
      print('PREPARING HIVE TO OPEN THE $boxName BOX');
      return null;
    }
  }

  Future<List<TodoModel>> getAll() async {
    final box = await completer.future;
    return box.values.map((item) => TodoModel.fromJson(item)).toList();
  }

  Future<TodoModel> add(TodoModel model) async {
    final box = await completer.future;
    model.id = box.values.length;
    await box.put(box.values.length, model.toJson());
    return model;
  }

  update(TodoModel model) async {
    final box = await completer.future;
    await box.put(model.id, model.toJson());
  }

  remove(int id) async {
    final box = await completer.future;
    await box.delete(id);
  }

  clear() async {
    final box = await completer.future;
    await box.clear();
  }

  @override
  void dispose() async {
    final box = await completer.future;
    box.close();
  }
}

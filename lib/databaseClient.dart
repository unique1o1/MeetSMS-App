import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseClient {
  Database db;
  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbpath = join(path.path, "database.db");
    db = await openDatabase(dbpath, version: 1, onCreate: this._create);
  }

  Future _create(Database _db, int version) async {
    await _db.execute("""
    CREATE TABLE user(id integer primary key autoincrement,username TEXT NOT NULL,password TEXT NOT NULL)
    """);
  }

  void insertInfo(String password, String username) async {
    await db.insert(
        "user", <String, String>{'username': username, 'password': password});
  }

  void updateInfo(String password, String username) async {
    await db.update(
        "songs", <String, dynamic>{'username': username, 'password': password},
        where: "id= ?", whereArgs: [1]);
  }

  Future<Map<String, dynamic>> getinfo() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("select * from user limit 1");

    return results[0];
  }
}

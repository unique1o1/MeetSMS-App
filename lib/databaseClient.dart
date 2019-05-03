import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseClient {
  Database db;
  static int quotaStatus = 0;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbpath = join(path.path, "database.db");
    db = await openDatabase(dbpath, version: 2, onCreate: this._create);
  }

  Future _create(Database _db, int version) async {
    await _db.execute("""
    CREATE TABLE user(id integer primary key autoincrement,username TEXT NOT NULL,password TEXT NOT NULL,cookie TEXT NOT NULL)
    """);
    await _db.execute("""
    CREATE TABLE resettime(id integer primary key autoincrement,epoch integer NOT NULL default 1551622693421,quota integer NOT NULL default 0)
    """);
  }

  void updateEpoch() async {
    // Future.delayed(duration);

    await db.update(
        "resettime",
        <String, dynamic>{
          'epoch': DateTime.now().millisecondsSinceEpoch,
          'quota': 0
        },
        where: "id= ?",
        whereArgs: [1]);
  }

  void updateQuota(int quota) async {
    await db.update("resettime", <String, dynamic>{'quota': quota},
        where: "id= ?", whereArgs: [1]);
  }

  Future<int> getQuota() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("select * from resettime limit 1");

    return results[0]['quota'];
  }

  Future<int> getEpoch() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("select * from resettime limit 1");

    return results[0]['epoch'];
  }

  Future<String> getcookie() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("select * from user limit 1");
    return results[0]['cookie'];
  }

  void insertResetTime() async {
    await db.insert("resettime", <String, dynamic>{
      'epoch': DateTime.now().millisecondsSinceEpoch,
      'quota': 0
    });
  }

  void insertInfo(String password, String username, String cookie) async {
    await db.insert("user", <String, String>{
      'username': username,
      'password': password,
      'cookie': cookie
    });
  }

  void updateInfo(String password, String username, String cookie) async {
    await db.update(
        "user",
        <String, dynamic>{
          'username': username,
          'password': password,
          'cookie': cookie
        },
        where: "id= ?",
        whereArgs: [1]);
  }

  Future<Map<String, dynamic>> getinfo() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("select * from user limit 1");

    return results[0];
  }
}

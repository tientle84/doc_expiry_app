import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import '../model/model.dart';

class DbHelper {
  // Tables
  static String tblDocs = "docs";

  // Fields of the 'docs' table
  String docId = "id";
  String docTitle = "title";
  String docExpiration = "expiration";

  String fqYear = "fqYear";
  String fqHalfYear = "fqHalfYear";
  String fqQuarter = "fqQuarter";
  String fqMonth = "fqMonth";

  // singleton
  static final DbHelper _dbHelper = DbHelper._internal();

  // factory constructor
  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get db async {
    if(_db == null) {
      _db = await initializeDb();
    }

    return  _db;
  }

  // initialize the database
  Future<Database> initializeDb() async {
    Directory d = await getApplicationDocumentsDirectory();
    String p = d.path + "/docexpire.db";
    var db = await openDatabase(p, version: 1, onCreate: _createDb);
    return  db;
  }

  // create database table
  void _createDb(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $tblDocs("
          "$docId INTEGER PRIMARY KEY, " +
          "$docTitle TEXT, " +
          "$docExpiration TEXT, " +
          "$fqYear INTEGER, " +
          "$fqHalfYear INTEGER, " +
          "$fqQuarter INTEGER, " +
          "$fqMonth INTEGER)"
    );
  }

  // get the list of docs
  Future<List> getDocs() async {
    Database db = await this.db;
    var r = await db.rawQuery(
      "SELECT * FROM $tblDocs ORDER BY $docExpiration ASC"
    );
    return r;
  }

  // get a Doc based on the id
  Future<List> getDoc(int id) async {
    Database db = await this.db;
    var r = await db.rawQuery(
      "SELECT * FROM $tblDocs WHERE $docId = " + id.toString() + ""
    );

    return r;
  }

  // get a Doc based on a String payLoad
  Future<List> getDocFromStr(String payLoad) async {
    List<String> p = payLoad.split("|");
    if(p.length == 2) {
      Database db = await this.db;
      var r = await db.rawQuery(
        "SELECT * FROM $tblDocs WHERE $docId = " + p[0] +
          "AND $docExpiration = '" + p[1] + "'"
      );
      return r;
    }
    else
      return null;
  }

  // get the number of Docs
  Future<int> getDocsCount() async {
    Database db = await this.db;
    var r = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM $tblDocs")
    );
    return r;
  }

  // get the mac document id available on the database
  Future<int> getMaxId() async {
    Database db = await this.db;
    var r = Sqflite.firstIntValue(
      await db.rawQuery("SELECT MAX(id) FROM $tblDocs")
    );
    return r;
  }

  // insert a new Doc
  Future<int> insertDoc(Doc doc) async {
    var r;
    Database db = await this.db;
    try {
      r = await db.insert(tblDocs, doc.toMap());
    } catch (e) {
      debugPrint("insertDoc: " + e.toString());
    }

    return r;
  }

  // update a Doc
  Future<int> updateDoc(Doc doc) async {
    var db = await this.db;
    var r = await db.update(tblDocs, doc.toMap(),
      where: "$docId = ?", whereArgs: [doc.id]);
    return r;
  }

  // delete a Doc
  Future<int> deleteDoc(int id) async {
    var db = await this.db;
    int r = await db.rawDelete(
      "DELETE FROM $tblDocs WHERE $docId = $id"
    );
    return r;
  }

  // delete all docs
  Future<int> deleteRows(String tbl) async {
    var db = await this.db;
    int r = await db.rawDelete(
      "DELETE FROM $tbl"
    );
    return r;
  }
}
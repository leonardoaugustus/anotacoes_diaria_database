import 'dart:io';

import 'package:anotacoes_diaria_app/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static const String nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    print(_db);

    if (_db != null) {
      return _db;
    } else {
      print("else");
      _db = await inicializarDatabase();

      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        "CREATE TABLE $nomeTabela (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR(255), descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  inicializarDatabase() async {
    final pathDatabase = await getDatabasesPath();
    final localDatabase = join(pathDatabase, "banco_anotacoes.db");

    var db = await openDatabase(
      localDatabase,
      version: 1,
      onCreate: _onCreate,
    );

    print(db);

    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;

    int resultado = await bancoDados.insert(nomeTabela, anotacao.toMap());

    return resultado;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;

    return await bancoDados.update(
      nomeTabela,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id],
    );
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await db;

    return await bancoDados.delete(
      nomeTabela,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  recuperarAnotacoes() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);

    return anotacoes;
  }
}

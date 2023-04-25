import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> _getDataBase() async {
  /*abre o banco de dados. O método join é a melhor forma para garantir que
  o path está correto para todas as plataformas */
  return openDatabase(
    join(await getDatabasesPath(), 'dog_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, nome TEXT, idade INTEGER)',
      );
    },
    //Definir a versão para a execução de onCreate
    version: 1,
  );
}

void main() async {
  //para evitar erros causados pela atualização do Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  //função para inserir registros na tabela dogs

  Future<void> insertDog(Dog dog) async {
    //referencia o banco de dados
    final Database db = await _getDataBase();
    await db.insert('dogs', dog.toMap(),
        //usado caso o mesmo registro for inserido 2 vezes
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //função para obter uma listagem dos registros cadastrados
  Future<List<Dog>> dogs() async {
    //referencia o banco de dados
    final Database db = await _getDataBase();
    //consulta a tabela com todos os registros
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    //converte a lista obtida para uma lista de Dog
    return List.generate(maps.length, (i) {
      return Dog(
          id: maps[i]['id'], nome: maps[i]['nome'], idade: maps[i]['idade']);
    });
  }

  //função para atualizar um registro
  Future<void> updateDog(Dog dog) async {
    //referencia o banco de dados
    final Database db = await _getDataBase();
    await db.update(
      'dogs',
      dog.toMap(),
      //certifica-se de que há um registro com id
      where: 'id = ?',
      //passa o id do dog como um argumento
      whereArgs: [dog.id],
    );
  }

  //função que exclui um registro do bamnco de dados
  Future<void> deleteDog(int id) async {
    //referncia o banco de dados
    final Database db = await _getDataBase();
    await db.delete(
      'dogs',
      //usando where para excluir um registro específico
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /*=======================TESTES=======================*/
  //Criar um dog e inseri-lo na table dogs
  var lua = const Dog(
    id: 0,
    nome: 'Lua',
    idade: 1,
  );
  await insertDog(lua);
  //printa os registros cadastrados
  print(await dogs());

  //atualiza a idade de Lua e salva no BD
  lua = Dog(id: lua.id, nome: lua.nome, idade: lua.idade + 2);
  await updateDog(lua);
  //printa os dados atualizados
  print(await dogs());

  //deleta lua do banco de dados
  await deleteDog(lua.id);
  print(await dogs());
}

class Dog {
  final int id;
  final String nome;
  final int idade;

  const Dog({required this.id, required this.nome, required this.idade});

  /*converter um objeto Dog em Map possibilita manipulá-lo no banco de dados
  por meio de um padrão chave:valor, correspondente ao campos do BD */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
    };
  }

  /*implememtar toString oara ver as informações de cada Dog ao usarmos o
  método print*/
  @override
  String toString() {
    return 'Dog{id: $id, nome: $nome, idade: $idade}';
  }
}

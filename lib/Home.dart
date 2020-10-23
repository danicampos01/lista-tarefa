import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefa= [];

  Map<String, dynamic> _ultimaTarefaremovida = Map();

  TextEditingController _controllertarefa= TextEditingController();

  Future<File>_getFile()async{
    final diretorio = await getApplicationDocumentsDirectory();
    var arquivo= File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){
    String textoDigitado= _controllertarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"]= textoDigitado;
    tarefa["realizada"]= false;

    setState(() {
      _listaTarefa.add(tarefa);

    });

    _salvarArquivo();
    _controllertarefa.text="";


  }

  _salvarArquivo() async{

    var arquivo= await _getFile();




    String dados = json.encode(_listaTarefa);

    arquivo.writeAsString(dados);


  }

  _lerArrquivo()async{

    try{
      final arquivo = await _getFile();
     return arquivo.readAsString();
    }catch(e){
     // e.toString();
      return null;
    }

  }


  @override
  void initState() {
    super.initState();
    _lerArrquivo().then((dados){
      setState(() {
        _listaTarefa=json.decode(dados);
      });
    });

  }


  Widget criarItemLista( context, index){
   // final item=_listaTarefa[index]["titulo"];

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){

    _ultimaTarefaremovida= _listaTarefa[index];

        _listaTarefa.removeAt(index);
        _salvarArquivo();

        final snackbar = SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          content: Text("Tarefa removida"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: (){

              setState(() {
                _listaTarefa.insert(index, _ultimaTarefaremovida);
              });

                _salvarArquivo();
            },
          ),
        );
        
        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefa[index]['titulo']),
        value: _listaTarefa[index]['realizada'],
        onChanged: (valorAlterado){
          setState(() {
            _listaTarefa[index]['realizada']= valorAlterado;
          });

          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

//_salvarArquivo();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){

          showDialog(context: context,
          builder: (context){
    return AlertDialog(
      title: Text("Adicionar tarefa"),
      content: TextField(
        controller: _controllertarefa,
        decoration: InputDecoration(
          labelText: "Digite sua tarefa"
        ),
        onChanged: (text){

        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancelar"),
          onPressed: ()=> Navigator.pop(context),
        ),

        FlatButton(
          child: Text("Salvar"),
          onPressed: (){
            _salvarTarefa();
            Navigator.pop(context);
          },
        ),
      ],
    );
          }
          );
        },
      ),
      body: Column(
        children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: _listaTarefa.length,
              itemBuilder: criarItemLista
          ),
        )
        ],
      ),
    );
  }
}

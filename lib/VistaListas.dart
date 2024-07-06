import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ElementosLista.dart';

class VistaListas extends StatefulWidget {
  final List<String> titulosListas;

  VistaListas({required this.titulosListas});

  @override
  VistaListasState createState() => VistaListasState();
}

class VistaListasState extends State<VistaListas> {
  late List<String> elemento;

  @override
  void initState() {
    super.initState();
    elemento = List.from(widget.titulosListas);
  }

  Future<void> guardarLiGuardadas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('listasGuardadas', elemento);
  }

  void irAEditarTituloLista(int index) async {
    final editarElemento = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VistaEditarTitulo(valorInicial: elemento[index]),
      ),
    );

    if (editarElemento != null) {
      setState(() {
        elemento[index] = editarElemento;
        guardarLiGuardadas();
      });
    }
  }

  Future<void> mostrarAlertaEliminar(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Lista'),
          content: Text('¿Estás seguro segurito de eliminar esta lista?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                setState(() {
                  elemento.removeAt(index);
                  guardarLiGuardadas();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void IrAElementosDeListas(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElementosLista(tituloLista: elemento[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas Guardadas'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Color.fromARGB(255, 196, 211, 222),
        child: ReorderableListView(
        children: <Widget>[
          for (int index = 0; index < elemento.length; index += 1)
            Dismissible(
              key: Key('$index'),
              background: Container(color: Colors.blue),
              secondaryBackground: Container(
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await mostrarAlertaEliminar(index);
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  irAEditarTituloLista(index);
                  return false;
                }
                return false;
              },
              child: Card(
                child: ListTile(
                  key: Key('$index'),
                  title: Text(elemento[index]),
                  leading: CircleAvatar(
                    child: Text(elemento[index].substring(0, 1)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      irAEditarTituloLista(index);
                    },
                  ),
                  onTap: () => IrAElementosDeListas(index),
                ),
              ),
            ),
        ],
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = elemento.removeAt(oldIndex);
            elemento.insert(newIndex, item);
          });
          guardarLiGuardadas();
        },
      ),
      ),
    );
  }
}

class VistaEditarTitulo extends StatefulWidget {
  final String valorInicial;

  VistaEditarTitulo({required this.valorInicial});

  @override
  VistaEditarTituloState createState() => VistaEditarTituloState();
}

class VistaEditarTituloState extends State<VistaEditarTitulo> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.valorInicial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void guardarEditar() {
    if(controller.text.isNotEmpty){
    final nuevoTitulo = controller.text;
    Navigator.pop(context, nuevoTitulo);
    }else{
      final snackBar = SnackBar(
        content: Text('El titulo de la lista es obligatorio'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Color.fromARGB(255, 196, 211, 222),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: controller,
                keyboardType: TextInputType.text, //abre el teclado en texto
                textAlign: TextAlign.center, // centra el texto
                maxLength: 30, // maximo 30 caracteres
                autofocus: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.edit),// pone un icono antes de la caja de texto
                  helperText: "Modifica el titulo de Lista", // Pone texto abajo de la caja
                  border: OutlineInputBorder(), // pone borde al texto
                  hintText: "Titulo de la Lista Modificada", //Pone texto dentro de la caja de texto
                  labelText: 'Modificar',
                  fillColor: Colors.blue, filled: true, //Pone color a la caja de texto
                  
                ),
                style: TextStyle(
                  color: Colors.black, // Pone el texto color negro
                  fontWeight: FontWeight.bold,  // Pone el texto en negritas                     
                  ),
                ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: guardarEditar,
              child: Text('Actualizar'),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

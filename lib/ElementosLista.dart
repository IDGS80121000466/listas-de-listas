import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElementosLista extends StatefulWidget {
  final String tituloLista;

  ElementosLista({required this.tituloLista});

  @override
  ElementosListaState createState() => ElementosListaState();
}

class ElementosListaState extends State<ElementosLista> {
  final TextEditingController controller = TextEditingController();
  List<String> elementos = [];

  @override
  void initState() {
    super.initState();
    mostrarElementos();
  }

  Future<void> mostrarElementos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? elementosGuardados = prefs.getStringList(widget.tituloLista);
    if (elementosGuardados != null) {
      setState(() {
        elementos = elementosGuardados;
      });
    }
  }

  Future<void> agregarElemento() async {
    if (controller.text.isNotEmpty) {
      setState(() {
        elementos.add(controller.text);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(widget.tituloLista, elementos);

      controller.clear();
    } else {
      final snackBar = SnackBar(
        content: Text('Ingresa un nombre para el nuevo elemento'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> eliminarElemento(int index) async {
    setState(() {
      elementos.removeAt(index);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.tituloLista, elementos);
  }

  void irAeditarElemento(int index) async {
    final elementoAEditar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VistaEditarElemento(valorInicial: elementos[index]),
      ),
    );

    if (elementoAEditar != null) {
      setState(() {
        elementos[index] = elementoAEditar;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(widget.tituloLista, elementos);
    }
  }

  Future<void> confirmarEliminar(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro segurito de eliminar este elemento?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                eliminarElemento(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> moverElementos(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = elementos.removeAt(oldIndex);
      elementos.insert(newIndex, item);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.tituloLista, elementos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tituloLista),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 196, 211, 222),
              child: ReorderableListView(
                children: <Widget>[
                  for (int index = 0; index < elementos.length; index += 1)
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
                          await confirmarEliminar(index);
                          return false;
                        } else if (direction == DismissDirection.startToEnd) {
                          irAeditarElemento(index);
                          return false;
                        }
                        return false;
                      },
                      child: Card(
                        child: ListTile(
                          key: Key('$index'),
                          title: Text(elementos[index]),
                          leading: CircleAvatar(
                            child: Text(elementos[index].substring(0, 1)),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              irAeditarElemento(index);
                            },
                          ),
                        ),
                      ),
                    ),
                ],
                onReorder: moverElementos,
              ),
            ),
          ),
          Container(
            color: Color.fromARGB(255, 196, 211, 222),
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                controller: controller,
                keyboardType: TextInputType.text, //habre el teclado en texto
                textAlign: TextAlign.center, // centra el texto
                maxLength: 30, // maximo 30 caracteres
                autofocus: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.task),// pone un icono antes de la caja de texto
                  helperText: "Nuevo Elemento", // Pone texto abajo de la caja
                  border: OutlineInputBorder(), // pone borde al texto
                  hintText: "Nuevo Elemento", //Pone texto dentro de la caja de texto
                  labelText: 'Elemento',
                  fillColor: Colors.blue, filled: true, //Pone color a la caja de texto
                  
                ),
                style: TextStyle(
                  color: Colors.black, // Pone el texto color negro
                  fontWeight: FontWeight.bold,  // Pone el texto en negritas                     
                  ),
                ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: agregarElemento,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VistaEditarElemento extends StatefulWidget {
  final String valorInicial;

  VistaEditarElemento({required this.valorInicial});

  @override
  VistaEditarElementoState createState() => VistaEditarElementoState();
}

class VistaEditarElementoState extends State<VistaEditarElemento> {
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

  void guardarElementoModificado() {
    if(controller.text.isNotEmpty){
    final nuevoElemento = controller.text;
    Navigator.pop(context, nuevoElemento);
    }else{
      final snackBar = SnackBar(
        content: Text('El Elemento de la lista es obligatorio'),
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
                keyboardType: TextInputType.text, //habre el teclado en texto
                textAlign: TextAlign.center, // centra el texto
                maxLength: 30, // maximo 30 caracteres
                autofocus: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.edit),// pone un icono antes de la caja de texto
                  helperText: "Modifica Elemeto", // Pone texto abajo de la caja
                  border: OutlineInputBorder(), // pone borde al texto
                  hintText: "Nombre del Elemento", //Pone texto dentro de la caja de texto
                  labelText: 'Modificar Elemento',
                  fillColor: Colors.blue, filled: true, //Pone color a la caja de texto
                  
                ),
                style: TextStyle(
                  color: Colors.black, // Pone el texto color negro
                  fontWeight: FontWeight.bold,  // Pone el texto en negritas                     
                  ),
                ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: guardarElementoModificado,
              child: Text('Actualizar'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

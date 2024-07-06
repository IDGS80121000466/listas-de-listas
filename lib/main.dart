import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VistaListas.dart';
import 'ElementosLista.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Listas de Listas'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller = TextEditingController();
  final List<String> tituloLista = <String>[];
  
  @override
  void initState(){
    super.initState();
    verificarListaGurdada();
  }

  Future<void> verificarListaGurdada() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? listasGuardadas = prefs.getStringList('listasGuardadas');
    if (listasGuardadas != null) {
      setState(() {
        tituloLista.addAll(listasGuardadas);
      });
    }
  }

  void agregarNuevaLista() async {
    if (controller.text.isNotEmpty) {
      setState(() {
        tituloLista.add(controller.text);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('listasGuardadas', tituloLista);

      controller.clear();
    } else {
      final snackBar = SnackBar(
        content: Text('Ingresa un nombre para la nueva lista'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void irAListasGuardadas() async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => VistaListas(titulosListas: tituloLista)),);
}
void irAElementosDeListas(String tituloLista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElementosLista(tituloLista: tituloLista),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: tituloLista.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(        
              child: ListTile(
                title: Text(tituloLista[index]),
                onTap: () {
                  Navigator.pop(context);
                  irAElementosDeListas(tituloLista[index]);
                },
              ),
            );
          }
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 196, 211, 222),
        padding: EdgeInsets.all(8.0),
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
                  icon: Icon(Icons.add_task_outlined),// pone un icono antes de la caja de texto
                  helperText: "Escribe un titulo de Lista", // Pone texto abajo de la caja
                  border: OutlineInputBorder(), // pone borde al texto
                  hintText: "Escribe aqui el nombre de la Lista", //Pone texto dentro de la caja de texto
                  labelText: 'Titulo Lista',
                  fillColor: Colors.blue, filled: true, //Pone color a la caja de texto
                  
                ),
                style: TextStyle(
                  color: Colors.black, // Pone el texto color negro
                  fontWeight: FontWeight.bold,  // Pone el texto en negritas                     
                  ),
                ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                 
                  SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: agregarNuevaLista,
                    child: Text('Agregar nueva Lista'),
                  ),
                  OutlinedButton(
                    onPressed: irAListasGuardadas,
                    child: Text('Ver listas Guardadas'),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cxlqrakllojugiyrjkvd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4bHFyYWtsbG9qdWdpeXJqa3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE1NjEwNTgsImV4cCI6MjAyNzEzNzA1OH0.vJEQOFkvc5s2k1-5J5iadBRdcxIQ-tf42XOicblY3Og',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: myhomepage());
  }
}

class myhomepage extends StatefulWidget {
  const myhomepage({super.key});

  @override
  State<myhomepage> createState() => _myhomepageState();
}

class _myhomepageState extends State<myhomepage> {
  final db =
      Supabase.instance.client.from('juegos').stream(primaryKey: ['id_juegos']);
  

  @override
  void initState() {
    super.initState();
    Supabase.instance.client
        .channel('juegos')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'juegos',
            callback: (payload) {
              debugPrint('');  
            })
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9400FF),
          title: Text("PANTALLA DE INICIO"),
        ),
        drawer: Drawer(
          backgroundColor: Color(0xFF27005D),
          child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Color(0xFF9400FF),
        ),
        child: Text('OPCIONES', style: TextStyle(color: Colors.white)),
      ),
      ListTile(
        title: const Text('AGREGAR NUEVO JUEGO', style: TextStyle(color: Colors.white)),
        onTap: ()  {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => pantallainsert(),));
        },
      ),
    ],
  ),
        ),
        body: Container(
          color: Color(0xFF27005D),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: db,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    debugPrint('Cambios recibidos por stream ${snapshot.data}');
                    final datos = snapshot.data as List;
                    return ListView.builder(
                      itemCount: datos.length,
                      itemBuilder: (context, index) {
                        final juegos = datos[index];
                        return Column(
                          children: [
                            //Text(juegos.toString()),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  margin: const EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(juegos['nombre'].toString(), style: TextStyle(color: Colors.white)),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          Text(juegos['desarrolladora'].toString(), style: TextStyle(color: Colors.white)),
                                        ]
                                      )
                                    ]
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                IconButton(onPressed: () async {
                              await Supabase.instance.client.from('juegos').delete().match(juegos);
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => myhomepage(),));
                            }, icon: const Icon(Icons.delete),
                            style: ButtonStyle(
                              iconColor: MaterialStateColor.resolveWith((states) => Color(0xFF9400FF)),                              
                            ),)
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ),
              ],
          ),
        ));
  }
}

class pantallainsert extends StatefulWidget {
  const pantallainsert({super.key});

  @override
  State<pantallainsert> createState() => _pantallainsertState();
}

class _pantallainsertState extends State<pantallainsert> {
  final controllerT = TextEditingController();
  final controllerD = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9400FF),
        title: Text("PANTALLA DE INSERCION", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Color(0xFF27005D),
        child: Column(
          children: [
            const SizedBox(
              height: 150,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black),
                color: Colors.white
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: controllerT,
                decoration: InputDecoration(
                  labelText: "TITULO DEL JUEGO"
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black),
                color: Colors.white
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: controllerD,
                decoration: InputDecoration(
                  labelText: "DESARROLLADORA DEL JUEGO"
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            ElevatedButton(onPressed: () async {
              await Supabase.instance.client.from('juegos').insert([{'nombre': controllerT.text, 'desarrolladora':controllerD.text}]);
              controllerT.clear();
              controllerD.clear();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => myhomepage(),));
            }, style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith((states) => Color(0xFF27005D)),
            ),
            child: Text(
              "INSERTAR NUEVO TITULO",
              style: TextStyle(color: Colors.white),
            )
            )
          ],
        ),
      ),
    );
  }
}

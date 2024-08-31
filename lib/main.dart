import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {

  runApp(const MyApp());
}

Future<List<Map<String, dynamic>>> getTasks() async {
  final url = Uri.parse('http://127.0.0.1/getFullTasks.php');
  final response = await http.post(url); // Use .get if appropriate

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Extract the completeTasks and incompleteTasks arrays
    List<Map<String, dynamic>> completeTasks = List<Map<String, dynamic>>.from(data['completeTasks'] ?? []);
    List<Map<String, dynamic>> incompleteTasks = List<Map<String, dynamic>>.from(data['incompleteTasks'] ?? []);

    // Combine the two lists or handle them separately
    return completeTasks + incompleteTasks; // If you want to handle them together
  } else {
    throw Exception('Failed to load tasks');
  }
}

/*
Future<List?> getTasks1() async {
  final url = Uri.parse('http://localhost/getFullTasks.php');
  final response = await http.post(
      url
  );

  if (response.statusCode == 200) {
    final data = response.body;
    debugPrint(data);
    final List<dynamic> dataList = jsonDecode(data);
    return dataList;
  }
  else {
    return null;
  }
}*/

convert24To12(String time) {
  return (DateFormat("h:mma").format(DateTime.parse(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString().replaceAll("00:00:00", time))));
}
convert24To12Date(String time){
  return(DateFormat("h:mma").format(DateTime.parse(time)));
}


/*Future<void> login(String username, String password) async {
  final url = Uri.parse('http://localhost/login.php');
  final response = await http.post(
    url,
    body: {
      'username': username,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      debugPrint('Login successful');
    } else {
      debugPrint('Login failed: ${data['message']}');
    }
  } else {
    debugPrint('Server error: ${response.statusCode}');
  }
}

 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Check list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text('Current Tasks'),
        centerTitle: false,
        actions: const [
          Text('test'),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found'));
          } else {
            var tasksList = snapshot.data!;

            // Split the tasks into complete and incomplete lists
            var completeTasks = tasksList.where((task) => task.containsKey('completed')).toList();
            var incompleteTasks = tasksList.where((task) => !task.containsKey('completed')).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, top: 12),
                      child: Text(
                        'Incomplete Tasks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < incompleteTasks.length; i++) ...[
                            ListTile(
                              title: Text(incompleteTasks[i]['name'] ?? 'No Title'),
                              subtitle: Text('Finish by: ${convert24To12(incompleteTasks[i]['due'])}'),
                            ),
                            if (i < incompleteTasks.length - 1) const Divider(height: 0,),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, top: 12),
                      child: Text(
                        'Complete Tasks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < completeTasks.length; i++) ...[
                            ListTile(
                              title: Text(completeTasks[i]['name'] ?? 'No Title'),
                              subtitle: Text('Completed: ${convert24To12Date(completeTasks[i]['completed'])}'),
                            ),
                            if (i < completeTasks.length - 1) const Divider(height: 0,),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),

    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}


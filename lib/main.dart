import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

Future<List<Map<String, dynamic>>> getTasks() async {
  final url = Uri.parse('http://100.111.51.59/getFullTasks.php');
  final response = await http.post(url); // Use .get if appropriate

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Extract the completeTasks and incompleteTasks arrays
    List<Map<String, dynamic>> completeTasks =
        List<Map<String, dynamic>>.from(data['completeTasks'] ?? []);
    List<Map<String, dynamic>> incompleteTasks =
        List<Map<String, dynamic>>.from(data['incompleteTasks'] ?? []);

    // Combine the two lists or handle them separately
    return completeTasks +
        incompleteTasks; // If you want to handle them together
  } else {
    throw Exception('Failed to load tasks');
  }
}

Future<List<dynamic>?> getTaskEdit(String taskID) async {
  final url = Uri.parse('http://100.111.51.59/getTaskEdit.php');
  final response = await http.post(url, body: {'taskID': taskID});

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return [
      data['taskDetails'] ?? {}, // Task data at index 0
      data['completionDetails'] ?? {}, // Completion data at index 1
    ];
  } else {
    throw Exception('Failed to load task details');
  }
}

/*
Future<List?> getTasks1(String taskID) async {
  final url = Uri.parse('http://100.111.51.59/getTaskEdit.php');

  // Including the taskID as part of the POST request body
  final response = await http.post(
    url,
    body: {'taskID': taskID},
  );
if (
response.statusCode == 200) {
final data = response.body;
debugPrint(data);
final List<dynamic> dataList = jsonDecode(data);
return dataList;
} else {
return null;
}
}
*/
convert24To12(String time) {
  return (DateFormat("h:mma").format(DateTime.parse(DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString().replaceAll("00:00:00", time))));
}

convert24To12Date(String time) {
  return (DateFormat("h:mma").format(DateTime.parse(time)));
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Current Tasks'),
        centerTitle: false,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditTaskScreen()),
              );
            },
            child: const Text("Test"),
          ),
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
            var completeTasks = tasksList
                .where((task) => task.containsKey('completed'))
                .toList();
            var incompleteTasks = tasksList
                .where((task) => !task.containsKey('completed'))
                .toList();

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
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 4),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < incompleteTasks.length; i++) ...[
                            ListTile(
                              title: Text(
                                  incompleteTasks[i]['name'] ?? 'No Title'),
                              subtitle: Text(
                                  'Finish by: ${convert24To12(incompleteTasks[i]['due'])}'),
                            ),
                            if (i < incompleteTasks.length - 1)
                              const Divider(
                                height: 0,
                              ),
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
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 4),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < completeTasks.length; i++) ...[
                            ListTile(
                              title:
                                  Text(completeTasks[i]['name'] ?? 'No Title'),
                              subtitle: Text(
                                  'Completed: ${convert24To12Date(completeTasks[i]['completed'])}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SecondRoute(
                                        data: completeTasks[i]['id'] ??
                                            'No Title',
                                        taskName: completeTasks[i]['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                            if (i < completeTasks.length - 1)
                              const Divider(
                                height: 0,
                              ),
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
  final String data; // Assuming this is the taskID or related data
  final String taskName;

  const SecondRoute({super.key, required this.data, required this.taskName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit task: $taskName"),
      ),
      body: FutureBuilder<List?>(
        future: getTaskEdit(data),
        // Make sure `data` is passed correctly as the taskID
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the future is loading, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If the future returns an error, show an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If the future completes with no data, show a message
            return const Center(child: Text('No task data found'));
          } else {
            // If the future completes with data, show the task details
            final taskData = snapshot
                .data![0]; // Assuming the task data is in the first index
            final completionData = snapshot.data![
                1]; // Assuming the completion data is in the second index

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Task Name: ${taskData['taskName'] ?? 'No Name'}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Description: ${taskData['taskDescription'] ?? 'No Description'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (completionData != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Completed by: ${completionData['user'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Completion Time: ${completionData['completionTime'] ?? 'Not Completed'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    // Display photos if available

                    for (int i = 0; i < taskData['photoCount']; i++)
                      if (completionData['photo${i + 1}Path'] != "")
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: Card(
                              color: Colors.amber,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(taskData["photo${i + 1}Name"]),
                                  ),
                                  const Divider(
                                    height: 0,
                                  ),
                                  GestureDetector(
                                    onTap: () => showImageViewer(
                                      context,
                                      Image.network('http://100.111.51.59${completionData['photo${i + 1}Path']}').image,
                                      useSafeArea: true,
                                      swipeDismissible: true,
                                      doubleTapZoomable: true,
                                    ),
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8.0),
                                        image: completionData['photo${i + 1}Path'] != null
                                            ? DecorationImage(
                                          image: Image.network(
                                              'http://100.111.51.59${completionData['photo${i + 1}Path']}').image,
                                          fit: BoxFit.cover,
                                        )
                                            : null,
                                      ),
                                      child: completionData['photo${i + 1}Path'] == null
                                          ? const Icon(Icons.camera)
                                          : const Text('Retake Photo'),
                                    ),
                                  ),
                                  InstaImageViewer(
                                    child: Image(
                                      image: Image.network(
                                              'http://100.111.51.59${completionData['photo${i + 1}Path']}')
                                          .image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('This task has not been completed yet.'),
                    ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Image paths for the two fridges
  String? backFridgeImagePath;
  String? milkFridgeImagePath;

  // Function to handle image capture
  Future<void> _captureImage(String fridgeType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        if (fridgeType == 'Back Fridge') {
          backFridgeImagePath = image.path;
        } else {
          milkFridgeImagePath = image.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Back Fridge'),
                const Text('Milk Fridge'),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _captureImage('Back Fridge'),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      image: backFridgeImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(backFridgeImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: backFridgeImagePath == null
                        ? const Icon(Icons.camera)
                        : const Text('Retake Photo'),
                  ),
                ),
                GestureDetector(
                  onTap: () => _captureImage('Milk Fridge'),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      image: milkFridgeImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(milkFridgeImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: milkFridgeImagePath == null
                        ? const Icon(Icons.camera)
                        : const Text('Take Photo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Comment to Manager'),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Type Comment Here',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle submit action
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

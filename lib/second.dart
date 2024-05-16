import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textController = TextEditingController();

  bool loader = false;
  setLoader(bool val) {
    loader = val;
    setState(() {});
  }

  addData() async {
    try {
      setLoader(true);
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseDatabase.instance
          .ref("data")
          .child(id)
          .set({"text": textController.text, "id": id});
      textController.clear();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SecondScreen()));
    } catch (e) {
      print(e);
    } finally {
      setLoader(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Database"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "Enter text",
                border: border,
                disabledBorder: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
          ),
          loader
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
              onPressed: () async {
                await addData();
              },
              child: const Text("Add"))
        ],
      ),
    );
  }
}

InputBorder border = const OutlineInputBorder();

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get data"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("data").onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic> data =
            snapshot.data!.snapshot.value as dynamic;
            List<Model> list = [];
            list = data.values.map((e) => Model.fromJson(e)).toList();
            return ListView.builder(
              itemCount: snapshot.data?.snapshot.children.length,
              itemBuilder: (context, index) {
                return ListTile(
                  trailing: GestureDetector(
                      onTap: () {
                        FirebaseDatabase.instance
                            .ref("data")
                            .child(list[index].id ?? "")
                            .remove();
                      },
                      child: const Icon(Icons.delete)),
                  title: Text(list[index].text ?? ""),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Model {
  String? text;
  String? id;

  Model({this.id, this.text});

  factory Model.fromJson(Map<dynamic, dynamic> json) {
    return Model(
      id: json["id"],
      text: json["text"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "text": text,
    };
  }
}

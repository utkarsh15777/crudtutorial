import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtutorial/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FireStoreService fireStoreService =  FireStoreService();

  TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID}){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(docID == null){
                fireStoreService.addNote(textController.text);
              }else{
                fireStoreService.updateNote(docID, textController.text);
              }
              textController.clear(); 
              Navigator.pop(context);
            },
            child: const Text(
              "Save"
            ),
          )
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.readNotesStream(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List notesList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID =document.id;

                Map<String,dynamic> data = document.data() as Map<String,dynamic>;

                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () async {
                          textController.text = await fireStoreService.getNote(docID);
                          return openNoteBox(docID: docID);
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: ()  {
                          fireStoreService.deleteNote(docID);
                        },
                      ),
                    ],
                  )
                );
              },
            );
          }else{
            print("No Notes");
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index){
                return const ListTile(
                  title: Text("No Notes"),
                );
              },
              
            );
          }
        },
      ),
    );
  }
}
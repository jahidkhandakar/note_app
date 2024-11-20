import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //__________________________Methods and Instances___________________________
  //FiresStoreService instance_____________________
  final FireStoreService firestoreService = FireStoreService();
  //text controller__________________
  final TextEditingController textController = TextEditingController();
  //openNoteBox Method_________________
  void openNoteBox({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
              hintText: 'Enter your note...',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyan, width: 2)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.cyan,width: 2,),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.cyan,width: 2,),
              )
          ),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    )
                  ),
              ),            
              //_________________
              SizedBox(
                width: 5,
              ),
              //_________________
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      if (docId == null)
                        firestoreService.addNote(textController.text);
                      else
                        firestoreService.updateNote(docId, textController.text);

                      //clear the text controller
                      textController.clear();
                      //close the note box
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    )
                  ),
              ),
            ],
          )
        ],
        //decorations_____________
        elevation: 10.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }
  //__________________________________________________________________________

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 156, 255, 247),
      //______________________App Bar________________________________
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Center(
            child: Text(
          "Note App",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        )),
      ),
      //______________________Floating Action Button__________________________
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        shape: CircleBorder(),
        onPressed: () {
          openNoteBox();
        },
        child: Icon(Icons.add),
      ),

      //______________________BODY______________________________
      body: StreamBuilder(
          stream: firestoreService.getNoteStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //if we have data, get all the notes
              List noteList = snapshot.data!.docs;
              //display in a list
              return ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    //get each document
                    DocumentSnapshot document = noteList[index];
                    String docId = document.id;

                    //get note from each document
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tile
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 2, color: Colors.cyan),
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 5, top: 5, right: 5),
                      child: ListTile(
                        title: Text(
                          noteText,
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              //Update
                              onPressed: () {
                                openNoteBox(docId: docId);
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.blueGrey,
                              ),
                            ),
                            IconButton(
                                //Delete
                                onPressed: () {
                                  firestoreService.deleteNote(docId);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.cyan,
                                )),
                          ],
                        ),
                        //decoration______________
                        leading: Icon(
                          Icons.note,
                          color: Colors.cyan[600],
                        ),
                      ),
                    );
                  });
            } else {
              //if we don't have data, show a message
              return Center(
                child: Text("No notes found"),
              );
            }
          }),
    );
  }
}

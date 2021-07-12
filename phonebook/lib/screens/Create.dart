import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonebook/modules/API.dart';
import 'package:phonebook/screens/Manage.dart';
import 'package:phonebook/structures/PBPartialData.dart';
import 'package:phonebook/utils/Toasts.dart';

class Create extends StatefulWidget {
  final String? id;
  const Create({Key? key, String? this.id}) : super(key: key);

  @override
  _CreateState createState() => _CreateState(id);
}

class _CreateState extends State<Create> {
  String? _id;
  int PNumTextFields_id = 0;

  TextEditingController fname_ctrlr = TextEditingController();
  TextEditingController lname_ctrlr = TextEditingController();
  List<PNumTextField> PNumTextFields = [];

  _CreateState(String? this._id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: _id != null ? Text('Create Contact') : Text('New Contact'),
        centerTitle: true,
        actions: [
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              List<String> conditions = [];

              // Check if all fields are valid
              if (fname_ctrlr.text.isEmpty) {
                conditions.add('First Name must not be empty.');
              }
              if (lname_ctrlr.text.isEmpty) {
                conditions.add('Last Name must not be empty.');
              }
              if (PNumTextFields.where((e) => e.controller.text.isEmpty)
                      .length >
                  0) {
                conditions.add('Phone Numbers must not be empty.');
              }

              if (conditions.isNotEmpty) {
                Toasts.showMessage(conditions.join(',\n'));
              } else {
                try {
                  final result = await API.putContact(
                    PBPartialData(
                      first_name: fname_ctrlr.text,
                      last_name: lname_ctrlr.text,
                      phone_numbers:
                          PNumTextFields.map((e) => e.controller.text).toList(),
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Manage(
                        id: result.id,
                      ),
                    ),
                  );
                } catch (error) {
                  Toasts.showMessage(error.toString());
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 50),
            CircleAvatar(
              child: _id != null
                  ? Icon(Icons.person, size: 80)
                  : Icon(Icons.person_add, size: 70),
              radius: 50,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40, 30, 40, 0),
              child: Column(
                children: [
                  TextField(
                    controller: fname_ctrlr,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'First Name',
                      labelText: 'First Name',
                    ),
                  ),
                  TextField(
                    controller: lname_ctrlr,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Last Name',
                      labelText: 'Last Name',
                    ),
                  ),
                  SizedBox(height: 20),
                  ...PNumTextFields,
                  SizedBox(height: 20),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text('Add Phone Number'),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        PNumTextFields.add(PNumTextField(
                          id: PNumTextFields_id++,
                          remove: (id) {
                            setState(() {
                              PNumTextFields.removeWhere((e) => e.id == id);
                            });
                          },
                        ));
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PNumTextField extends StatelessWidget {
  final id, remove, initial;
  final controller = TextEditingController();

  PNumTextField({
    Key? key,
    required int this.id,
    required this.remove,
    this.initial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initial != null) {
      controller.text = initial;
    }
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.call),
        hintText: 'Phone Number',
        labelText: 'Phone Number',
        suffixIcon: IconButton(
          icon: Icon(Icons.remove, color: Colors.red),
          onPressed: () {
            this.remove(id);
          },
        ),
      ),
    );
  }
}
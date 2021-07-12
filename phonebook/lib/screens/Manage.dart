import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonebook/modules/API.dart';
import 'package:phonebook/screens/View.dart';
import 'package:phonebook/structures/PBData.dart';
import 'package:phonebook/utils/Toasts.dart';

class Manage extends StatefulWidget {
  final PBData data;
  const Manage({Key? key, required PBData this.data}) : super(key: key);

  @override
  _ManageState createState() => _ManageState(data);
}

class _ManageState extends State<Manage> {
  bool init = true;
  PBData data;
  int PNumTextFields_id = 0;

  TextEditingController fname_ctrlr = TextEditingController();
  TextEditingController lname_ctrlr = TextEditingController();
  List<PNumTextField> PNumTextFields = [];

  _ManageState(PBData this.data);

  @override
  Widget build(BuildContext context) {
    if (init) {
      fname_ctrlr.text = data.first_name;
      lname_ctrlr.text = data.last_name;
      data.phone_numbers.forEach((phone_number) {
        PNumTextFields.add(PNumTextField(
          id: PNumTextFields_id++,
          initial: phone_number,
          remove: (id) {
            setState(() {
              PNumTextFields.removeWhere((e) => e.id == id);
            });
          },
        ));
      });
      init = false;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Manage Contact'),
        centerTitle: true,
        actions: [
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              List<String> conditions = [];
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
                  await API.patchContact(
                    PBData(
                      data.id,
                      fname_ctrlr.text,
                      lname_ctrlr.text,
                      PNumTextFields.map((e) => e.controller.text).toList(),
                    ),
                  );
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => View(id: data.id)));
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
              child: Icon(Icons.person, size: 80),
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
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextField(
                    controller: lname_ctrlr,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Last Name',
                      labelText: 'Last Name',
                    ),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
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
                  SizedBox(height: 50),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        Text(
                          'Delete Contact',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      try {
                        await API.deleteContact(data.id);
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/'));
                      } catch (error) {
                        Toasts.showMessage(error.toString());
                      }
                    },
                  ),
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
      keyboardType: TextInputType.number,
    );
  }
}

import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  String? _city;
  // the error message will not be displayed until the user submits it
  // we will change it to AutoValidateMode.always in setState when submitting
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  void _submit() {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      Navigator.of(context).pop(_city!.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextFormField(
                // can input it immediately after it’s displayed on the screen
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: "City name",
                  hintText: "more than 2 characters",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                validator: (String? input) {
                  if (input == null || input.trim().length < 2) {
                    return 'City name must be at least 2 characters';
                  }
                  return null;
                },
                onSaved: (String? input) {
                  _city = input;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  "How's weather?",
                  style: TextStyle(fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/form_field_builder.dart';

class ValuesPage extends StatefulWidget {
  final AppState appState;
  const ValuesPage({super.key, required this.appState});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  @override
  Widget build(BuildContext context) {
    final model = widget.appState.values;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('۱۰ ارزش مهم خود را بنویسید')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...List.generate(
                model.list.length,
                (index) => FormBuilder.buildTextField(
                  'ارزش شماره ${index + 1}',
                  model.list[index],
                  (value) => setState(() => model.list[index] = value),
                ),
              ),
              FormBuilder.buildSaveButton(
                () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ مقادیر ذخیره شد')),
                  );
                },
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

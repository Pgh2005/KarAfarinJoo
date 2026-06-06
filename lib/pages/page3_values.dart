import 'package:flutter/material.dart';
import 'package:karafarini/widgets/app_bar_builder.dart';
import 'package:karafarini/widgets/save_button.dart';
import '../app_state.dart';
import '../widgets/form_field_builder.dart';

class ValuesPage extends StatefulWidget {
  final AppState appState;
  const ValuesPage({super.key, required this.appState});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final model = widget.appState.values;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarBuilder(title: '۱۰ ارزش مهم خود را بنویسید'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(
                model.list.length,
                (index) => FormBuilder.buildTextField(
                  'ارزش شماره ${index + 1}',
                  model.list[index],
                  (value) => setState(() => model.list[index] = value),
                ),
              ),
              SizedBox(height: 24),
              SaveButton(
                onSave: () {},
                isEnabled: isEnable,
                isLoading: isLoading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

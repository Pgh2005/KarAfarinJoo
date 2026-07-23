import 'package:flutter/material.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/state/app_state.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';

class ValuesPage extends StatefulWidget {
  const ValuesPage({super.key});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final model = AppState().values;
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

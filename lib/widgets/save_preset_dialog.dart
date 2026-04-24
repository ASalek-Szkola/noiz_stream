import 'package:flutter/material.dart';

class SavePresetDialogResult {
  const SavePresetDialogResult({required this.name, required this.color});

  final String name;
  final Color color;
}

Future<SavePresetDialogResult?> showSavePresetDialog({
  required BuildContext context,
  required Color initialColor,
  required List<Color> colorOptions,
}) async {
  final nameController = TextEditingController();
  var selectedColor = initialColor;

  final result = await showDialog<SavePresetDialogResult>(
    context: context,
    builder: (BuildContext dialogContext) {
      final theme = Theme.of(dialogContext);
      return StatefulBuilder(
        builder: (BuildContext _, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Zapisz preset'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa presetu',
                      hintText: 'Np. Morning Focus',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kolor presetu',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colorOptions
                        .map((color) {
                          final isSelected =
                              color.toARGB32() == selectedColor.toARGB32();
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: theme.colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Podaj nazwę presetu.')),
                    );
                    return;
                  }

                  Navigator.of(dialogContext).pop(
                    SavePresetDialogResult(name: name, color: selectedColor),
                  );
                },
                child: const Text('Zapisz'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  return result;
}

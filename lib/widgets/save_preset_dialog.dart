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
  final result = await showDialog<SavePresetDialogResult>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _SavePresetDialog(
        initialColor: initialColor,
        colorOptions: colorOptions,
      );
    },
  );
  return result;
}

class _SavePresetDialog extends StatefulWidget {
  const _SavePresetDialog({
    required this.initialColor,
    required this.colorOptions,
  });

  final Color initialColor;
  final List<Color> colorOptions;

  @override
  State<_SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<_SavePresetDialog> {
  late final TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj nazwę presetu.')),
      );
      return;
    }

    Navigator.of(context).pop(
      SavePresetDialogResult(name: name, color: _selectedColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Zapisz preset'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nazwa presetu',
                hintText: 'Np. Morning Focus',
              ),
              onSubmitted: (_) => _save(),
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
              children: widget.colorOptions
                  .map((color) {
                    final isSelected =
                        color.toARGB32() == _selectedColor.toARGB32();
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}

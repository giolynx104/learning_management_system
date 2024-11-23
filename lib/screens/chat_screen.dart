import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'dart:io';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final messages = useState<List<Widget>>([]);
    final picker = useMemoized(() => ImagePicker());

    Widget buildMessage(String message) {
      return Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(message),
      );
    }

    Widget buildImageMessage(File imageFile) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            imageFile,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    void sendMessage() {
      if (controller.text.isNotEmpty) {
        messages.value = [...messages.value, buildMessage(controller.text)];
        controller.clear();
      }
    }

    Future<void> pickImage(ImageSource source) async {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        messages.value = [...messages.value, buildImageMessage(File(pickedFile.path))];
      }
    }

    Widget _buildInputArea() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              onPressed: () => pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo, color: Theme.of(context).colorScheme.primary),
              onPressed: () => pickImage(ImageSource.gallery),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150.0,
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter your message',
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
              onPressed: sendMessage,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.value.length,
              itemBuilder: (context, index) => messages.value[index],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
} 
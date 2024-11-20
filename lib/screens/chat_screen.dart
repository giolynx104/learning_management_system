Widget _buildInputArea() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        IconButton(
          icon: Icon(Icons.photo, color: Theme.of(context).colorScheme.primary),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 150.0,
            ),
            child: TextField(
              controller: _controller,
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
          onPressed: _sendMessage,
        ),
      ],
    ),
  );
} 
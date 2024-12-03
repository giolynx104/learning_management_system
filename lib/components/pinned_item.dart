import 'package:flutter/material.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';

class PinnedItem extends StatelessWidget {
  final PinnedChannelModel channel;
  final VoidCallback onUnpinPressed;

  const PinnedItem({super.key, 
    required this.channel,
    required this.onUnpinPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.push_pin, color: Colors.red),
      title: Text(channel.name),
      subtitle: Text(channel.subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onUnpinPressed,  // Call the function when unpin is pressed
      ),
    );
  }
}

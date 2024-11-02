class PinnedChannelModel {
  final String name;
  // Add other necessary fields

  PinnedChannelModel({
    required this.name,
  });

  // Add this static method for temporary data
  static List<PinnedChannelModel> getPinnedChannels() {
    // Return dummy data for now
    return [];
  }
}

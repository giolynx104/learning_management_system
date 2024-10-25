
class PinnedChannelModel {
  final String name;
  final String subtitle;
  bool isPinned;

  PinnedChannelModel({
    required this.name,
    required this.subtitle,
    this.isPinned = true,  // Initially pinned by default
  });

  // Function to remove a channel from pinned
  static void removePinnedChannel(PinnedChannelModel channel) {
    channel.isPinned = false;
  }

  // Sample data
  static List<PinnedChannelModel> getPinnedChannels() {
    return [
      PinnedChannelModel(name: "Chung", subtitle: "20231 - IT3180 Nhập môn CNPM"),
      PinnedChannelModel(name: "K66-Trường CNTT&TT", subtitle: "Khóa học CN"),
    ];
  }
}

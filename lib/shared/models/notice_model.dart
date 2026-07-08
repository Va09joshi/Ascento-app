class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String? bannerUrl;
  final String type;
  final bool isPublished;
  final DateTime? createdAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    this.bannerUrl,
    required this.type,
    required this.isPublished,
    this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      bannerUrl: json['banner_url'] as String?,
      type: json['type'] as String? ?? 'event',
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'banner_url': bannerUrl,
      'type': type,
      'is_published': isPublished,
    };
  }
}

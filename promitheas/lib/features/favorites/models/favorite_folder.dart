class FavoriteFolder {
  const FavoriteFolder({
    required this.folderId,
    required this.userId,
    required this.folderName,
    required this.createdAt,
    this.productCount = 0,
  });

  final int folderId;
  final String userId;
  final String folderName;
  final DateTime createdAt;
  final int productCount;

  factory FavoriteFolder.fromJson(Map<String, dynamic> json) {
    final countRaw = json['favorite_products'];
    int count = 0;
    if (countRaw is List && countRaw.isNotEmpty) {
      count = (countRaw.first['count'] as num?)?.toInt() ?? 0;
    }

    return FavoriteFolder(
      folderId: json['folder_id'] as int,
      userId: json['user_id'] as String,
      folderName: json['folder_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      productCount: count,
    );
  }

  FavoriteFolder copyWith({
    int? folderId,
    String? userId,
    String? folderName,
    DateTime? createdAt,
    int? productCount,
  }) {
    return FavoriteFolder(
      folderId: folderId ?? this.folderId,
      userId: userId ?? this.userId,
      folderName: folderName ?? this.folderName,
      createdAt: createdAt ?? this.createdAt,
      productCount: productCount ?? this.productCount,
    );
  }
}

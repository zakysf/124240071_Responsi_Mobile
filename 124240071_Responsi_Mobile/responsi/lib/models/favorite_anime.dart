import 'package:hive/hive.dart';

class FavoriteAnime extends HiveObject {
  final String id;
  final String name;
  final String? imageUrl;
  final String rating;

  FavoriteAnime({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
  });
}

class FavoriteAnimeAdapter extends TypeAdapter<FavoriteAnime> {
  @override
  final int typeId = 0;

  @override
  FavoriteAnime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteAnime(
      id: fields[0]?.toString() ?? '',
      name: fields[1] as String? ?? '',
      imageUrl: fields[2] as String?,
      rating: fields[3]?.toString() ?? '0.0',
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteAnime obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

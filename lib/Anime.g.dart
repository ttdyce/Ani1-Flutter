// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Anime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ani1Anime _$Ani1AnimeFromJson(Map<String, dynamic> json) {
  return Ani1Anime(
    name: json['name'] as String,
    cat: json['cat'] as String,
    episode: json['episode'] as String,
    year: json['year'] as String,
    season: json['season'] as String,
    fansub: json['fansub'] as String,
  );
}

Map<String, dynamic> _$Ani1AnimeToJson(Ani1Anime instance) => <String, dynamic>{
      'name': instance.name,
      'cat': instance.cat,
      'episode': instance.episode,
      'year': instance.year,
      'season': instance.season,
      'fansub': instance.fansub,
    };

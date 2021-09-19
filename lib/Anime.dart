import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'Anime.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
enum Season { spring, summer, autumn, winter }

@JsonSerializable()
class Ani1Anime {
  final String name;
  final String cat;
  final String episode;
  final String year;
  final String season;
  final String fansub;

  Ani1Anime({this.name,this.cat, this.episode, this.year, this.season, this.fansub});

  factory Ani1Anime.fromJson(Map<String, dynamic> json) {
    return Ani1Anime(
      name: json['name'],
      cat: json['cat'],
      episode: json['episode'],
      year: json['year'],
      season: json['season'],
      fansub: json['fansub'],
    );
  }
}

class Ani1Episode {
  String link, src, name;

  Ani1Episode(this.link, this.src);
  Ani1Episode.link(this.link);
  Ani1Episode.name(this.name);

}

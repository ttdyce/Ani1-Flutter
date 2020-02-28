import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_world/Anime.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Ani1Scraper {
  Future<List<Ani1Anime>> fetchAnimes() async {
    final response = await http.get('https://anime1.me/');

    if (response.statusCode == 200) {
      final animesJson = getAni1HTMLToJSONList(response.body);
      final List<Ani1Anime> animes = List();

      for (var aJson in animesJson) {
        animes.add(Ani1Anime.fromJson(aJson));
      }

      return animes;
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to fetch animes');
    }
  }

  List getAni1HTMLToJSONList(String body) {
    final document = parse(body);
    final names = List(),
        episodes = List(),
        years = List(),
        seasons = List(),
        fansubs = List(),
        catList = List();
    final allList = [names, episodes, years, seasons, fansubs];

    for (int i = 1; i <= 5; i++) {
      final animeList = document.getElementsByClassName('column-$i');
      final title = animeList.removeAt(0);

      debugPrint(i.toString());
      debugPrint(title.innerHtml);
      for (var a in animeList) {
        if (i == 1)
          catList.add(a.getElementsByTagName('a')[0].attributes["href"]);
        allList[i - 1].add(
            i == 1 ? a.getElementsByTagName('a')[0].innerHtml : a.innerHtml);
      }
    }

//    debugPrint(catList.toString());
//    debugPrint(names.toString());
//    debugPrint(episodes.toString());
//    debugPrint(years.toString());
//    debugPrint(seasons.toString());

    final animeJsonList = List();

    for (int i = 0; i < names.length; i++) {
      Map<String, dynamic> map = Map();
      map.putIfAbsent('name', () => names[i]);
      map.putIfAbsent('cat', () => catList[i]);
      map.putIfAbsent('episode', () => episodes[i]);
      map.putIfAbsent('year', () => years[i]);
      map.putIfAbsent('season', () => seasons[i]);
      map.putIfAbsent('fansub', () => fansubs[i]);

      animeJsonList.add(map);
    }

    return animeJsonList;
  }

  Future<List<Ani1Episode>> fetchAnime(String cat) async {
    final response = await http.get('https://anime1.me$cat');

    if (response.statusCode == 200) {
      return getAni1Episodes(response.body);
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to fetch episode');
    }
  }

  List<Ani1Episode> getAni1Episodes(String body) {
    final List<Ani1Episode> episodes = List();
    final document = parse(body);
    
    for (var x in document.getElementsByClassName('loadvideo')){
      String link = x.attributes['data-src'];
      Ani1Episode ae = new Ani1Episode.link(link);

      episodes.add(ae);
    }

    return episodes;
  }

  Future<String> fetchAni1EpisodesSrc(String link) async {
    final response = await http.get(link);
    final document = parse(response.body);

    return document.getElementsByTagName('source')[0].attributes['src'];
  }


}

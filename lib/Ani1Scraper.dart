import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_world/Anime.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Ani1Scraper {
  Future<List<Ani1Anime>> fetchAnimes() async {
    final response = await http.get(Uri.parse('https://anime1.me/'));

    if (response.statusCode == 200) {
      final animesJson = getAni1HTMLToJSONList(response.body);
      final List<Ani1Anime> animes = [];

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
    final names = [],
        episodes = [],
        years = [],
        seasons = [],
        fansubs = [],
        catList = [];
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

    final animeJsonList = [];

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
    final response = await http.get(Uri.parse('https://anime1.me?cat=$cat'), );

    if (response.statusCode == 200) {
      return await fetchAni1Episodes(parse(response.body));
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to fetch episode');
    }
  }

  Future<List<Ani1Episode>> fetchAni1Episodes(Document document) async{
    final List<Ani1Episode> episodes = [];
    final List<String> videoLinks = [];
    final List<String> temps = [];

    for (var a in document.getElementsByTagName('article')) {
      String? videoLink = a.getElementsByTagName('iframe')[0].attributes['src'];
      videoLinks.add(videoLink!);
    }

    for (var link in videoLinks){
      final response = await http.get(Uri.parse(link));

      String episodeLink = parse(response.body).getElementsByTagName('script').last.outerHtml;

      String temp = episodeLink.split('.send(\'')[1].split('\');')[0];
      temp = temp.split('=')[1];
      temp = Uri.decodeFull(temp);

      temps.add(temp);
    }

    for (var t in temps){
      Uri uri = Uri.parse('https://v.anime1.me/api');
      final response = await http.post(uri, body: {'d': t});

      Map<String, dynamic> json = jsonDecode(response.body);

      Ani1Episode ae = new Ani1Episode.link('https://' + json['l'].replaceAll('//', ''));
      // ae.name = a.getElementsByTagName('a')[1].innerHtml;

      episodes.add(ae);
    }



    return episodes;
  }

  Future<String?> fetchAni1EpisodesSrc(String link) async {
    final response = await http.get(Uri.parse(link));
    final document = parse(response.body);

    return document.getElementsByTagName('source')[0].attributes['src'];
  }
}

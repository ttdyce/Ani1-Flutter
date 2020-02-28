import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_world/Ani1Scraper.dart';
import 'package:hello_world/Anime.dart';
import 'package:hello_world/VideoPlayer.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Ani1Anime>> futureAnimes;

  @override
  void initState() {
    super.initState();

    final scraper = Ani1Scraper();
    futureAnimes = scraper.fetchAnimes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: FutureBuilder<List<Ani1Anime>>(
          future: futureAnimes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //retrieve animes from scraper
              final List<Ani1Anime> animes = snapshot.data;
              return GridView.count(
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 3,
                // Generate 100 widgets that display their index in the List.
                children: List.generate(animes.length, (index) {
                  return Column(
                    children: <Widget>[
                      Container(
                          height: 40,
                          width: 200,
                          child: Card(
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SecondRoute(anime: animes[index])),
                                );
                                print('Card tapped.');
                              },
                              child: Text('Index $index'),
                            ),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          )),
                      Text('${animes[index].name}'),
                      Text('${animes[index].episode}'),
                      Text('${animes[index].year}'),
                      Text('${animes[index].fansub}'),
                      Text('${animes[index].cat}'),
                    ],
                  );
                }),
              );
            } else if (snapshot.hasError) return Text("${snapshot.error}");

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  final Ani1Anime anime;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  SecondRoute({Key key, @required this.anime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scraper = Ani1Scraper();
    final futureAnime = scraper.fetchAnime(anime.cat);

    return Scaffold(
        appBar: AppBar(
          title: Text('${anime.name} ${anime.episode}'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<List<Ani1Episode>>(
                future: futureAnime,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final List<Ani1Episode> episodes = snapshot.data;
                  Future<String> futureSrc =
                      scraper.fetchAni1EpisodesSrc(episodes[0].link);

                  return FutureBuilder<String>(
                      future: futureSrc,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Column(
                            children: [
                              Text("Got link, loading src..."),
                              CircularProgressIndicator(),
                            ],
                          );

                        final String src = snapshot.data;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VideoPlayerScreen(
                              link: src,
                            ),
                          ],
                        );
                      });
                },
              ),
              FutureBuilder<List<Ani1Episode>>(
                future: futureAnime,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final List<Ani1Episode> episodes = snapshot.data;

                  return Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.all(8),
                          itemCount: episodes.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Text("episodes ${episodes[i].link}");
                          }));
                },
              ),
            ],
          ),
        ));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String link;

  VideoPlayerScreen({Key key, this.link}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(link);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  String link;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  _VideoPlayerScreenState(String link) {
    this.link = link;
  }

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      link,
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.play();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: InkWell(
              onDoubleTap: () {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              },
              child: VideoPlayer(_controller),
            ),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

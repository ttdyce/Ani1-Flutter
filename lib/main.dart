import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/Ani1Scraper.dart';
import 'package:hello_world/Anime.dart';
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
  FutureBuilder futureBuilder;

  @override
  void initState() {
    super.initState();

    final scraper = Ani1Scraper();
    futureAnimes = scraper.fetchAnimes();
    futureBuilder = FutureBuilder<List<Ani1Anime>>(
      future: futureAnimes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //retrieve animes from scraper
          final List<Ani1Anime> animes = snapshot.data;
          return GridView.builder(
              itemCount: animes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: (10 / 16)),
              itemBuilder: (BuildContext context, int index) {
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
              });
        } else if (snapshot.hasError) return Text("${snapshot.error}");

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Anime List'),
        ),
        body: futureBuilder,
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  final Ani1Anime anime;

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
                  String src = episodes[0].link;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoPlayerScreen(
                        link: src,
                      ),
                    ],
                  );
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
                            return Text(
                                "${episodes[i].name} ${episodes[i].link}");
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
  ChewieController chewieController;

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            showControls: true,
          );

          return Container(
              height: 300, // todo remove hardcode height
              child: Chewie(
                controller: chewieController,
              ));
//          return AspectRatio(
//            aspectRatio: _controller.value.aspectRatio,
//            // Use the VideoPlayer widget to display the video.
//            child: InkWell(
//              onDoubleTap: () {
//                _controller.value.isPlaying
//                    ? _controller.pause()
//                    : _controller.play();
//              },
//              child: Chewie(
//                controller: chewieController,
//              ),
//            ),
//          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    chewieController.dispose();

    super.dispose();
  }
}

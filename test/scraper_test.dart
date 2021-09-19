

import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/Ani1Scraper.dart';

main(){
  test('Ani1Scraper should be able to get the video url', () async {
    final scraper = Ani1Scraper();
    final futureAnime = await scraper.fetchAnime('/832'); // 832: 七大罪 憤怒的審判 (第四季) found in https://anime1.me/

    expect(futureAnime, 1);
  });
}
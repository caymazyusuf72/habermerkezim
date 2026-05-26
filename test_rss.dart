import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

void main() async {
  final dio = Dio();
  dio.options.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  
  final feeds = [
    'https://www.hurriyet.com.tr/rss/ekonomi',
    'https://www.sabah.com.tr/rss/ekonomi.xml',
    'https://www.ntv.com.tr/ekonomi.rss',
    'https://www.haberturk.com/rss/kategori/ekonomi.xml'
  ];
  
  for (final url in feeds) {
    try {
      print('\n--- Fetching $url ---');
      final res = await dio.get(url);
      final doc = XmlDocument.parse(res.data.toString());
      final items = doc.findAllElements('item').take(3);
      for (final item in items) {
        final title = item.findElements('title').firstOrNull?.innerText;
        final category = item.findElements('category').firstOrNull?.innerText;
        print('Title: $title');
        print('Category: $category');
      }
    } catch(e) {
      print('Error: $e');
    }
  }
}

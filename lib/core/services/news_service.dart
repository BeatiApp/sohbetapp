import 'dart:convert';

import 'package:sohbetapp/models/news_model.dart';
import 'package:sohbetapp/utilities/apis.dart';
import 'package:http/http.dart' as http;

class NewsService {
  String url = "http://newsapi.org/v2/top-headlines?country=tr&apiKey=$newsAPI";

  Future<List<NewsModel>> getAllNews() async {
    http.Response response = await http.get(url);
    Map<String, dynamic> data = jsonDecode(response.body);
    List list = data['articles'];
    List<NewsModel> newsList = [];

    list.forEach((element) {
      newsList.add(NewsModel.fromJSON(element));
    });

    return newsList;
  }

  Future<List<NewsModel>> getCategoryNews(NewsCategoryType category) async {
    String categoryStr;

    switch (category) {
      case NewsCategoryType.business:
        categoryStr = "business";
        break;
      case NewsCategoryType.entertainment:
        categoryStr = "entertainment";
        break;
      case NewsCategoryType.sports:
        categoryStr = "sports";
        break;
      case NewsCategoryType.science:
        categoryStr = "science";
        break;
      case NewsCategoryType.health:
        categoryStr = "health";
        break;
      case NewsCategoryType.technology:
        categoryStr = "technology";
        break;
      default:
    }

    String newURL = url + "&category=$categoryStr";
    http.Response response = await http.get(newURL);
    Map<String, dynamic> data = jsonDecode(response.body);
    List list = data['articles'];
    List<NewsModel> newsList = [];

    list.forEach((element) {
      newsList.add(NewsModel.fromJSON(element));
    });

    return newsList;
  }
}

enum NewsCategoryType {
  business,
  entertainment,
  health,
  science,
  sports,
  technology
}

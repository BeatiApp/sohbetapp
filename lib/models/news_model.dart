class NewsModel {
  final String author;
  final String title;
  final String description;
  final String url;
  final String content;
  final String urlToImage;
  final String publishedToAt;

  NewsModel(
      {this.content,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedToAt});

  factory NewsModel.fromJSON(Map<String, dynamic> data) {
    return NewsModel(
        author: data['author'],
        description: data['description'],
        publishedToAt: data['publishedToAt'],
        title: data['title'],
        content: data['content'],
        url: data['url'],
        urlToImage: data['urlToImage']);
  }
}

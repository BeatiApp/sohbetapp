class Music {
  final String title;
  final double duration;
  final double position;
  final String author;
  final String playerState;
  final String state;
  final String url;

  Music(
      {this.title,
      this.duration,
      this.position,
      this.author,
      this.playerState,
      this.state,
      this.url});

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      author: map['author'],
      duration: map['duration'],
      playerState: map['playerState'],
      position: map['position'],
      state: map['state'],
      title: map['title'],
    );
  }
}

import 'dart:developer';

class Article {
  int id = 0;
  int groupsId = 0;
  String name = '';
  String description='';
  String createdAt='';
  bool submitted = false;
  Group group = Group();
  VoteSubmit voteSubmit = VoteSubmit();
  Session session = Session();
  List<SubArticle> subArticles = [];

  static Article fromJson(Map<String, dynamic> json)  {
    Article article = Article();
    article.id = json["id"];
    article.groupsId = json["groupsId"];
    article.name = json["name"];
    article.description = json["description"];
    article.createdAt = json["createdAt"];

    article.group.id = json["group"]["id"];
    article.group.name = json["group"]["name"];
    article.group.readableId = json["group"]["readableId"];
    article.group.createdAt = json["group"]["createdAt"];

    article.session.id = json["session"]["id"];
    article.session.articleId = json["session"]["articleId"];
    article.session.name = json["session"]["name"];
    article.session.description = json["session"]["description"];
    article.session.from = json["session"]["from"];
    article.session.to = json["session"]["to"];

    for(Map<String, dynamic> sa in json["subArticles"]) {
      SubArticle saTemp = new SubArticle();
      saTemp.id = sa["id"];
      saTemp.articleId = sa["articleId"];
      saTemp.name = sa["name"];
      saTemp.description = sa["description"];
      saTemp.createdAt = sa["createdAt"];
      saTemp.voteType = sa["voteType"];
      article.subArticles.add(saTemp);
    }
    if (json["voteSubmitResponse"] != null) {
      article.voteSubmit.id = json["voteSubmitResponse"]["id"];
      article.voteSubmit.articleId = json["voteSubmitResponse"]["articleId"];
      article.voteSubmit.userEmail = json["voteSubmitResponse"]["userEmail"];
    }
    article.submitted = json["submitted"];

    return article;
  }
}

class Group {
  int id = 0;
  String name = '';
  String readableId = '';
  String createdAt = '';
}
class VoteSubmit {
  int id = 0;
  String userEmail = '';
  int articleId = 0;
}
class SubArticle {
  int id = 0;
  int articleId = 0;
  String name = '';
  String description = '';
  String createdAt = '';
  int voteType = -1;
}
class Session {
  int id = 0;
  int articleId = 0;
  String name = '';
  String description = '';
  String from = '';
  String to = '';
}
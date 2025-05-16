class ReferenceModel {
  final String url;
  final String logoUrl;
  final String siteName;
  final String title;
  final String summary;
  final String publishTime;

  ReferenceModel({
    required this.url,
    required this.logoUrl,
    required this.siteName,
    required this.title,
    required this.summary,
    required this.publishTime,
  });

  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      url: json['url'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      siteName: json['site_name'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      publishTime: json['publish_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'logo_url': logoUrl,
      'site_name': siteName,
      'title': title,
      'summary': summary,
      'publish_time': publishTime,
    };
  }
}

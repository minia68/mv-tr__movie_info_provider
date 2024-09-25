import 'package:json_annotation/json_annotation.dart';

part 'configuration_response.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ConfigurationResponse {
  final Images? images;

  ConfigurationResponse({required this.images});

  factory ConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationResponseFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Images {
  final String baseUrl;
  final String secureBaseUrl;
  final List<String> backdropSizes;
  final List<String> logoSizes;
  final List<String> posterSizes;
  final List<String> profileSizes;
  final List<String> stillSizes;

  Images({
    required this.baseUrl,
    required this.secureBaseUrl,
    required this.backdropSizes,
    required this.logoSizes,
    required this.posterSizes,
    required this.profileSizes,
    required this.stillSizes,
  });

  factory Images.fromJson(Map<String, dynamic> json) => _$ImagesFromJson(json);
}

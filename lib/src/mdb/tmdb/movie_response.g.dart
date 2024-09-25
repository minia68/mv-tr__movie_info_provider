// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      json['poster_path'] as String?,
      json['overview'] as String,
      json['release_date'] as String?,
      (json['id'] as num).toInt(),
      json['title'] as String,
      json['backdrop_path'] as String?,
      (json['vote_count'] as num).toInt(),
      (json['vote_average'] as num).toDouble(),
      (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['production_countries'] as List<dynamic>?)
          ?.map((e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['credits'] == null
          ? null
          : Credits.fromJson(json['credits'] as Map<String, dynamic>),
      json['videos'] == null
          ? null
          : Videos.fromJson(json['videos'] as Map<String, dynamic>),
    );

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
      (json['id'] as num).toInt(),
      json['name'] as String,
    );

ProductionCountry _$ProductionCountryFromJson(Map<String, dynamic> json) =>
    ProductionCountry(
      json['iso_3166_1'] as String,
      json['name'] as String,
    );

Credits _$CreditsFromJson(Map<String, dynamic> json) => Credits(
      (json['cast'] as List<dynamic>?)
          ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['crew'] as List<dynamic>?)
          ?.map((e) => Crew.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Cast _$CastFromJson(Map<String, dynamic> json) => Cast(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['character'] as String,
      (json['order'] as num).toInt(),
      json['profile_path'] as String?,
    );

Crew _$CrewFromJson(Map<String, dynamic> json) => Crew(
      (json['id'] as num).toInt(),
      json['name'] as String,
      json['job'] as String,
      json['profile_path'] as String?,
    );

Videos _$VideosFromJson(Map<String, dynamic> json) => Videos(
      (json['results'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      json['key'] as String,
      json['site'] as String,
      json['type'] as String,
    );

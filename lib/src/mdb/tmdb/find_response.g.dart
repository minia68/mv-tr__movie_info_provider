// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindResponse _$FindResponseFromJson(Map<String, dynamic> json) => FindResponse(
      movieResults: (json['movie_results'] as List<dynamic>)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

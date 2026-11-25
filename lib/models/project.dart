import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Matches `ProjectSerializer` in the Django backend. `fieldRename: snake`
/// maps Dart camelCase names (for example `techStack`) to the API's
/// snake_case keys (`tech_stack`).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID assigned by Django, so it is never sent in a POST body.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  @JsonKey(defaultValue: '')
  final String techStack;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  /// Optional; an empty string means the project has no image.
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

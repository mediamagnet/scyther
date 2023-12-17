import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:toml/toml.dart';

var file = 'config.toml';

class TestIssue {
  String summary;
  String description;
  Category category;
  Project project;
  Severity severity;
  List<Tag> tags;

  TestIssue({
    required this.summary,
    required this.description,
    required this.category,
    required this.project,
    required this.severity,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'description': description,
      'category': category.toJson(),
      'project': project.toJson(),
      'severity': severity.toJson(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}

class Category {
  String name;

  Category({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Project {
  int id;

  Project({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class Severity {
  String name;

  Severity({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Tag {
  String name;

  Tag({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

final titleInput = TextInputBuilder(
    customId: 'title',
    style: TextInputStyle.short,
    label: 'Issue Title',
    isRequired: true);

final detailInput = TextInputBuilder(
    customId: 'details',
    style: TextInputStyle.paragraph,
    label: 'Issue',
    isRequired: true,
    placeholder: 'The more detail the better');

final recreateInput = TextInputBuilder(
    customId: 'steps',
    style: TextInputStyle.paragraph,
    label: 'Steps to Recreate');

final linkInput = TextInputBuilder(
    customId: 'screenshot',
    style: TextInputStyle.short,
    label: 'Issue Screenshot',
    isRequired: false);

final typeInput = TextInputBuilder(
    customId: 'type',
    style: TextInputStyle.short,
    label: 'Type of issue',
    isRequired: true,
    placeholder: 'Bug, Request, Question');

final newIssue = ChatCommand(
    'newissue',
    'Create an Issue in the tracker',
    id('newIssue', (InteractionChatContext context) async {
      var document = await TomlDocument.load(file);
      var config = document.toMap();
      var issue = await context.getModal(title: 'Create Issue', components: [
        titleInput,
        typeInput,
        detailInput,
        recreateInput,
        linkInput
      ]);
      issue.acknowledge();

      String? screenshot = '';
      if (issue['screenshot'] == '') {
        screenshot = 'No Screenshot Submitted';
      } else {
        screenshot = issue['screenshot'];
      }

      print(
          "\x1B[31m \u001b[7m \ueb70 New Issue \x1B[0m Title: ${issue['title']}, Description: ${issue['details']}, Steps: ${issue['steps']}, Screenshot: $screenshot, Type: ${issue['type']}");
      List<Tag> tagsList;
      if (issue['type'] is List) {
        tagsList =
            (issue['type'] as List).map((tag) => Tag(name: tag)).toList();
      } else {
        tagsList = [Tag(name: issue['type'].toString())];
      }
      TestIssue issueStr = TestIssue(
          summary: issue['title'].toString(),
          description:
              "Description: ${issue['details']} \n Steps: ${issue['steps']} \n Screenshot: $screenshot",
          category: Category(name: issue['type'].toString()),
          project: Project(id: 1),
          severity: Severity(name: 'major'),
          tags: tagsList);
      String jsonIssue = jsonEncode(issueStr.toJson());
      Map<String, String> headers = {
        'Authorization': config['Mantis']['API'],
        'Content-Type': 'application/json'
      };

      http.Response response = await http.post(
          Uri.parse(config['Mantis']['URL'] + '/api/rest/issues'),
          headers: headers,
          body: jsonIssue);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        String issueID = jsonData['issue']['id'].toString().padLeft(7, '0');
        issue.respond(
            MessageBuilder(
                content:
                    "Issue submitted with ID of [$issueID](${config['Mantis']['URL']}/view.php?id=$issueID), Note: Login Required"),
            level: ResponseLevel.private);
      }
    }));

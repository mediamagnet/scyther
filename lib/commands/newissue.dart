import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final titleInput = TextInputBuilder(
    customId: 'titleissue',
    style: TextInputStyle.short,
    label: 'Issue Title',
    isRequired: true);

final detailInput = TextInputBuilder(
    customId: 'detailsissue',
    style: TextInputStyle.paragraph,
    label: 'Issue',
    isRequired: true,
    placeholder: 'The more detail the better');

final recreateInput = TextInputBuilder(
    customId: 'stepsinput',
    style: TextInputStyle.paragraph,
    label: 'Steps to Recreate');

final linkInput = TextInputBuilder(
    customId: 'screenshotlink',
    style: TextInputStyle.short,
    label: 'Issue Screenshot');

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
      var issue = await context.getModal(title: 'Create Issue', components: [
        titleInput,
        typeInput,
        detailInput,
        recreateInput,
        linkInput
      ]);
      print(issue.toString());
    }));

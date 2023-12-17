import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final ChatCommand ping = ChatCommand(
    'ping',
    'Checks if the bot is online',
    id('ping', (ChatContext context) {
      context.respond(MessageBuilder(content: 'https://cdn.dribbble.com/users/460316/screenshots/2118863/media/457df2f0d59c0169111b7d0527b83324.gif'));
    }),
  );
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_extensions/nyxx_extensions.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:scyther/commands.dart';
import 'package:toml/toml.dart';
import 'dart:async';

var ownerID = '';
var launch = DateTime.now();
// String botID = '';
var botToken;
var botStatus;
var file = 'config.toml';

Future main() async {
  try {
    var document = await TomlDocument.load(file);
    var config = document.toMap();
    print('Loaded config file: $file');
    ownerID = config['Owner']['ID'];
    // botID = config['Bot']['ID'];
    botToken = config['Bot']['Token'];
    botStatus = config['Bot']['Status'];

    print('Connected');

    CommandsPlugin commands = CommandsPlugin(
      prefix: (message) => '!',
      options: CommandsOptions(logErrors: true),
    );

    commands.addCommand(newIssue);
    commands.addCommand(ping);

    final bot = await Nyxx.connectGateway(botToken, GatewayIntents.all,
        options: GatewayClientOptions(plugins: [logging, cliIntegration, commands]));
    final emoji = bot.getTextEmoji('❤️');
    final botID = await bot.users.fetchCurrentUser();
    bot.onReady.listen((ReadyEvent e) {
      print('Connected to Discord');

      bot.updatePresence(PresenceBuilder(
          status: CurrentUserStatus.online,
          isAfk: false,
          activities: [
            ActivityBuilder(
                name: 'with the Source Code',
                type: ActivityType.game,
                url: Uri.parse('https://github.com/mediamagnet/scyther'))
          ]));
    });

    bot.onMessageCreate.listen((event) async {
      if (event.mentions.contains((botID))) {
        await event.message.react(ReactionBuilder.fromEmoji(emoji));
      }
    });



    print(commands.registeredCommands);
  } catch (e) {
    print(e);
  }
}

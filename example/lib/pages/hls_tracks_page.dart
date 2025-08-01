import 'package:better_player_plus/better_player_plus.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

class HlsTracksPage extends StatefulWidget {
  @override
  _HlsTracksPageState createState() => _HlsTracksPageState();
}

class _HlsTracksPageState extends State<HlsTracksPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Constants.hlsTestStreamUrl,
      useAsmsSubtitles: true,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(
      dataSource,
    );
    super.initState();
  }

  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HLS tracks"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Player with HLS stream which loads tracks from HLS."
              " You can choose tracks by using overflow menu (3 dots in right corner).",
              style: TextStyle(fontSize: 16),
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
          TextField(
            controller: _urlController,
          ),
          ElevatedButton(
            onPressed: () {
              BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                BetterPlayerDataSourceType.network,
                _urlController.text,
                useAsmsSubtitles: true,
                headers: {
                  'Cookie':
                      'sails.sid=s%3AaM93otK1qZVuQP-1X8oCjygIWoj6koi4.HzsPdlUHLsBbJLTsZcQEGyP3xzZsy8BsHVUabnAbLtQ',
                  'Referer': 'https://www.floatplane.com/',
                  'Origin': 'https://www.floatplane.com',
                },
              );
              _betterPlayerController.setupDataSource(dataSource);
            },
            child: Text("Load tracks"),
          ),
        ],
      ),
    );
  }
}

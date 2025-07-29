import 'package:better_player_plus/src/core/better_player_utils.dart';

class BetterPlayerSubtitle {
  static const String timerSeparator = ' --> ';
  final int? index;
  final Duration? start;
  final Duration? end;
  final List<String>? texts;

  BetterPlayerSubtitle._({
    this.index,
    this.start,
    this.end,
    this.texts,
  });

  factory BetterPlayerSubtitle(String value, bool isWebVTT) {
    try {
      // Clean up the input and split into lines
      final lines = value
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        return BetterPlayerSubtitle._();
      }

      // Handle WebVTT specific parsing
      if (isWebVTT) {
        // Skip WebVTT header and style/region blocks
        if (lines[0].contains('WEBVTT') || 
            lines[0].contains('STYLE') || 
            lines[0].contains('REGION')) {
          return BetterPlayerSubtitle._();
        }
      }

      if (lines.length == 2) {
        return _handle2LinesSubtitles(lines);
      } else if (lines.length >= 2) {
        return _handle3LinesAndMoreSubtitles(lines, isWebVTT);
      }
      
      return BetterPlayerSubtitle._();
    } catch (e) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $value\nError: $e");
      return BetterPlayerSubtitle._();
    }
  }

  static BetterPlayerSubtitle _handle2LinesSubtitles(List<String> scanner) {
    try {
      final timeSplit = scanner[0].split(timerSeparator);
      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      final texts = scanner.sublist(1, scanner.length);

      return BetterPlayerSubtitle._(
        index: -1,
        start: start,
        end: end,
        texts: texts,
      );
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $scanner");
      return BetterPlayerSubtitle._();
    }
  }

  static BetterPlayerSubtitle _handle3LinesAndMoreSubtitles(
      List<String> scanner, bool isWebVTT) {
    try {
      if (scanner.isEmpty) {
        BetterPlayerUtils.log("Empty subtitle scanner data");
        return BetterPlayerSubtitle._();
      }
      
      int? index = -1;
      List<String> timeSplit = [];
      int firstLineOfText = 0;
      
      if (scanner[0].contains(timerSeparator)) {
        timeSplit = scanner[0].split(timerSeparator);
        firstLineOfText = 1;
      } else if (scanner.length > 1) {
        index = int.tryParse(scanner[0]);
        timeSplit = scanner[1].split(timerSeparator);
        firstLineOfText = 2;
      } else {
        BetterPlayerUtils.log("Invalid subtitle format: $scanner");
        return BetterPlayerSubtitle._();
      }

      if (timeSplit.length < 2) {
        BetterPlayerUtils.log("Invalid time format in subtitle: $scanner");
        return BetterPlayerSubtitle._();
      }

      final start = _stringToDuration(timeSplit[0]);
      final end = _stringToDuration(timeSplit[1]);
      
      if (firstLineOfText >= scanner.length) {
        BetterPlayerUtils.log("No subtitle text found: $scanner");
        return BetterPlayerSubtitle._(start: start, end: end);
      }
      
      final texts = scanner.sublist(firstLineOfText, scanner.length);
      return BetterPlayerSubtitle._(
          index: index, start: start, end: end, texts: texts);
    } on Exception catch (e) {
      BetterPlayerUtils.log("Failed to parse subtitle line: $scanner. Error: $e");
      return BetterPlayerSubtitle._();
    }
  }

  static Duration _stringToDuration(String value) {
    try {
      final valueSplit = value.split(" ");
      String componentValue;

      if (valueSplit.length > 1) {
        componentValue = valueSplit[0];
      } else {
        componentValue = value;
      }

      final component = componentValue.split(':');
      // Interpret a missing hour component to mean 00 hours
      if (component.length == 2) {
        component.insert(0, "00");
      } else if (component.length != 3) {
        return const Duration();
      }

      final secsAndMillisSplitChar = component[2].contains(',') ? ',' : '.';
      final secsAndMillsSplit = component[2].split(secsAndMillisSplitChar);
      if (secsAndMillsSplit.length != 2) {
        return const Duration();
      }

      final result = Duration(
        hours: int.tryParse(component[0])!,
        minutes: int.tryParse(component[1])!,
        seconds: int.tryParse(secsAndMillsSplit[0])!,
        milliseconds: int.tryParse(secsAndMillsSplit[1])!,
      );
      return result;
    } on Exception catch (_) {
      BetterPlayerUtils.log("Failed to process value: $value");
      return const Duration();
    }
  }

  @override
  String toString() {
    return 'BetterPlayerSubtitle{index: $index, start: $start, end: $end, texts: $texts}';
  }
}

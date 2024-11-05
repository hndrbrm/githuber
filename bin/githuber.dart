import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';
import 'package:http/http.dart' as http;

import 'argument.dart';

Future<void> main(List<String> arguments) async {
  final argument = Argument.parse(arguments);

  // final github = GitHub();
  final github = GitHub();
  final slug = RepositorySlug(
    argument.github.username,
    argument.github.repository,
  );

  await for (var release in github.repositories.listReleases(slug)) {
    final releaseDir = Directory('release/${release.tagName!}');
    if (!await releaseDir.exists()) {
      await releaseDir.create(recursive: true);
    }

    final file = File('${releaseDir.path}/info.json');
    if (!(await file.exists()) || argument.overwrite) {
      stdout.write("Saving '${release.tagName}/info.json'...");
      await file.writeAsString(jsonEncode(release.toJson()));
      stdout.writeln(' OK');
    } else {
      print("Skip '${release.tagName}/info.json'");
    }

    if (release.assets != null && release.assets!.isNotEmpty) {
      final assetDir = Directory('${releaseDir.path}/asset');
      if (!await assetDir.exists()) {
        assetDir.create(recursive: true);
      }

      for (var asset in release.assets!) {
        final file = File('${assetDir.path}/${asset.name}');
        if (!(await file.exists()) || argument.overwrite) {
          stdout.write("  Downloading '${asset.name}'...");
          final response = await http.get(Uri.parse(asset.browserDownloadUrl!));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            stdout.writeln(' OK');
          } else {
            stdout.writeln(' FAILED');
          }
        } else {
          print("  Skip '${asset.name}'");
        }
      }
    }
  }
}

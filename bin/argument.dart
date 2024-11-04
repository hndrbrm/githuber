// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'github.dart';

final class Argument {
  const Argument._({
    required this.github,
    required this.verbose,
    required this.overwrite,
  });

  factory Argument.parse(List<String> arguments) {
    final parser = _parser();

    try {
      final results = parser.parse(arguments);

      if (results.wasParsed('help')) {
        _printUsage();
        exit(0);
      }

      if (results.wasParsed('version')) {
        print('githuber version: $_version');
        exit(0);
      }

      var verbose = false;
      if (results.wasParsed('verbose')) {
        verbose = true;
      }

      var overwrite = false;
      if (results.wasParsed('overwrite')) {
        overwrite = true;
      }

      if (results.rest.isEmpty) {
        print('Github repository url are needed!');
        print('');
        _printUsage();
        exit(0);
      }

      final github = _parseGithub(results.rest.first);

      return Argument._(
        github: github,
        verbose: verbose,
        overwrite: overwrite,
      );
    } catch (e) {
      if (e is FormatException) {
        _exitFormatException(e);
      }

      rethrow;
    }
  }

  final Github github;
  final bool verbose;
  final bool overwrite;

  // This should be equal to pubspec.yaml
  // Theres still no good mechanism to synchronize this variable.
  static const String _version = '0.0.1';

  static ArgParser _parser() => ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Clone repository from github.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addFlag(
      'overwrite',
      negatable: true,
      help: 'Download and replace the file if exist.',
      defaultsTo: false,
      abbr: 'o',
    );

  static void _printUsage() {
    final parser = _parser();

    print('Usage: dart githuber.dart <flags> url');
    print(parser.usage);
  }

  static Github _parseGithub(String argument) {
    try {
      return Github.parse(argument);
    } catch (e) {
      if (e is FormatException) {
        _exitFormatException(e);
      }

      rethrow;
    }
  }

  static void _exitFormatException(FormatException exception, [int exitNumber = 1] ) {
    print(exception.message);
    print('');
    _printUsage();
    exit(exitNumber);
  }
}

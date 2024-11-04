// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

final class Github {
  const Github._({
    required this.username,
    required this.repository,
  });

  factory Github.parse(String argument) {
    if (argument.isEmpty) {
      throw EmptyRepositoryUrlException();
    }

    final regex = RegExp(
      r'^https://github\.com/([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)$',
    );

    final match = regex.firstMatch(argument);
    if (match == null || match.group(1) == null || match.group(2) == null) {
      throw InvalidRepositoryUrlException();
    }

    return Github._(
      username: match.group(1)!,
      repository: match.group(2)!,
    );
  }

  final String username;
  final String repository;
}

final class EmptyRepositoryUrlException extends FormatException {
  const EmptyRepositoryUrlException() : super(
    'Github repository url cannot be empty!',
  );
}

final class InvalidRepositoryUrlException extends FormatException {
  const InvalidRepositoryUrlException() : super(
"""The argument supplied are not a github repository url:
'https://github.com/username/repository'""",
  );
}

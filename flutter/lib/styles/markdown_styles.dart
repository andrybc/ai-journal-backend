import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'text_styles.dart';

/// A utility class for markdown-specific styling
class AppMarkdownStyle {
  /// Creates a standard MarkdownStyleSheet with app-specific styling
  static MarkdownStyleSheet markdownStyleSheet(ColorScheme colorScheme) {
    return MarkdownStyleSheet(
      p: AppTextStyle.body,
      h1: AppTextStyle.h1,
      h2: AppTextStyle.h2,
      h3: AppTextStyle.h3,
      blockquote: TextStyle(
        fontStyle: FontStyle.italic,
        color: colorScheme.onSurfaceVariant,
      ),
      code: TextStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        color: colorScheme.primary,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Custom extension set with emoji support for markdown parsing
  static final md.ExtensionSet extensionSet = md.ExtensionSet(
    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
    <md.InlineSyntax>[
      md.EmojiSyntax(),
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
    ],
  );

  /// Creates a TextField decoration for markdown editing
  static InputDecoration editorDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hintText: 'Edit your markdown here',
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
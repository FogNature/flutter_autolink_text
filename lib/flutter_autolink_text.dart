library flutter_autolink_text;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

RegExp phoneRegExp = RegExp(r"[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*");
RegExp emailRegExp = RegExp(r"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*");
RegExp linksRegExp = RegExp(r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})");

class AutolinkText extends StatelessWidget {

  final String text;
  final onWebLinkTap, onPhoneTap, onEmailTap;
  final TextStyle textStyle, linkStyle;
  bool humanize = false;

  AutolinkText({
    Key key,
    @required this.text,
    @required this.textStyle,
    @required this.linkStyle,
    this.onWebLinkTap,
    this.onEmailTap,
    this.onPhoneTap,
    this.humanize
  }) : super(key: key);

  _onLinkTap(String link, MatchType type) {
    switch (type) {
      case MatchType.phone:
        onPhoneTap(link);
        break;
      case MatchType.email:
        onEmailTap(link);
        break;
      case MatchType.link:
        onWebLinkTap(link);
        break;
      case MatchType.none:
        break;
    }
  }

  String _getTypes() {
    String types = '';
    if (onWebLinkTap != null) types += 'web';
    if (onEmailTap != null) types += 'email';
    if (onPhoneTap != null) types += 'phone';
    return types;
  }

  List<TextSpan> _buildTextSpans() {
    return findMatches(text, _getTypes(), humanize).map((match) {
      if (match.type == MatchType.none) return TextSpan(text: match.text, style: textStyle);
      final recognizer = TapGestureRecognizer();
      recognizer.onTap = () => _onLinkTap(match.text, match.type);
      return TextSpan(text: match.text, style: linkStyle, recognizer: recognizer);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          children: _buildTextSpans()
      ),
    );
  }

}

enum MatchType {phone, email, link, none}

class MatchedString {

  final MatchType type;
  final String text;

  MatchedString({this.text, this.type});

  @override
  String toString() {
    return text;
  }

}

List<MatchedString> findMatches(String text, String types, bool humanize) {

  List<MatchedString> matched = [
    MatchedString(type: MatchType.none, text: text)
  ];

  if (types.contains('phone')) {
    List<MatchedString> newMatched = [];
    for (MatchedString matchedBefore in matched) {
      if (matchedBefore.type == MatchType.none) {
        newMatched.addAll(findLinksByType(matchedBefore.text, MatchType.phone));
      } else newMatched.add(matchedBefore);
    }
    matched = newMatched;
  }

  if (types.contains('email')) {
    List<MatchedString> newMatched = [];
    for (MatchedString matchedBefore in matched) {
      if (matchedBefore.type == MatchType.none) {
        newMatched.addAll(findLinksByType(matchedBefore.text, MatchType.email));
      } else newMatched.add(matchedBefore);
    }
    matched = newMatched;
  }

  if (types.contains('web')) {
    List<MatchedString> newMatched = [];
    for (MatchedString matchedBefore in matched) {
      if (matchedBefore.type == MatchType.none) {
        final webMatches = findLinksByType(matchedBefore.text, MatchType.link);
        for (MatchedString webMatch in webMatches) {
          if (webMatch.type == MatchType.link
              && (webMatch.text.startsWith('http://') || webMatch.text.startsWith('https://'))
              && humanize) {
            newMatched.add(MatchedString(
                text: webMatch.text.substring(webMatch.text.startsWith('http://') ? 7 : 8),
                type: MatchType.link));
          } else {
            newMatched.add(webMatch);
          }
        }
      } else newMatched.add(matchedBefore);
    }
    matched = newMatched;
  }

  return matched;
}

RegExp _getRegExpByType(MatchType type) {
  switch (type) {
    case MatchType.phone:
      return phoneRegExp;
    case MatchType.email:
      return emailRegExp;
    case MatchType.link:
      return linksRegExp;
    default:
      return null;
  }
}

List<MatchedString> findLinksByType(String text, MatchType type) {
  List<MatchedString> output = [];
  final matches = _getRegExpByType(type).allMatches(text);
  int endOfMatch = 0;
  for (Match match in matches) {
    final before = text.substring(endOfMatch, match.start);
    if (before.isNotEmpty) output.add(MatchedString(text: before, type: MatchType.none));
    final lastCharacterIndex = text[match.end - 1] == ' ' ? match.end - 1 : match.end;
    output.add(MatchedString(type: type, text: text.substring(match.start, lastCharacterIndex)));
    endOfMatch = lastCharacterIndex;
  }
  final endOfText = text.substring(endOfMatch);
  if (endOfText.isNotEmpty) output.add(MatchedString(text: endOfText, type: MatchType.none));
  return output;
}

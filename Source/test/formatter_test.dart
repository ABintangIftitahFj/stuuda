import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stundaa/services/html_formatter.dart';

void main() {
  test('WhatsAppHtmlFormatter formats strong tags', () {
    const html = '<strong>Hello</strong>';
    final span = WhatsAppHtmlFormatter.format(html);
    
    // Structure: TextSpan(children: [TextSpan(children: [TextSpan(children: [TextSpan(text: 'Hello')])])])
    // The top level is from format(), the next is from body, the next is from strong
    expect(span.toPlainText(), 'Hello');
    
    // Drill down to the strong tag's span
    final bodySpan = span.children![0] as TextSpan;
    final strongSpan = bodySpan.children![0] as TextSpan;
    expect(strongSpan.style?.fontWeight, FontWeight.bold);
  });

  test('WhatsAppHtmlFormatter fixes malformed strong tags', () {
    const html = '<strong></strong>text<strong></strong>';
    final span = WhatsAppHtmlFormatter.format(html);
    expect(span.toPlainText(), 'text');
  });

  test('WhatsAppHtmlFormatter formats italic and strikethrough', () {
    const html = '<em>italic</em> <del>strike</del>';
    final text = WhatsAppHtmlFormatter.format(html).toPlainText();
    expect(text, contains('italic'));
    expect(text, contains('strike'));
  });

  test('WhatsAppHtmlFormatter handles code tags', () {
    const html = '<code>print("hi")</code>';
    final span = WhatsAppHtmlFormatter.format(html);
    expect(span.toPlainText(), 'print("hi")');
  });
}

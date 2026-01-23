import 'dart:js_interop';
import 'package:web/web.dart' as web;

void openInvoiceHtml(String htmlContent) {
  final newWindow = web.window.open('', '_blank');

  if (newWindow == null) return;

  final document = newWindow.document;
  if (document == null) return;

  document.open();
  document.write(htmlContent.toJS); // ✅ FIX HERE
  document.close();
}

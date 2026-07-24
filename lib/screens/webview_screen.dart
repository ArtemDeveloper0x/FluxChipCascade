import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/theme.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    required this.whiteBackground,
  });

  final String title;
  final String url;
  final bool whiteBackground;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final bg = widget.whiteBackground ? Colors.white : AppColors.bgDeep;
    _controller = WebViewController()
      ..setBackgroundColor(bg)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p / 100),
        onPageFinished: (_) => setState(() => _progress = 1),
        onWebResourceError: (_) => setState(() => _hasError = true),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.whiteBackground ? Colors.white : AppColors.bgDeep;
    final fg = widget.whiteBackground ? Colors.black : AppColors.textPrimary;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: widget.whiteBackground ? 1 : 0,
        title: Text(widget.title),
      ),
      body: Container(
        color: bg,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_progress < 1)
              LinearProgressIndicator(
                value: _progress,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
              ),
            if (_hasError)
              Container(
                color: bg,
                alignment: Alignment.center,
                child: Text('Unable to load page.\nCheck your internet connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: fg)),
              ),
          ],
        ),
      ),
    );
  }
}

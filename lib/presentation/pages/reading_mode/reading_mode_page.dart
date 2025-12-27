import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/article.dart';

/// Okuma modu sayfası - Distraction-free okuma, özelleştirilebilir font/stil, gece modu
class ReadingModePage extends ConsumerStatefulWidget {
  final Article article;

  const ReadingModePage({
    super.key,
    required this.article,
  });

  @override
  ConsumerState<ReadingModePage> createState() => _ReadingModePageState();
}

class _ReadingModePageState extends ConsumerState<ReadingModePage> {
  double _fontSize = 18.0;
  double _lineHeight = 1.6;
  String _fontFamily = 'Georgia';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black87;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Sistem ayarlarına göre başlangıç değerleri
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isDarkMode) {
      _backgroundColor = const Color(0xFF1A1A1A);
      _textColor = Colors.white;
    }
  }

  String _getCleanContent() {
    String content = widget.article.content ?? widget.article.description;
    
    // HTML tag'lerini temizle
    content = content.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Fazla boşlukları temizle
    content = content.replaceAll(RegExp(r'\s+'), ' ');
    content = content.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    
    return content.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                widget.article.title,
                style: TextStyle(
                  fontSize: _fontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  fontFamily: _fontFamily,
                  height: _lineHeight,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Meta bilgiler
              Row(
                children: [
                  Text(
                    widget.article.sourceName,
                    style: TextStyle(
                      fontSize: _fontSize * 0.8,
                      color: _textColor.withOpacity(0.6),
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.article.formattedDateTime,
                    style: TextStyle(
                      fontSize: _fontSize * 0.8,
                      color: _textColor.withOpacity(0.6),
                      fontFamily: _fontFamily,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // İçerik
              Text(
                _getCleanContent(),
                style: TextStyle(
                  fontSize: _fontSize,
                  color: _textColor,
                  fontFamily: _fontFamily,
                  height: _lineHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Okuma Ayarları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Font boyutu
              Text('Font Boyutu: ${_fontSize.toInt()}'),
              Slider(
                value: _fontSize,
                min: 14.0,
                max: 24.0,
                divisions: 10,
                label: _fontSize.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              
              // Satır yüksekliği
              Text('Satır Yüksekliği: ${_lineHeight.toStringAsFixed(1)}'),
              Slider(
                value: _lineHeight,
                min: 1.2,
                max: 2.0,
                divisions: 8,
                label: _lineHeight.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _lineHeight = value;
                  });
                },
              ),
              
              // Font ailesi
              DropdownButton<String>(
                value: _fontFamily,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Georgia', child: Text('Georgia')),
                  DropdownMenuItem(value: 'Times New Roman', child: Text('Times New Roman')),
                  DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                  DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fontFamily = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Gece modu
              SwitchListTile(
                title: const Text('Gece Modu'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                    if (_isDarkMode) {
                      _backgroundColor = const Color(0xFF1A1A1A);
                      _textColor = Colors.white;
                    } else {
                      _backgroundColor = Colors.white;
                      _textColor = Colors.black87;
                    }
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}


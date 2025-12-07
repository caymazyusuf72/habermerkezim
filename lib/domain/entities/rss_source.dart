/// RSS feed kaynağı entity
class RssSource {
  final String id;
  final String name;
  final String url;
  final String category;
  final String description;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastFetchedAt;
  final int? articleCount;
  final String? iconUrl;

  const RssSource({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    this.description = '',
    this.isEnabled = true,
    required this.createdAt,
    this.lastFetchedAt,
    this.articleCount,
    this.iconUrl,
  });

  /// Boş RSS kaynağı
  static RssSource get empty => RssSource(
    id: '',
    name: '',
    url: '',
    category: '',
    createdAt: DateTime.now(),
  );

  /// Boş olup olmadığını kontrol et
  bool get isEmpty => id.isEmpty;

  /// Boş olmadığını kontrol et  
  bool get isNotEmpty => !isEmpty;

  /// Aktif durumu
  bool get isActive => isEnabled && url.isNotEmpty;

  /// Son fetch durumu
  String get lastFetchStatus {
    if (lastFetchedAt == null) return 'Hiç güncellenmemiş';
    
    final now = DateTime.now();
    final diff = now.difference(lastFetchedAt!);
    
    if (diff.inMinutes < 1) {
      return 'Az önce güncellendi';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} saat önce';
    } else {
      return '${diff.inDays} gün önce';
    }
  }

  /// Domain adını al
  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  /// Kopya oluştur
  RssSource copyWith({
    String? id,
    String? name,
    String? url,
    String? category,
    String? description,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastFetchedAt,
    int? articleCount,
    String? iconUrl,
  }) {
    return RssSource(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      category: category ?? this.category,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      articleCount: articleCount ?? this.articleCount,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  /// Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'category': category,
      'description': description,
      'isEnabled': isEnabled,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastFetchedAt': lastFetchedAt?.millisecondsSinceEpoch,
      'articleCount': articleCount,
      'iconUrl': iconUrl,
    };
  }

  /// Map'den oluştur
  factory RssSource.fromMap(Map<String, dynamic> map) {
    return RssSource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      isEnabled: map['isEnabled'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastFetchedAt: map['lastFetchedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastFetchedAt'])
          : null,
      articleCount: map['articleCount'],
      iconUrl: map['iconUrl'],
    );
  }

  @override
  String toString() {
    return 'RssSource(id: $id, name: $name, url: $url, category: $category, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RssSource && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

/// Varsayılan RSS kaynakları
class DefaultRssSources {
  static List<RssSource> get sources => [
    // Son Dakika Haberleri
    RssSource(
      id: 'sondakika_trt',
      name: 'TRT Haber - Son Dakika',
      url: 'https://www.trthaber.com/xml_mobile.rss',
      category: 'sondakika',
      description: 'TRT Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.trthaber.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_ahaber',
      name: 'A Haber - Son Dakika',
      url: 'https://www.ahaber.com.tr/rss/sondakika.xml',
      category: 'sondakika',
      description: 'A Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ahaber.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_aa',
      name: 'Anadolu Ajansı - Güncel',
      url: 'https://www.aa.com.tr/tr/rss/default?cat=guncel',
      category: 'sondakika',
      description: 'Anadolu Ajansı güncel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.aa.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_show',
      name: 'Show Haber - Son Dakika',
      url: 'https://www.showhaber.com/rss/sondakika.xml',
      category: 'sondakika',
      description: 'Show Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.showhaber.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_star',
      name: 'Star Gazetesi - Son Dakika',
      url: 'https://www.stargazete.com/rss/sondakika.xml',
      category: 'sondakika',
      description: 'Star Gazetesi son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.stargazete.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_yenisafak',
      name: 'Yeni Şafak - Son Dakika',
      url: 'https://www.yenisafak.com/rss/sondakika.xml',
      category: 'sondakika',
      description: 'Yeni Şafak son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.yenisafak.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_iha',
      name: 'İHA - İhlas Haber Ajansı',
      url: 'https://www.iha.com.tr/rss/sondakika',
      category: 'sondakika',
      description: 'İhlas Haber Ajansı son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.iha.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_dha',
      name: 'DHA - Demirören Haber Ajansı',
      url: 'https://www.dha.com.tr/rss/sondakika.xml',
      category: 'sondakika',
      description: 'Demirören Haber Ajansı son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.dha.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_cnnturk',
      name: 'CNN Türk - Son Dakika',
      url: 'https://www.cnnturk.com/feed/rss/news/sondakika',
      category: 'sondakika',
      description: 'CNN Türk son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.cnnturk.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_ntv',
      name: 'NTV - Son Dakika',
      url: 'https://www.ntv.com.tr/sondakika.rss',
      category: 'sondakika',
      description: 'NTV son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_hurriyet',
      name: 'Hürriyet - Son Dakika',
      url: 'https://www.hurriyet.com.tr/rss/sondakika',
      category: 'sondakika',
      description: 'Hürriyet son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.hurriyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_sabah',
      name: 'Sabah - Son Dakika',
      url: 'https://www.sabah.com.tr/rss/sondakika',
      category: 'sondakika',
      description: 'Sabah son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.sabah.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_milliyet',
      name: 'Milliyet - Son Dakika',
      url: 'https://www.milliyet.com.tr/rss/sondakilarss.xml',
      category: 'sondakika',
      description: 'Milliyet son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.milliyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_cumhuriyet',
      name: 'Cumhuriyet - Son Dakika',
      url: 'https://www.cumhuriyet.com.tr/rss/son_dakika.xml',
      category: 'sondakika',
      description: 'Cumhuriyet son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.cumhuriyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_haberturk',
      name: 'Habertürk - Son Dakika',
      url: 'https://www.haberturk.com/rss/sondakika',
      category: 'sondakika',
      description: 'Habertürk son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.haberturk.com/favicon.ico',
    ),
    RssSource(
      id: 'sondakika_sozcu',
      name: 'Sözcü - Son Dakika',
      url: 'https://www.sozcu.com.tr/kategori/gundem/feed/',
      category: 'sondakika',
      description: 'Sözcü son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.sozcu.com.tr/favicon.ico',
    ),

    // Genel Haberler
    RssSource(
      id: 'ntv',
      name: 'NTV',
      url: 'https://www.ntv.com.tr/gundem.rss',
      category: 'genel',
      description: 'NTV genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'cnn_turk',
      name: 'CNN Türk',
      url: 'https://www.cnnturk.com/feed/rss/all/news',
      category: 'genel',
      description: 'CNN Türk genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.cnnturk.com/favicon.ico',
    ),
    RssSource(
      id: 'hurriyet',
      name: 'Hürriyet',
      url: 'https://www.hurriyet.com.tr/rss/anasayfa',
      category: 'genel',
      description: 'Hürriyet genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.hurriyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'milliyet',
      name: 'Milliyet',
      url: 'https://www.milliyet.com.tr/rss/rss/gundemrss.xml',
      category: 'genel',
      description: 'Milliyet genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.milliyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sozcu',
      name: 'Sözcü',
      url: 'https://www.sozcu.com.tr/feed/',
      category: 'genel',
      description: 'Sözcü genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.sozcu.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sabah',
      name: 'Sabah',
      url: 'https://www.sabah.com.tr/rss',
      category: 'genel',
      description: 'Sabah genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.sabah.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'haberturk',
      name: 'Habertürk',
      url: 'https://www.haberturk.com/rss',
      category: 'genel',
      description: 'Habertürk genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.haberturk.com/favicon.ico',
    ),
    RssSource(
      id: 'trt_haber',
      name: 'TRT Haber',
      url: 'https://www.trthaber.com/xml_mobile.rss',
      category: 'genel',
      description: 'TRT Haber genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.trthaber.com/favicon.ico',
    ),
    RssSource(
      id: 'cumhuriyet',
      name: 'Cumhuriyet',
      url: 'https://www.cumhuriyet.com.tr/rss/son_dakika.xml',
      category: 'genel',
      description: 'Cumhuriyet genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.cumhuriyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'ensonhaber',
      name: 'Ensonhaber',
      url: 'https://www.ensonhaber.com/rss/manset.xml',
      category: 'genel',
      description: 'Ensonhaber genel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ensonhaber.com/favicon.ico',
    ),
    RssSource(
      id: 'trt_haber_sondakika',
      name: 'TRT Haber',
      url: 'https://www.trthaber.com/xml_mobile.rss',
      category: 'genel',
      description: 'TRT Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.trthaber.com/favicon.ico',
    ),
    RssSource(
      id: 'a_haber',
      name: 'A Haber',
      url: 'https://www.ahaber.com.tr/rss/anasayfa.xml',
      category: 'genel',
      description: 'A Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ahaber.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'anadolu_ajansi',
      name: 'Anadolu Ajansı',
      url: 'https://www.aa.com.tr/tr/rss/default?cat=guncel',
      category: 'genel',
      description: 'Anadolu Ajansı güncel haberler',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.aa.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'show_haber',
      name: 'Show Haber',
      url: 'https://www.showhaber.com/rss/anasayfa.xml',
      category: 'genel',
      description: 'Show Haber son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.showhaber.com/favicon.ico',
    ),
    RssSource(
      id: 'star_gazetesi',
      name: 'Star Gazetesi',
      url: 'https://www.star.com.tr/rss/rss.xml',
      category: 'genel',
      description: 'Star Gazetesi son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.star.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'yeni_safak',
      name: 'Yeni Şafak',
      url: 'https://www.yenisafak.com/rss',
      category: 'genel',
      description: 'Yeni Şafak son dakika haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.yenisafak.com/favicon.ico',
    ),
    RssSource(
      id: 'iha',
      name: 'İHA',
      url: 'https://www.iha.com.tr/rss',
      category: 'genel',
      description: 'İhlas Haber Ajansı haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.iha.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'dha',
      name: 'DHA',
      url: 'https://www.dha.com.tr/rss.xml',
      category: 'genel',
      description: 'Demirören Haber Ajansı haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.dha.com.tr/favicon.ico',
    ),

    // Dünya Haberleri
    RssSource(
      id: 'bbc_turkce',
      name: 'BBC Türkçe',
      url: 'https://feeds.bbci.co.uk/turkce/rss.xml',
      category: 'dünya',
      description: 'BBC Türkçe dünya haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.bbc.com/favicon.ico',
    ),
    RssSource(
      id: 'euronews_turkce',
      name: 'Euronews Türkçe',
      url: 'https://tr.euronews.com/rss',
      category: 'dünya',
      description: 'Euronews Türkçe dünya haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://tr.euronews.com/favicon.ico',
    ),
    RssSource(
      id: 'ntv_dunya',
      name: 'NTV Dünya',
      url: 'https://www.ntv.com.tr/dunya.rss',
      category: 'dünya',
      description: 'NTV dünya haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sputnik_turkiye',
      name: 'Sputnik Türkiye',
      url: 'https://sputniknews.com.tr/feeds/rss/',
      category: 'dünya',
      description: 'Sputnik Türkiye dünya haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://sputniknews.com.tr/favicon.ico',
    ),

    // Teknoloji
    RssSource(
      id: 'webtekno',
      name: 'Webtekno',
      url: 'https://www.webtekno.com/rss.xml',
      category: 'teknoloji',
      description: 'Webtekno teknoloji haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.webtekno.com/favicon.ico',
    ),
    RssSource(
      id: 'donanimhaber',
      name: 'Donanım Haber',
      url: 'https://www.donanimhaber.com/rss/tum-haberler',
      category: 'teknoloji',
      description: 'Donanım Haber teknoloji haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.donanimhaber.com/favicon.ico',
    ),
    RssSource(
      id: 'shiftdelete',
      name: 'ShiftDelete.Net',
      url: 'https://shiftdelete.net/feed',
      category: 'teknoloji',
      description: 'ShiftDelete.Net teknoloji haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://shiftdelete.net/favicon.ico',
    ),
    RssSource(
      id: 'teknoseyir',
      name: 'Teknoseyir',
      url: 'https://teknoseyir.com/feed/',
      category: 'teknoloji',
      description: 'Teknoseyir teknoloji haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://teknoseyir.com/favicon.ico',
    ),
    RssSource(
      id: 'chip_online',
      name: 'Chip Online',
      url: 'https://www.chip.com.tr/rss/gundem.xml',
      category: 'teknoloji',
      description: 'Chip Online teknoloji haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.chip.com.tr/favicon.ico',
    ),

    // Ekonomi
    RssSource(
      id: 'dunya',
      name: 'Dünya',
      url: 'https://www.dunya.com/rss',
      category: 'ekonomi',
      description: 'Dünya gazetesi ekonomi haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.dunya.com/favicon.ico',
    ),
    RssSource(
      id: 'ntv_ekonomi',
      name: 'NTV Ekonomi',
      url: 'https://www.ntv.com.tr/ekonomi.rss',
      category: 'ekonomi',
      description: 'NTV ekonomi haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'paraanaliz',
      name: 'Para Analiz',
      url: 'https://www.paraanaliz.com/feed/',
      category: 'ekonomi',
      description: 'Para Analiz ekonomi haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.paraanaliz.com/favicon.ico',
    ),
    RssSource(
      id: 'bloomberght',
      name: 'Bloomberg HT',
      url: 'https://www.bloomberght.com/rss/anasayfa',
      category: 'ekonomi',
      description: 'Bloomberg HT ekonomi haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.bloomberght.com/favicon.ico',
    ),
    RssSource(
      id: 'foreks',
      name: 'Foreks',
      url: 'https://www.foreks.com/rss/gundem',
      category: 'ekonomi',
      description: 'Foreks ekonomi haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.foreks.com/favicon.ico',
    ),

    // Spor
    RssSource(
      id: 'fanatik',
      name: 'Fanatik',
      url: 'https://www.fanatik.com.tr/rss/manset.xml',
      category: 'spor',
      description: 'Fanatik spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.fanatik.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'ntvspor',
      name: 'NTV Spor',
      url: 'https://www.ntvspor.net/rss',
      category: 'spor',
      description: 'NTV Spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntvspor.net/favicon.ico',
    ),
    RssSource(
      id: 'aspor',
      name: 'A Spor',
      url: 'https://www.aspor.com.tr/rss',
      category: 'spor',
      description: 'A Spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.aspor.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'milliyet_spor',
      name: 'Milliyet Spor',
      url: 'https://www.milliyet.com.tr/rss/rss/sporarss.xml',
      category: 'spor',
      description: 'Milliyet spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.milliyet.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'sporx',
      name: 'Sporx',
      url: 'https://www.sporx.com/rss/gundem',
      category: 'spor',
      description: 'Sporx spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.sporx.com/favicon.ico',
    ),
    RssSource(
      id: 'fotospor',
      name: 'FotoSpor',
      url: 'https://www.fotospor.com/rss/manset.xml',
      category: 'spor',
      description: 'FotoSpor spor haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.fotospor.com/favicon.ico',
    ),

    // Sağlık
    RssSource(
      id: 'ntv_saglik',
      name: 'NTV Sağlık',
      url: 'https://www.ntv.com.tr/saglik.rss',
      category: 'sağlık',
      description: 'NTV sağlık haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'medimagazin',
      name: 'Medimagazin',
      url: 'https://www.medimagazin.com.tr/rss/anasayfa.xml',
      category: 'sağlık',
      description: 'Medimagazin sağlık haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.medimagazin.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'saglikaktuel',
      name: 'Sağlık Aktüel',
      url: 'https://www.saglikaktuel.com/rss/',
      category: 'sağlık',
      description: 'Sağlık Aktüel sağlık haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.saglikaktuel.com/favicon.ico',
    ),

    // Bilim
    RssSource(
      id: 'ntv_bilim',
      name: 'NTV Bilim',
      url: 'https://www.ntv.com.tr/bilim.rss',
      category: 'bilim',
      description: 'NTV bilim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'webtekno_bilim',
      name: 'Webtekno Bilim',
      url: 'https://www.webtekno.com/bilim',
      category: 'bilim',
      description: 'Webtekno bilim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.webtekno.com/favicon.ico',
    ),
    RssSource(
      id: 'evrimagaci',
      name: 'Evrim Ağacı',
      url: 'https://evrimagaci.org/rss',
      category: 'bilim',
      description: 'Evrim Ağacı bilim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://evrimagaci.org/favicon.ico',
    ),
    RssSource(
      id: 'bilimfili',
      name: 'Bilim Fili',
      url: 'https://bilimfili.com/feed/',
      category: 'bilim',
      description: 'Bilim Fili bilim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://bilimfili.com/favicon.ico',
    ),

    // Magazin
    RssSource(
      id: 'mynet_magazin',
      name: 'Mynet Magazin',
      url: 'https://www.mynet.com/rss/magazin',
      category: 'magazin',
      description: 'Mynet magazin haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.mynet.com/favicon.ico',
    ),
    RssSource(
      id: 'posta_magazin',
      name: 'Posta Magazin',
      url: 'https://www.posta.com.tr/rss/magazin.xml',
      category: 'magazin',
      description: 'Posta magazin haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.posta.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'hurriyet_magazin',
      name: 'Hürriyet Magazin',
      url: 'https://www.hurriyet.com.tr/rss/magazin',
      category: 'magazin',
      description: 'Hürriyet magazin haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.hurriyet.com.tr/favicon.ico',
    ),

    // Kültür & Sanat
    RssSource(
      id: 'birgun_kultur',
      name: 'BirGün Kültür',
      url: 'https://www.birgun.net/rss/kultur-sanat.rss',
      category: 'kültür',
      description: 'BirGün kültür sanat haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.birgun.net/favicon.ico',
    ),
    RssSource(
      id: 'ntv_sanat',
      name: 'NTV Sanat',
      url: 'https://www.ntv.com.tr/sanat.rss',
      category: 'sanat',
      description: 'NTV sanat haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'cumhuriyet_kultur',
      name: 'Cumhuriyet Kültür',
      url: 'https://www.cumhuriyet.com.tr/rss/kultur_sanat.xml',
      category: 'kültür',
      description: 'Cumhuriyet kültür sanat haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.cumhuriyet.com.tr/favicon.ico',
    ),

    // Eğitim
    RssSource(
      id: 'ntv_egitim',
      name: 'NTV Eğitim',
      url: 'https://www.ntv.com.tr/egitim.rss',
      category: 'eğitim',
      description: 'NTV eğitim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'milliyet_egitim',
      name: 'Milliyet Eğitim',
      url: 'https://www.milliyet.com.tr/rss/rss/egitimrss.xml',
      category: 'eğitim',
      description: 'Milliyet eğitim haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.milliyet.com.tr/favicon.ico',
    ),

    // Turizm & Yaşam
    RssSource(
      id: 'ntv_yasam',
      name: 'NTV Yaşam',
      url: 'https://www.ntv.com.tr/yasam.rss',
      category: 'yaşam',
      description: 'NTV yaşam haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.ntv.com.tr/favicon.ico',
    ),
    RssSource(
      id: 'hurriyet_yasam',
      name: 'Hürriyet Yaşam',
      url: 'https://www.hurriyet.com.tr/rss/yasam',
      category: 'yaşam',
      description: 'Hürriyet yaşam haberleri',
      createdAt: DateTime.now(),
      iconUrl: 'https://www.hurriyet.com.tr/favicon.ico',
    ),
  ];

  /// Kategori listesi
  static const List<String> categories = [
    'sondakika',
    'genel',
    'dünya',
    'teknoloji',
    'ekonomi',
    'spor',
    'sağlık',
    'bilim',
    'eğitim',
    'kültür',
    'sanat',
    'magazin',
    'yaşam',
  ];

  /// Kategoriye göre varsayılan kaynakları al
  static List<RssSource> getSourcesByCategory(String category) {
    return sources.where((source) => source.category == category).toList();
  }

  /// Tüm kategorileri al
  static List<String> getAllCategories() {
    final cats = <String>{};
    for (final source in sources) {
      cats.add(source.category);
    }
    return cats.toList()..sort();
  }
}
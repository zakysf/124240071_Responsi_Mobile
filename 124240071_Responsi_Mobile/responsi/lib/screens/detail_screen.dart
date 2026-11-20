import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/favorite_anime.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String animeId;
  const DetailScreen({super.key, required this.animeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _animeDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await ApiService.getAnimeDetail(widget.animeId);
      setState(() {
        _animeDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isFavorite() {
    final box = Hive.box<FavoriteAnime>('favorites');
    return box.values.any((item) => item.id == widget.animeId);
  }

  void _toggleFavorite() {
    if (_animeDetail == null) return;

    final box = Hive.box<FavoriteAnime>('favorites');
    final bool favorited = _isFavorite();
    final attributes = _animeDetail!['attributes'] ?? {};
    final titles = attributes['titles'] ?? {};
    final String title =
        titles['en_jp'] ?? attributes['canonicalTitle'] ?? 'Tanpa Judul';
    final String? posterUrl = attributes['posterImage']?['small'] ??
        attributes['posterImage']?['medium'] ??
        attributes['posterImage']?['original'];
    final String averageRating =
        attributes['averageRating']?.toString() ?? 'N/A';

    if (favorited) {
      final dynamic targetKey = box.keys.firstWhere(
        (key) => box.get(key)?.id == widget.animeId,
        orElse: () => null,
      );
      if (targetKey != null) {
        box.delete(targetKey);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari daftar favorit.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      final newFav = FavoriteAnime(
        id: widget.animeId,
        name: title,
        imageUrl: posterUrl,
        rating: averageRating,
      );
      box.add(newFav);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke daftar favorit!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6519)),
      );
    }

    if (_errorMessage != null || _animeDetail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Mengambil Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Data tidak ditemukan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6519),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final attributes = _animeDetail!['attributes'] ?? {};
    final titles = attributes['titles'] ?? {};
    final String title =
        titles['en_jp'] ?? attributes['canonicalTitle'] ?? 'Tanpa Judul';
    final coverImageMap = attributes['coverImage'];
    final posterImageMap = attributes['posterImage'];
    final String? coverUrl = coverImageMap?['large'] ??
        coverImageMap?['original'] ??
        coverImageMap?['small'] ??
        coverImageMap?['tiny'] ??
        posterImageMap?['large'] ??
        posterImageMap?['original'];
    final dynamic episodeCount = attributes['episodeCount'];
    final String ageRating = attributes['ageRating'] ?? 'N/A';
    final String averageRating =
        attributes['averageRating']?.toString() ?? 'N/A';
    final String synopsis =
        attributes['synopsis'] ?? 'Tidak ada sinopsis untuk anime ini.';
    final bool favorited = _isFavorite();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (coverUrl != null)
            Image.network(
              coverUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 220,
                color: const Color(0xFF1E1E1E),
                child: const Icon(Icons.movie, size: 60, color: Colors.grey),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFF1E1E1E),
              child: const Icon(Icons.movie, size: 60, color: Colors.grey),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      averageRating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$ageRating • ${episodeCount != null ? '$episodeCount Episodes' : 'N/A Episodes'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Memutar: $title')),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Nonton',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6519),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: favorited
                              ? const Color(0xFFFF6519)
                              : Colors.grey.shade700,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          favorited ? Icons.favorite : Icons.favorite_border,
                          color: favorited
                              ? const Color(0xFFFF6519)
                              : Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  synopsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

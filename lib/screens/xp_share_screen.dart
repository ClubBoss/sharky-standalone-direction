import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/xp_service.dart';
import '../services/streak_tracker_service.dart';
import '../services/xp_milestone_service.dart';
import '../services/league_engine.dart';
import '../widgets/xp_recapped_milestone_preview_card.dart';
import '../widgets/xp_progress_ring_block.dart';

/// Screen for generating and sharing a visual XP summary card.
///
/// Features:
/// - Visual card with user's XP stats, streak, league position, milestones
/// - Save to gallery as PNG
/// - Native share dialog
class XpShareScreen extends StatefulWidget {
  XpShareScreen({super.key});

  @override
  State<XpShareScreen> createState() => _XpShareScreenState();
}

class _XpShareScreenState extends State<XpShareScreen> {
  final GlobalKey _cardKey = GlobalKey();

  int _totalXp = 0;
  int _currentStreak = 0;
  int _leaguePosition = 0;
  String _leagueName = '';
  int _claimedMilestones = 0;
  int? _unclaimedMilestone;
  int? _upcomingMilestone;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Fetch XP data
      final xpService = XpService();
      final totalXp = xpService.getTotalXp();

      // Fetch streak data
      final streakService = StreakTrackerService.instance;
      final currentStreak = await streakService.getCurrentStreak();

      // Fetch league data
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final weekSeed =
          DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);
      final leagueEngine = LeagueEngine();
      final leagueEntries = leagueEngine.simulateWeeklyLeague(
        userXp: totalXp,
        userId: userId,
        weekSeed: weekSeed,
      );
      final userEntry = leagueEntries.firstWhere((e) => e.isUser);

      // Fetch milestone data
      final milestoneService = XpMilestoneService();
      final claimedMilestones = await milestoneService.getClaimedMilestones();
      // Determine unclaimed and upcoming milestones
      final unlockedNotClaimed = await milestoneService
          .getUnlockedButUnclaimedMilestones(totalXp);
      int? unclaimed;
      if (unlockedNotClaimed.isNotEmpty) {
        unlockedNotClaimed.sort();
        unclaimed = unlockedNotClaimed.first;
      }
      int? upcoming;
      for (final m in XpMilestoneService.milestones) {
        if (m > totalXp) {
          upcoming = m;
          break;
        }
      }

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      setState(() {
        _totalXp = totalXp;
        _currentStreak = currentStreak;
        _leaguePosition = userEntry.rank;
        _leagueName = _getLeagueName(l10n, userEntry.rank);
        _claimedMilestones = claimedMilestones.length;
        _unclaimedMilestone = unclaimed;
        _upcomingMilestone = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
      });
      _showError(l10n.xpShareLoadError);
    }
  }

  String _getLeagueName(AppLocalizations l10n, int rank) {
    if (rank <= 10) return l10n.xpShareLeagueGold;
    if (rank <= 30) return l10n.xpShareLeagueSilver;
    if (rank <= 50) return l10n.xpShareLeagueBronze;
    return l10n.xpShareLeagueRookie;
  }

  String _getCaption(AppLocalizations l10n) {
    if (_totalXp >= 1000) return l10n.xpShareCaptionBeast;
    if (_totalXp >= 500) return l10n.xpShareCaptionSummit;
    if (_totalXp >= 250) return l10n.xpShareCaptionGreat;
    if (_totalXp >= 100) return l10n.xpShareCaptionKeepGoing;
    if (_totalXp >= 50) return l10n.xpShareCaptionLetsGo;
    return l10n.xpShareCaptionGettingStarted;
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    try {
      final image = await _captureCard();
      if (image == null) {
        throw Exception('Failed to capture image');
      }

      final result = await ImageGallerySaver.saveImage(
        image,
        quality: 100,
        name: 'poker_analyzer_xp_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      if (result['isSuccess'] == true) {
        _showSuccess(l10n.xpShareSaveSuccess);
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      if (!mounted) return;
      _showError(l10n.xpShareSaveError);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareCard() async {
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    try {
      final image = await _captureCard();
      if (image == null) {
        throw Exception('Failed to capture image');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/xp_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(image);

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.xpShareShareText(
          _totalXp,
          l10n.xpDaysCount(_currentStreak),
          _leaguePosition,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(l10n.xpShareShareError);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<Uint8List?> _captureCard() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpShareTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        RepaintBoundary(key: _cardKey, child: _buildShareCard(l10n)),
        const SizedBox(height: 24),
        _buildActionButtons(l10n),
      ],
    ),
  );

  Widget _buildShareCard(AppLocalizations l10n) {
    final leagueLabel = _leagueName.isEmpty
        ? l10n.xpShareLeagueRookie
        : _leagueName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App logo placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.casino, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Poker Analyzer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          // XP progress ring
          XpProgressRingBlock(
            totalXp: _totalXp,
            milestoneXp: _upcomingMilestone ?? _totalXp,
            percent: _computePercent(),
            caption: _getCaption(l10n),
            leagueRank: _leaguePosition,
          ),
          const SizedBox(height: 24),
          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.local_fire_department,
                Colors.orange[700]!,
                l10n.xpDaysCount(_currentStreak),
                l10n.xpShareStreakLabel,
              ),
              _buildStatItem(
                Icons.emoji_events,
                Colors.blue[700]!,
                '#$_leaguePosition',
                leagueLabel,
              ),
              _buildStatItem(
                Icons.verified,
                Colors.green[700]!,
                '$_claimedMilestones',
                l10n.xpShareMilestonesLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMilestonePreview(l10n),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            l10n.xpShareGeneratedFooter,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) => Column(
    children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildActionButtons(AppLocalizations l10n) => Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveToGallery,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_alt),
          label: Text(l10n.xpShareSaveButton),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isSaving ? null : _shareCard,
          icon: const Icon(Icons.share),
          label: Text(l10n.xpShareShareButton),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    ],
  );

  Widget _buildMilestonePreview(AppLocalizations l10n) => Theme(
    data: Theme.of(
      context,
    ).copyWith(cardTheme: const CardTheme(margin: EdgeInsets.zero)),
    child: XpRecappedMilestonePreviewCard(
      totalXp: _totalXp,
      unclaimedMilestone: _unclaimedMilestone,
      upcomingMilestone: _upcomingMilestone,
    ),
  );

  double _computePercent() {
    final next = _upcomingMilestone;
    if (next == null || next <= 0) {
      return 1.0;
    }
    return (_totalXp / next).clamp(0.0, 1.0);
  }
}

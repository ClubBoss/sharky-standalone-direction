import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/glass_action_button.dart';

/// Premium bet sizing panel with slider, presets, and action buttons.
class BetSizingPanel extends StatefulWidget {
  const BetSizingPanel({
    super.key,
    this.minBet = 10,
    this.maxBet = 1000,
    this.potSize = 500,
    required this.onBetConfirmed,
    required this.onCancel,
  });

  final double minBet;
  final double maxBet;
  final double potSize;
  final Function(double) onBetConfirmed;
  final VoidCallback onCancel;

  @override
  State<BetSizingPanel> createState() => _BetSizingPanelState();
}

class _BetSizingPanelState extends State<BetSizingPanel> {
  late double _currentBet;

  @override
  void initState() {
    super.initState();
    _currentBet = (widget.minBet + widget.maxBet) / 2; // Start at midpoint
  }

  void _setBet(double value) {
    setState(() {
      _currentBet = value.clamp(widget.minBet, widget.maxBet);
    });
  }

  @override
  Widget build(BuildContext context) {
    final potSize = widget.potSize;
    const betButtonHeight = 40.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!.withOpacity(0.95),
            Colors.black.withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Bet Amount',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Current bet display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[800]!.withOpacity(0.6),
                      Colors.blue[900]!.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[300]!.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentBet.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Slider
              Column(
                children: [
                  Slider(
                    value: _currentBet,
                    min: widget.minBet,
                    max: widget.maxBet,
                    divisions: 100,
                    activeColor: Colors.blue[400],
                    inactiveColor: Colors.grey[700],
                    onChanged: _setBet,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.minBet.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${widget.maxBet.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Preset buttons
              SizedBox(
                height: betButtonHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Min bet button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setBet(widget.minBet),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentBet == widget.minBet
                                ? Colors.blue[600]!
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[400]!.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _currentBet == widget.minBet
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 50% pot button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setBet(potSize * 0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_currentBet - potSize * 0.5).abs() < 1
                                ? Colors.blue[600]!
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[400]!.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '50% Pot',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (_currentBet - potSize * 0.5).abs() < 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pot button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setBet(potSize),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_currentBet - potSize).abs() < 1
                                ? Colors.blue[600]!
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[400]!.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Pot',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (_currentBet - potSize).abs() < 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Max button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setBet(widget.maxBet),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentBet == widget.maxBet
                                ? Colors.blue[600]!
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[400]!.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Max',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _currentBet == widget.maxBet
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GlassActionButton(
                      label: 'CANCEL',
                      color: const Color(0xFFD32F2F), // Red
                      onTap: widget.onCancel,
                      height: 50,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassActionButton(
                      label: 'BET',
                      color: const Color(0xFF388E3C), // Green
                      onTap: () => widget.onBetConfirmed(_currentBet),
                      isPreferred: true,
                      height: 50,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

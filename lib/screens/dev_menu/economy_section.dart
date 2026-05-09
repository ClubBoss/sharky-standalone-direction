import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/energy_service.dart';
import 'package:poker_analyzer/services/chips_wallet_service.dart';

/// Economy Debug section: tools to refill energy and add chips for testing.
class EconomySection extends StatefulWidget {
  const EconomySection({super.key});

  @override
  State<EconomySection> createState() => _EconomySectionState();
}

class _EconomySectionState extends State<EconomySection> {
  int _currentEnergy = 0;
  int _maxEnergy = 5;
  int _chipsBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final energyService = EnergyService();
    final chipsService = ChipsWalletService();

    final energy = await energyService.getCurrentEnergy();
    final max = await energyService.getMaxEnergy();
    final balance = await chipsService.getBalance();

    setState(() {
      _currentEnergy = energy;
      _maxEnergy = max;
      _chipsBalance = balance;
    });
  }

  Future<void> _refillEnergy() async {
    final energyService = EnergyService();
    await energyService.restoreEnergy(_maxEnergy);
    await _loadStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Energy refilled to max!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addChips() async {
    const amount = 1000;
    final chipsService = ChipsWalletService();
    final success = await chipsService.addChips(amount);
    await _loadStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Added $amount chips!'
                : 'Failed to add chips (limit reached?)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Energy Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u26A1 $_currentEnergy / $_maxEnergy',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _refillEnergy,
                    icon: const Icon(Icons.bolt),
                    label: const Text('Refill Energy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chips Wallet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\uD83D\uDCB0 $_chipsBalance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addChips,
                    icon: const Icon(Icons.add),
                    label: const Text('Add 1000 Chips'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Use these tools to test economy features during development.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

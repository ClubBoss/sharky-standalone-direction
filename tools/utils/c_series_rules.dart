class CSeriesRules {
  const CSeriesRules();

  static const List<String> positions = ['UTG', 'MP', 'CO', 'BTN', 'SB', 'BB'];
  static const List<String> actions = [
    'call',
    'fold',
    'raise',
    'cbet_small',
    'cbet_big',
    'check_back',
    'probe_bet',
  ];

  static const int theoryMinWords = 450;
  static const int theoryMaxWords = 650;
  static const int recapMinWords = 300;
  static const int recapMaxWords = 400;
  static const int rationaleMax = 120;
  static const int explanationMax = 80;
  static const int promptMax = 60;
  static const int optionMax = 25;
  static const int demosMin = 2;
  static const int demosMax = 3;
  static const int drillsMin = 12;
  static const int drillsMax = 16;
  static const int quizMin = 6;
  static const int quizMax = 8;
  static const int microMin = 10;
  static const int microMax = 14;

  static final RegExp imagePlaceholder = RegExp(
    r'\[\[IMAGE:\s*[^\]|]+\s*\|\s*[^\]]+\]\]',
  );

  static const List<String> bannedJargon = [
    'solver',
    'GTO+',
    'Pio',
    'aggregate report',
  ];
}

import 'package:flutter/material.dart';

enum XpLeague {
  rookie,
  whale,
  fish,
  gambler,
  amateur,
  grinder,
  semiPro,
  shark,
  beast,
  pro,
  endBoss,
  legend,
}

extension XpLeagueExt on XpLeague {
  int get minXp {
    switch (this) {
      case XpLeague.rookie:
        return 0;
      case XpLeague.whale:
        return 200;
      case XpLeague.fish:
        return 500;
      case XpLeague.gambler:
        return 1000;
      case XpLeague.amateur:
        return 2000;
      case XpLeague.grinder:
        return 4000;
      case XpLeague.semiPro:
        return 8000;
      case XpLeague.shark:
        return 15000;
      case XpLeague.beast:
        return 25000;
      case XpLeague.pro:
        return 35000;
      case XpLeague.endBoss:
        return 50000;
      case XpLeague.legend:
        return 75000;
    }
  }

  int? get maxXp {
    switch (this) {
      case XpLeague.rookie:
        return 199;
      case XpLeague.whale:
        return 499;
      case XpLeague.fish:
        return 999;
      case XpLeague.gambler:
        return 1999;
      case XpLeague.amateur:
        return 3999;
      case XpLeague.grinder:
        return 7999;
      case XpLeague.semiPro:
        return 14999;
      case XpLeague.shark:
        return 24999;
      case XpLeague.beast:
        return 34999;
      case XpLeague.pro:
        return 49999;
      case XpLeague.endBoss:
        return 74999;
      case XpLeague.legend:
        return null;
    }
  }

  String emoji() {
    switch (this) {
      case XpLeague.rookie:
        return '🐣';
      case XpLeague.whale:
        return '🐋';
      case XpLeague.fish:
        return '🐟';
      case XpLeague.gambler:
        return '🎰';
      case XpLeague.amateur:
        return '🧢';
      case XpLeague.grinder:
        return '🃏';
      case XpLeague.semiPro:
        return '🧠';
      case XpLeague.shark:
        return '🦈';
      case XpLeague.beast:
        return '🐲';
      case XpLeague.pro:
        return '👑';
      case XpLeague.endBoss:
        return '💀';
      case XpLeague.legend:
        return '🏆';
    }
  }

  String label({bool isRu = false}) {
    switch (this) {
      case XpLeague.rookie:
        return isRu ? 'Новичок' : 'Rookie';
      case XpLeague.whale:
        return isRu ? 'Кит' : 'Whale';
      case XpLeague.fish:
        return isRu ? 'Фиш' : 'Fish';
      case XpLeague.gambler:
        return isRu ? 'Гэмблер' : 'Gambler';
      case XpLeague.amateur:
        return isRu ? 'Любитель' : 'Amateur';
      case XpLeague.grinder:
        return isRu ? 'Грайндер' : 'Grinder';
      case XpLeague.semiPro:
        return isRu ? 'Полупрофи' : 'Semi-Pro';
      case XpLeague.shark:
        return isRu ? 'Акула' : 'Shark';
      case XpLeague.beast:
        return isRu ? 'Зверь' : 'Beast';
      case XpLeague.pro:
        return isRu ? 'Профи' : 'Pro';
      case XpLeague.endBoss:
        return isRu ? 'Финальный босс' : 'End Boss';
      case XpLeague.legend:
        return isRu ? 'Легенда' : 'Legend';
    }
  }

  String description({bool isRu = false}) {
    switch (this) {
      case XpLeague.rookie:
        return isRu ? 'Начало пути' : 'Just getting started';
      case XpLeague.whale:
        return isRu ? 'Щедрые банки, лузовая игра' : 'Big stacks, loose plays';
      case XpLeague.fish:
        return isRu ? 'Ошибки и эксперименты' : 'Learning through mistakes';
      case XpLeague.gambler:
        return isRu ? 'Азарт и риск' : 'High variance, high fun';
      case XpLeague.amateur:
        return isRu ? 'Уверенно осваивает основы' : 'Finding solid footing';
      case XpLeague.grinder:
        return isRu ? 'Дисциплина и объём' : 'Disciplined volume player';
      case XpLeague.semiPro:
        return isRu ? 'Плюсовый и уверенный' : 'Consistently profitable';
      case XpLeague.shark:
        return isRu ? 'Опасный регуляр' : 'Fearsome regular';
      case XpLeague.beast:
        return isRu ? 'Доминирует за столом' : 'Dominates the table';
      case XpLeague.pro:
        return isRu ? 'Полный контроль' : 'Complete mastery';
      case XpLeague.endBoss:
        return isRu ? 'GTO мастер' : 'GTO master';
      case XpLeague.legend:
        return isRu ? 'Икона покера' : 'Poker icon';
    }
  }

  static XpLeague fromXp(int xp) {
    for (final league in XpLeague.values.reversed) {
      if (xp >= league.minXp) return league;
    }
    return XpLeague.rookie;
  }

  Color color() {
    switch (this) {
      case XpLeague.rookie:
        return const Color(0xFF9E9E9E);
      case XpLeague.whale:
        return const Color(0xFF5C6BC0);
      case XpLeague.fish:
        return const Color(0xFF26A69A);
      case XpLeague.gambler:
        return const Color(0xFFFF7043);
      case XpLeague.amateur:
        return const Color(0xFF8D6E63);
      case XpLeague.grinder:
        return const Color(0xFF7E57C2);
      case XpLeague.semiPro:
        return const Color(0xFF5E35B1);
      case XpLeague.shark:
        return const Color(0xFF00897B);
      case XpLeague.beast:
        return const Color(0xFFD32F2F);
      case XpLeague.pro:
        return const Color(0xFFFFB300);
      case XpLeague.endBoss:
        return const Color(0xFF37474F);
      case XpLeague.legend:
        return const Color(0xFF6A1B9A);
    }
  }
}

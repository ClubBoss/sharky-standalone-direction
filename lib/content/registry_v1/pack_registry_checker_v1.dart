/// Passive checker for pack registry v1.
class PackRegistryCheckerV1 {
  const PackRegistryCheckerV1(this.registryMap);

  final Map<String, Object> registryMap;

  Map<String, Object> analyze() {
    final dynamic modules = registryMap['modules'];
    final List<String> moduleList = modules is List
        ? modules.whereType<String>().toList()
        : <String>[];
    const List<String> required = <String>[
      'cash:l3:v1',
      'icm:l4:v1',
      'mtt:l4:v1',
      'turn:chain:v1',
      'exploit:builder:v1',
      't2e:v1',
      'mix:cp:v1',
      'ra2:v1',
      'synthesis:v1',
    ];
    final bool hasAllModules = required.every(moduleList.contains);
    final bool uniqueModules = moduleList.toSet().length == moduleList.length;
    final Set<String> prefixes = <String>{
      'cash',
      'icm',
      'mtt',
      'turn',
      'exploit',
      't2e',
      'mix',
      'ra2',
      'synthesis',
    };
    final bool validPrefixes = moduleList.every(
      (m) => prefixes.contains(m.split(':').first),
    );
    final bool allValid = hasAllModules && uniqueModules && validPrefixes;
    return <String, Object>{
      'has_all_modules': hasAllModules,
      'unique_modules': uniqueModules,
      'valid_prefixes': validPrefixes,
      'all_valid': allValid,
    };
  }
}

/// Newly authored choices in Y5b. Legacy identity checks keep their original
/// fingerprints and check these rows against their own authoring contract.
const y5bNewChoicesV1 = <String, List<List<Object?>>>{
  'w4_protection_guided_raise_read': [
    ['choice_0', 'Weaker kings', false, 'wrong', 'Sets'],
    ['choice_1', 'Sets', true, 'correct', 'Sets'],
    ['choice_2', 'Weak hands with no pair', false, 'wrong', 'Sets'],
  ],
  'w4_protection_short_shove_price': [
    ['fold', 'Fold', false, 'wrong', 'Call'],
    ['choice_1', 'Both earn the same', false, 'wrong', 'Call'],
    ['call', 'Call', true, 'correct', 'Call'],
  ],
};

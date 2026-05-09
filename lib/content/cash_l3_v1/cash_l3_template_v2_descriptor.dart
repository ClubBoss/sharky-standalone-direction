/// Passive descriptor for Cash L3 Template V2.
class CashL3TemplateV2Descriptor {
  const CashL3TemplateV2Descriptor();

  Map<String, Object> asReadOnlyMap() {
    return <String, Object>{
      'id': 'cash:l3:v2',
      'source': 'cash:l3:v1',
      'template': 'training_pack_template_v2',
      'status': 'skeleton',
      'paths': <String, String>{
        'theory': 'content/cash/l3/theory.md',
        'drills': 'content/cash/l3/drills.jsonl',
        'demos': 'content/cash/l3/demos.jsonl',
        'allowlist': 'content/cash/l3/allowlist.txt',
      },
    };
  }
}

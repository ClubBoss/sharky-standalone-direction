class TableV4QASeverityLegendV1 {
  const TableV4QASeverityLegendV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'error': <String, String>{
        'color': '#FFFF0000',
        'description': 'Critical issues requiring immediate attention.',
      },
      'warning': <String, String>{
        'color': '#FFFFFF00',
        'description': 'Warnings that should be reviewed soon.',
      },
      'info': <String, String>{
        'color': '#FF00FFFF',
        'description': 'Informational messages for visibility.',
      },
    };
  }
}

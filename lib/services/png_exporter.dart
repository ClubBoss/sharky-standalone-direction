import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        PipelineOwner,
        RenderBox,
        RenderPositionedBox,
        RenderRepaintBoundary,
        RenderView,
        ViewConfiguration;
import '../models/v2/training_pack_template.dart';
import '../models/v2/hero_position.dart';
import '../widgets/hero_range_grid_widget.dart';

class PngExporter {
  static Future<Uint8List?> _capture(Widget child) async {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView!;
    final boundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration.fromView(view),
      child: RenderPositionedBox(alignment: Alignment.center, child: boundary),
    );
    final pipelineOwner = PipelineOwner();
    renderView.attach(pipelineOwner);
    renderView.prepareInitialFrame();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    final adapter = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: MaterialApp(home: child),
    );
    final rootElement = adapter.attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    final image = await boundary.toImage(pixelRatio: view.devicePixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  static Future<Uint8List?> exportWidget(Widget child) => _capture(child);

  static Future<Uint8List?> exportSpot(Widget spot, {required String label}) =>
      _capture(
        Stack(
          children: [
            spot,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );

  static Future<Uint8List?> exportTemplatePreview(
    TrainingPackTemplate template,
  ) => _capture(_TemplatePreview(template));

  static Future<Uint8List?> captureBoundary(
    RenderRepaintBoundary boundary,
  ) async {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView!;
    final image = await boundary.toImage(pixelRatio: view.devicePixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  static Future<Uint8List> imagesToPdf(List<Uint8List> images) async {
    final pdf = pw.Document();
    for (final img in images) {
      final mem = pw.MemoryImage(img);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(child: pw.Image(mem)),
        ),
      );
    }
    return pdf.save();
  }
}

class _TemplatePreview extends StatelessWidget {
  final TrainingPackTemplate template;
  const _TemplatePreview(this.template);

  static const _ranks = [
    'A',
    'K',
    'Q',
    'J',
    'T',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
  ];

  List<List<double>> _matrix() {
    final idx = {for (var i = 0; i < _ranks.length; i++) _ranks[i]: i};
    final m = [for (var i = 0; i < 13; i++) List.filled(13, 0.0)];
    for (final h in template.heroRange ?? []) {
      if ((h.length as int) < 2) continue;
      final r1 = h[0];
      final r2 = h[1];
      final i1Raw = idx[r1];
      final i2Raw = idx[r2];
      final shouldSkip = (i1Raw == null || i2Raw == null);
      if (shouldSkip) continue;
      final i1 = i1Raw;
      final i2 = i2Raw;
      if (h.length == 2 || r1 == r2) {
        m[i1][i2] = 1;
      } else if ((h.endsWith('s')) == true) {
        final row = i1 < i2 ? i1 : i2;
        final col = i1 < i2 ? i2 : i1;
        m[row][col] = 1;
      } else {
        final row = i1 > i2 ? i1 : i2;
        final col = i1 > i2 ? i2 : i1;
        m[row][col] = 1;
      }
    }
    return m;
  }

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    padding: const EdgeInsets.all(16),
    child: DefaultTextStyle(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('ID: ${template.id}'),
              Text('Spots: ${template.spots.length}'),
              Text('Position: ${template.heroPos.label}'),
              Text('Stack: ${template.heroBbStack} BB'),
            ],
          ),
          const SizedBox(width: 16),
          HeroRangeGridWidget(rangeMatrix: _matrix()),
        ],
      ),
    ),
  );
}

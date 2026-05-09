import 'dart:convert';
import 'dart:io';

dynamic _readJson(String p) {
  try {
    return json.decode(File(p).readAsStringSync());
  } catch (_) {
    return null;
  }
}

String _s(Object? x) => x is String ? x : (x ?? '').toString();

void main() {
  final lf = _readJson('build/ui_assets/lesson_flow.json') as Map? ?? {};
  final badges = _readJson('build/ui_assets/badges.json') as Map? ?? {};
  final see = _readJson('build/ui_assets/see_also.json') as Map? ?? {};
  final en = _readJson('build/ui_assets/i18n/en.json') as Map? ?? {};
  final ru = _readJson('build/ui_assets/i18n/ru.json') as Map? ?? {};

  // badges -> status map
  final br = (badges['rows'] as List?) ?? const [];
  final statusById = <String, String>{};
  for (final r in br) {
    final id = _s((r as Map)['module']);
    final st = _s(r['status']);
    if (id.isNotEmpty && st.isNotEmpty) statusById[id] = st;
  }

  // see_also -> map
  final seeMap = <String, List<String>>{};
  if (see['rows'] is List) {
    for (final r in (see['rows'] as List)) {
      final m = _s((r as Map)['module']);
      final top =
          (r['top'] as List?)?.map(_s).where((e) => e.isNotEmpty).toList() ??
          const <String>[];
      if (m.isNotEmpty) seeMap[m] = top.take(5).toList();
    }
  } else {
    for (final e in see.entries) {
      if (e.value is List) {
        seeMap[_s(e.key)] = (e.value as List)
            .map(_s)
            .where((x) => x.isNotEmpty)
            .take(5)
            .toList();
      }
    }
  }

  // build modules[]
  final rows = (lf['rows'] as List?) ?? const [];
  final legacy = (lf['modules'] as List?) ?? const [];
  final modules = <Map<String, Object>>[];

  if (rows.isNotEmpty) {
    for (final r in rows) {
      final m = _s((r as Map)['module']);
      if (m.isEmpty) continue;
      final st = _s(r['status']).isNotEmpty
          ? _s(r['status'])
          : (statusById[m] ?? 'unlockable');
      final sa =
          (r['see_also'] as List?)?.map(_s).toList() ??
          seeMap[m] ??
          const <String>[];
      modules.add({'id': m, 'status': st, 'seeAlso': sa});
    }
  } else if (legacy.isNotEmpty) {
    for (final r in legacy) {
      final m = _s((r as Map)['module'] ?? r['id']);
      if (m.isEmpty) continue;
      final st = statusById[m] ?? 'unlockable';
      modules.add({
        'id': m,
        'status': st,
        'seeAlso': seeMap[m] ?? const <String>[],
      });
    }
  } else {
    for (final id in statusById.keys) {
      modules.add({
        'id': id,
        'status': statusById[id]!,
        'seeAlso': seeMap[id] ?? const <String>[],
      });
    }
  }

  modules.sort((a, b) => _s(a['id']).compareTo(_s(b['id'])));

  // initial selection
  var initial = _s(((lf['summary'] as Map?)?['next']));
  if (initial.isEmpty || !modules.any((m) => m['id'] == initial)) {
    initial = modules.isNotEmpty ? _s(modules.first['id']) : '';
  }

  final html = StringBuffer()
    ..writeln('<!doctype html>')
    ..writeln('<meta charset="utf-8">')
    ..writeln('<title>UI Preview</title>')
    ..writeln(
      '<style>body{font-family:system-ui,Arial,sans-serif;margin:0}'
      'header{display:flex;justify-content:space-between;align-items:center;padding:8px 12px;border-bottom:1px solid #ddd}'
      '.lang-toggle button{margin-left:6px}'
      '.container{display:flex;height:calc(100vh - 48px)}'
      '.left{width:300px;border-right:1px solid #eee;overflow:auto}'
      '.right{flex:1;overflow:auto;padding:12px}'
      '.module{padding:8px 10px;border-bottom:1px solid #f0f0f0;cursor:pointer;display:flex;justify-content:space-between;align-items:center}'
      '.module.selected{background:#eef5ff}'
      '.module:hover{background:#fafafa}'
      '.chip{font-size:11px;padding:2px 6px;border-radius:10px;border:1px solid #ccc}'
      '.chip.done{background:#e0e0e0;border-color:#c8c8c8}'
      '.chip.unlockable{background:#ffe9b3;border-color:#f0d48a}'
      '.chip.next{background:#d3e5ff;border-color:#a8ccff}'
      '.chip.locked{background:#fff;border-color:#ddd}'
      '.tabs{display:flex;border-bottom:1px solid #eee;margin-bottom:8px}'
      '.tab{padding:8px 10px;cursor:pointer}'
      '.tab.active{border-bottom:2px solid #333;font-weight:bold}'
      '.see-also{margin-top:12px}.see-also li{margin-left:18px}'
      '.footer{position:fixed;right:8px;bottom:6px;background:#fff;color:#333;border:1px solid #ddd;border-radius:4px;padding:4px 6px;font-size:11px;opacity:.9}'
      'body.dark{background:#111;color:#e6e6e6}'
      'body.dark header{border-color:#333}'
      'body.dark .left{border-color:#333}'
      'body.dark .module{border-color:#2a2a2a}'
      'body.dark .module:hover{background:#1b1b1b}'
      'body.dark .module.selected{background:#162235}'
      'body.dark .chip{border-color:#555;color:#eee;background:#222}'
      'body.dark .chip.done{background:#333;border-color:#555}'
      'body.dark .chip.unlockable{background:#4a3f23;border-color:#6b541f}'
      'body.dark .chip.next{background:#1e3a5f;border-color:#2b5a8a}'
      'body.dark .chip.locked{background:#111;border-color:#444}'
      'body.dark .tabs{border-color:#333}'
      'body.dark .tab.active{border-color:#bbb}'
      'body.dark .footer{background:#1a1a1a;color:#ddd;border-color:#444}'
      '</style>',
    )
    ..writeln(
      '<header><div><strong>UI Preview</strong></div>'
      '<div class="lang-toggle"><span>Lang:</span> '
      '<button id="lang-en"></button><button id="lang-ru"></button></div></header>',
    )
    ..writeln(
      '<div class="container"><div class="left"><div style="padding:8px;border-bottom:1px solid #eee">'
      '<div id="counters" style="font-size:12px;margin-bottom:6px"></div>'
      '<div id="filters" style="margin-bottom:6px;font-size:12px">'
      '<button data-f="all">All</button> '
      '<button data-f="done">Done</button> '
      '<button data-f="unlockable">Unlockable</button> '
      '<button data-f="next">Next</button> '
      '<button data-f="locked">Locked</button>'
      '</div>'
      '<input id="search" type="text" placeholder="Search" style="width:100%;padding:6px 8px;border:1px solid #ccc;border-radius:4px;" />'
      '</div><div id="list"></div></div>'
      '<div class="right"><div class="tabs" id="tabs"></div><div id="kpi" style="margin:6px 0;font-size:12px"></div><div id="kpi" style="margin:6px 0;font-size:12px"></div><div id="content"></div></div></div>',
    )
    ..writeln(
      '<script type="application/json" id="modules">${jsonEncode(modules)}</script>',
    )
    ..writeln(
      '<script type="application/json" id="i18n">${jsonEncode({'en': en, 'ru': ru})}</script>',
    )
    ..writeln('<script>')
    ..writeln("window.addEventListener('DOMContentLoaded', function(){")
    ..writeln('  function g(id){return document.getElementById(id);}')
    ..writeln('  var modules = JSON.parse(g("modules").textContent);')
    ..writeln(
      '  var i18n = JSON.parse(g("i18n").textContent); console.info("PREVIEW BOOT", Date.now());',
    )
    ..writeln("  var lang='en';")
    ..writeln("  function t(k){return (i18n[lang]&&i18n[lang][k])||k;}")
    ..writeln("  g('lang-en').textContent='EN'; g('lang-ru').textContent='RU';")
    ..writeln(
      "  g('lang-en').onclick=function(){lang='en'; renderAll(state.sel);} ;",
    )
    ..writeln(
      "  g('lang-ru').onclick=function(){lang='ru'; renderAll(state.sel);} ;",
    )
    ..writeln('  var state={sel:"",tab:"theory",q:"",f:"all"};')
    ..writeln(
      '  function applyFilter(arr){ if(state.f==="all") return arr; return arr.filter(function(m){ return m.status===state.f; }); }',
    )
    ..writeln(
      '  function counts(arr){var c={done:0,unlockable:0,next:0,locked:0};arr.forEach(function(m){if(c[m.status]!==undefined)c[m.status]++;});return c;}',
    )
    ..writeln(
      '  function highlight(id, q){ if(!q) return id; var i=id.toLowerCase().indexOf(q.toLowerCase()); if(i<0) return id; return id.substring(0,i)+"<mark>"+id.substring(i,i+q.length)+"</mark>"+id.substring(i+q.length);}',
    )
    ..writeln('  function renderList(sel){')
    ..writeln("    var list=g('list'); list.innerHTML='';")
    ..writeln(
      '    var arrAll = modules.filter(function(m){ return !state.q || m.id.toLowerCase().indexOf(state.q.toLowerCase())>=0; });',
    )
    ..writeln('    var arr = applyFilter(arrAll);')
    ..writeln(
      '    var cnt = counts[arrAll]; var results = arr.length+"/"+modules.length; g("counters").textContent = "Done "+cnt.done+" • Unlockable "+cnt.unlockable+" • Next "+cnt.next+" • Locked "+cnt.locked+" — Results: "+results;',
    )
    ..writeln('    arr.forEach(function(m){')
    ..writeln(
      "      var d=document.createElement('div'); d.className='module'+(m.id===sel?' selected':'');",
    )
    ..writeln(
      "      var a=document.createElement('div'); a.innerHTML=highlight(m.id, state.q);",
    )
    ..writeln(
      "      var c=document.createElement('div'); c.className='chip '+m.status; c.textContent=[]||m.status;",
    )
    ..writeln('      d.appendChild(a); d.appendChild(c);')
    ..writeln(
      '      d.onclick=function(){ history.replaceState(null,"", "#"+m.id+"/"+state.tab+paramsToHash()); renderAll(m.id, state.tab); };',
    )
    ..writeln(
      "    var selEl=document.querySelector('.module.selected'); if(selEl){ try{selEl.scrollIntoView({block:'nearest'});}catch(e){} }",
    )
    ..writeln('      list.appendChild(d);')
    ..writeln('    });')
    ..writeln('    list.tabIndex=0;')
    ..writeln(
      "    list.onkeydown=function(ev){var arr = applyFilter(modules.filter(function(m){ return !state.q || m.id.toLowerCase().indexOf(state.q.toLowerCase())>=0; }));var idx=arr.findIndex(function(x){return x.id===state.sel}); if(ev.key==='ArrowDown'||ev.key==='j'){idx=Math.min(arr.length-1, idx+1);} else if(ev.key==='ArrowUp'||ev.key==='k'){idx=Math.max(0, idx-1);} else if(ev.key==='Home'){idx=0;} else if(ev.key==='End'){idx=arr.length-1;} else if(ev.key==='Enter'){ history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); return; } else { return; } state.sel = arr[idx] ? arr[idx].id : state.sel; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); ev.preventDefault(); }",
    )
    ..writeln('  }')
    ..writeln("  function renderTabs(){ var tabs=g('tabs'); tabs.innerHTML='';")
    ..writeln(
      "    var keys=['labels.theory','labels.demos','labels.drills']; var ids=['theory','demo','drill'];",
    )
    ..writeln(
      "    keys.forEach(function(key,idx){ var tb=document.createElement('div'); tb.className='tab'+(ids[idx]==state.tab?' active':''); tb.textContent=t[key]; tb.onclick=function(){ state.tab=ids[idx]; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); }; tabs.appendChild(tb); }); }",
    )
    ..writeln(
      "  function renderContent(kind){ var c=g('content'); c.innerHTML='';",
    )
    ..writeln(
      '    try { var k=document.getElementById("kpi"); var rp=${jsonEncode(_readJson('build/ui_assets/review_plan.json') as Map? ?? {})}; var e=null; if(rp && rp.modules){ e=rp.modules[state.sel]; } if(!e){ if(k) k.innerHTML=""; } else { var tok=[]?e.tokens_total:"-"; var s=[]?e.spot_kinds_total:"-"; var iv=[]?e.intervals.join(","):"-"; var ans=[]?e.answered:"-"; var cor=[]?e.correct:"-"; var mp=[]?e.missed_probes:"-"; var fe=[]?e.family_errors:"-"; if(k) k.innerHTML="Tokens: "+tok+" • Spot kinds: "+s+" • Intervals: "+iv+"<br>Answered: "+ans+" • Correct: "+cor+" • Missed probes: "+mp+" • Family errors: "+fe; } } catch(_) { }',
    )
    ..writeln(
      "    var h=document.createElement('div'); h.textContent='Module: '+state.sel+' — '+t['nav.see_also'];",
    )
    ..writeln(
      "    var ul=document.createElement('ul'); ul.className='see-also';",
    )
    ..writeln(
      '    var m = modules.find(function(x){return x.id===state.sel;});',
    )
    ..writeln(
      '    (m && m.seeAlso || []).forEach(function(s){ var li=document.createElement("li"); li.textContent=s; li.style.cursor="pointer"; li.onclick=function(){ location.hash="#"+s; renderAll(s); }; ul.appendChild(li); });',
    )
    ..writeln('    c.appendChild(h); c.appendChild(ul); }')
    ..writeln(
      '  function paramsToHash(){ var p=[]; if(state.q) p.push("q="+encodeURIComponent(state.q)); if(state.f&&state.f!==\'all\') p.push("f="+encodeURIComponent(state.f)); return p.length?"?"+p.join("&"):""; }',
    )
    ..writeln(
      "  function parseHash(){ var h=[]?location.hash.substring(1):''; var parts=h.split('?'); var main=parts[0]; var qp=[]; var id=main.split('/')[0]; var tab=main.split('/')[1]||'theory'; var q=''; var f='all'; qp.split('&').forEach(function(kv){ var kvp=kv.split('='); if(kvp[0]==='q') q=decodeURIComponent(kvp[1]||''); if(kvp[0]==='f') f=decodeURIComponent(kvp[1]||''); }); return {id:id, tab:tab, q:q, f:f}; }",
    )
    ..writeln(
      '  function renderAll(id, tab){ state.sel=id; if(tab) state.tab=tab; renderList(id); renderTabs(); renderContent(state.tab); }',
    )
    ..writeln(
      '  var init = parseHash(); var initialId = init.id || ${jsonEncode(initial)}; var initialTab = init.tab; state.q=init.q||""; state.f=init.f||"all";',
    )
    ..writeln('')
    ..writeln('  renderAll(initialId, initialTab);')
    ..writeln(
      "  var search=g('search'); search.placeholder=[]||'Search'; search.value=state.q; search.oninput=function(){ state.q=this.value||''; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderList(state.sel); }; document.addEventListener('keydown', function(e){ if(e.key=='/'){ e.preventDefault(); search.focus(); } else if(e.key==='Escape'){ state.q=''; search.value=''; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderList(state.sel); } else if(e.key==='1'){ state.tab='theory'; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); } else if(e.key==='2'){ state.tab='demo'; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); } else if(e.key==='3'){ state.tab='drill'; history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderAll(state.sel,state.tab); } });",
    )
    ..writeln(
      "  var filt=g('filters'); Array.prototype.forEach.call(filt.querySelectorAll('button'), function(b){ if(b.getAttribute('data-f')===state.f) b.style.fontWeight='bold'; b.onclick=function(){ Array.prototype.forEach.call(filt.querySelectorAll('button'), function(bb){bb.style.fontWeight='normal';}); this.style.fontWeight='bold'; state.f=this.getAttribute('data-f'); history.replaceState(null,'', '#'+state.sel+'/'+state.tab+paramsToHash()); renderList(state.sel); }; });",
    )
    ..writeln('});')
    ..writeln('</script>');
  // Footer: bundle stats from manifest.json[best-effort]
  Map<String, dynamic> manifest = {};
  try {
    final mf = File('build/ui_assets/manifest.json');
    if (mf.existsSync()) {
      final data = jsonDecode(mf.readAsStringSync());
      if (data is Map) manifest = data.cast<String, dynamic>();
    }
  } catch (_) {}
  String getNum(Map m, String k) {
    final v = m[k];
    if (v is num) return v.toInt().toString();
    return '-';
  }

  final sizesG = (manifest['total_bytes_gzip'] is num)
      ? (manifest['total_bytes_gzip'] as num).toInt().toString()
      : '-';
  final counts = (manifest['counts'] is Map)
      ? (manifest['counts'] as Map).cast<String, dynamic>()
      : <String, dynamic>{};
  final filesCount = (manifest['files'] is List)
      ? (manifest['files'] as List).length
      : (manifest['files_count'] is num
            ? (manifest['files_count'] as num).toInt()
            : 0);
  final generatedAt = getNum(manifest, 'generated_at');
  final footer =
      'Bundle: files=${filesCount == 0 ? '-' : filesCount} • bytes=${getNum(manifest, 'total_bytes')} • gzip=$sizesG • modules=${getNum(counts, 'modules')} • tokens=${getNum(counts, 'tokens')} • spot_kinds=${getNum(counts, 'spot_kinds')} • i18n=${getNum(counts, 'i18n_keys')} • telemetry=${getNum(counts, 'telemetry_events')} • generated_at=$generatedAt';
  html.writeln('<div class="footer">${_esc(footer)}</div>');

  Directory('build').createSync(recursive: true);
  const out = 'build/ui_preview.html';
  File(out).writeAsStringSync(html.toString());
  stdout.writeln('UI-PREVIEW out=$out modules=${modules.length} lang=en');
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

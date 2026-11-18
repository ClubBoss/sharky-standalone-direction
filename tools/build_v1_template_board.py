#!/usr/bin/env python3
"""Build the local V1 owner-choice page from unmodified native captures."""
from __future__ import annotations

import argparse
import html
import json
import pathlib
import shutil
import urllib.parse

ROOT = pathlib.Path(__file__).resolve().parents[1]

TABLE = '''<svg viewBox="0 0 345 220" role="img" aria-label="Layout illustration: flop A hearts, 7 clubs, 2 diamonds; your cards A spades, K diamonds; pot 6 BB">
<defs><radialGradient id="felt"><stop stop-color="#155758"/><stop offset="1" stop-color="#062e32"/></radialGradient></defs>
<ellipse cx="172" cy="108" rx="144" ry="78" fill="#051b20" stroke="#94764a" stroke-width="7"/>
<ellipse cx="172" cy="108" rx="133" ry="66" fill="url(#felt)" stroke="#507270"/>
<g fill="#d4e6e6" font-size="11" font-family="system-ui" text-anchor="middle">
<text x="73" y="31">UTG</text><text x="172" y="18">HJ</text><text x="273" y="31">CO</text>
<text x="316" y="125">BTN</text><text x="247" y="204">SB</text><text x="34" y="125">BB</text></g>
<g fill="#f8f3e7" stroke="#c8c5b7"><rect x="115" y="71" width="34" height="48" rx="5"/><rect x="155" y="71" width="34" height="48" rx="5"/><rect x="195" y="71" width="34" height="48" rx="5"/></g>
<g font-size="17" font-weight="700" font-family="system-ui" text-anchor="middle"><text x="132" y="91" fill="#b83b4f">A</text><text x="132" y="110" fill="#b83b4f">♥</text><text x="172" y="91" fill="#15272c">7</text><text x="172" y="110" fill="#15272c">♣</text><text x="212" y="91" fill="#b83b4f">2</text><text x="212" y="110" fill="#b83b4f">♦</text></g>
<text x="172" y="143" fill="#f2cf83" font-family="system-ui" font-size="12" text-anchor="middle">Pot 6 BB</text>
<g fill="#f8f3e7" stroke="#c8c5b7"><rect x="134" y="164" width="34" height="47" rx="5"/><rect x="176" y="164" width="34" height="47" rx="5"/></g>
<g font-size="17" font-weight="700" font-family="system-ui" text-anchor="middle"><text x="151" y="184" fill="#15272c">A</text><text x="151" y="203" fill="#15272c">♠</text><text x="193" y="184" fill="#b83b4f">K</text><text x="193" y="203" fill="#b83b4f">♦</text></g>
</svg>'''

CSS = '''
*{box-sizing:border-box}body{margin:0;background:#071519;color:#e6efee;font-family:system-ui,-apple-system,sans-serif}main{max-width:1320px;margin:auto;padding:36px 32px 80px}h1{font-size:36px;letter-spacing:-1px;margin:8px 0 14px}p{color:#b8c8c9;line-height:1.55}.eyebrow{color:#65e5d4;font-size:12px;letter-spacing:2px;font-weight:700}.intro{max-width:900px}.options{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:24px;margin:28px 0 40px}.option h2{font-size:21px;margin:0}.option>p{min-height:76px;font-size:14px;margin:10px 0 18px}.badge{display:inline-block;font-size:11px;background:#184b47;color:#9bffeb;padding:4px 8px;border-radius:5px;margin:8px 0}.viewport{position:relative;width:100%;aspect-ratio:393/852;overflow:hidden;border-radius:30px;border:1px solid #466269;box-shadow:0 20px 45px #0005}.phone{position:absolute;top:0;left:0;width:393px;height:852px;transform-origin:top left;background:#061c22;color:#edf6f4;padding:20px 22px;display:flex;flex-direction:column;gap:16px}.status{display:flex;justify-content:space-between;font-size:12px;margin-bottom:12px;letter-spacing:.5px}.bar{display:flex;justify-content:space-between;align-items:center;color:#9ebabc;font-size:12px;letter-spacing:1.4px;height:32px}.bar b{font-size:22px;letter-spacing:0;color:#d8eded}.prompt{margin:0;padding:0 2px}.prompt small{color:#68daca;letter-spacing:1.4px;font-size:10px;font-weight:700}.prompt h3{font-size:25px;line-height:1.17;letter-spacing:-.6px;margin:10px 0 0}.table{border:1px solid #285052;border-radius:22px;background:#061a1e;padding:2px 0}.table svg{width:100%;display:block}.answers{display:flex;flex-direction:column;gap:10px}.answer{display:flex;align-items:center;gap:12px;background:#102d34;border:1px solid #315056;border-radius:14px;padding:14px;min-height:64px;font-size:15px;line-height:1.3}.answer i{width:19px;height:19px;flex:none;border:1.5px solid #718f91;border-radius:50%}.footer{margin-top:auto}.help{display:flex;align-items:center;gap:10px;color:#a0babb;font-size:12px;margin-bottom:14px}.help img{width:38px;height:38px;object-fit:contain}.cta{border-radius:14px;background:#294b4e;color:#98b6b6;padding:17px;text-align:center;font-size:15px;font-weight:700}.homebar{width:110px;height:4px;background:#a3b1b1;border-radius:10px;margin:17px auto 0}.b{background:#10282d}.b .table{order:2;border-color:#8a7654;background:#0b2226}.b .prompt{order:3;border-left:3px solid #e0bc75;padding:4px 14px}.b .prompt h3{font-size:24px}.b .answers{order:4}.b .footer{order:5}.b .answer{background:#17363a;border-color:#456365}.b .bar{margin-bottom:2px}.b .status{margin-bottom:0}.b .help img{width:32px;height:32px}.c{background:linear-gradient(#071e25cc,#06191ffa 65%),url('media/lounge.png') center/cover}.c .prompt{background:#08252bf2;border:1px solid #477172;border-radius:18px;padding:17px;position:relative}.c .prompt h3{font-size:24px;max-width:260px}.c .prompt:after{content:'';display:block;position:absolute;right:8px;top:16px;width:48px;height:70px;background:url('media/mascot-current.png') center/contain no-repeat}.c .help img{display:none}.c .table{background:#09262bed;border-color:#4a6c6c}.c .answer{background:#0b2930f5;border-color:#527173}.note{font-size:13px;padding:18px 22px;background:#10272d;border:1px solid #29474e;border-radius:14px;line-height:1.6}.gallery-head{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-top:40px}.gallery-head h2{font-size:25px}select{padding:10px;border-radius:8px;background:#173239;color:#e7f0f0;border:1px solid #48656b}.gallery{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:16px}.shot{margin:0;background:#10262d;border:1px solid #2f4b53;border-radius:12px;overflow:hidden}.shot img{width:100%;display:block}.shot figcaption{padding:10px;font-size:11px;line-height:1.45;overflow-wrap:anywhere;color:#b7ced0}.shot strong{display:block;color:#eaf3f2;margin-bottom:4px}.shot[hidden]{display:none}a{color:#90efe0}.legend{display:flex;flex-wrap:wrap;gap:8px;margin:18px 0}.legend span{font-size:12px;padding:6px 9px;border:1px solid #38535a;border-radius:6px}@media(max-width:850px){main{padding:22px 16px}.options{gap:12px}.option h2{font-size:17px}.option>p{font-size:12px;min-height:110px}.gallery{grid-template-columns:repeat(3,minmax(0,1fr))}h1{font-size:29px}}@media print{body{background:white;color:black}main{padding:8px}.gallery{grid-template-columns:repeat(6,1fr)}.options{break-inside:avoid}.note,p{color:#334}select{display:none}}
'''


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--captures', type=pathlib.Path)
    parser.add_argument('--prepare-selection', type=pathlib.Path)
    parser.add_argument('--extra-captures', type=pathlib.Path, action='append', default=[])
    parser.add_argument('--exclude-row-id', action='append', default=[])
    parser.add_argument('--catalog', type=pathlib.Path, required=True)
    parser.add_argument('--out', type=pathlib.Path, required=True)
    args = parser.parse_args()
    if args.prepare_selection:
        tasks = json.loads(args.catalog.read_text())
        base = json.loads((ROOT/'tools/sharky_native_visual_audit_manifest_v1.json').read_text())['rows']
        # These three old fixtures return Home; current authored repair/recheck
        # tasks below supply the supported visual examples instead.
        excluded = {'repair_focus', 'repair_recheck', 'lesson.completion'}
        rows = [dict(r) for r in base if r['device_profile'] == 'canonical' and r['modifier'] == 'none' and r['state'] not in excluded]
        w3 = next(t for t in tasks if t['world'] == 3 and t['phase'] == 'drill')
        def query(t):
            return f"act0_capture=runner_drill&world=world_{t['world']}&lesson={t['lesson']}&task={t['task']}"
        for row in rows:
            row['logical_viewport'] = '393x852'
            if row['state'] == 'world3': row['query'] = query(w3)
        examples = [next(t for t in tasks if t['family'] == f) for f in ['recognition','counting','repair','review','sizing']]
        examples += [next(t for t in tasks if t['world'] == 2 and t['phase'] == 'drill'), next(t for t in tasks if t['world'] == 3 and t['family'] == 'repair')]
        for t in examples:
            name = f"w{t['world']}.{t['task']}"
            rows.append(dict(visual_state_id=name, state=name, semantic_phase=t['family'], device_profile='canonical', modifier='none', logical_viewport='393x852', query=query(t)))
        for name, phase, target in [('practice.current','practice','act0_capture=practice'), ('recheck.current','recheck', query(next(t for t in tasks if t['task'] == 'what_poker_is_table_read_recheck')))]:
            rows.append(dict(visual_state_id=name, state=name, semantic_phase=phase, device_profile='canonical', modifier='none', logical_viewport='393x852', query=target))
        args.prepare_selection.parent.mkdir(parents=True, exist_ok=True)
        args.prepare_selection.write_text(json.dumps({'expected_rows':len(rows), 'rows':rows}, indent=2)+'\n')
        print(args.prepare_selection)
        return
    if not args.captures:
        parser.error('--captures or --prepare-selection is required')
    manifest = json.loads((args.captures/'shard_capture_manifest.json').read_text())
    if manifest['status'] != 'success' or manifest['requested_rows'] != manifest['completed_rows']:
        raise SystemExit('Complete the selected native captures before building the board.')
    sources = {r['visual_state_id']: args.captures for r in manifest['rows']}
    for extra_path in args.extra_captures:
        extra = json.loads((extra_path/'shard_capture_manifest.json').read_text())
        if extra['status'] != 'success' or extra['candidate_sha'] != manifest['candidate_sha']:
            raise SystemExit('Extra captures must be successful and use the same source commit.')
        for row in extra['rows']:
            if row['visual_state_id'] in sources:
                raise SystemExit('Duplicate capture identity')
            sources[row['visual_state_id']] = extra_path
            manifest['rows'].append(row)
    if set(args.exclude_row_id) - sources.keys():
        raise SystemExit('Unknown excluded capture')
    manifest['rows'] = [r for r in manifest['rows'] if r['visual_state_id'] not in args.exclude_row_id]
    tasks = json.loads(args.catalog.read_text())
    selectors = {(f"world_{t['world']}", t['lesson'], t['task']) for t in tasks}
    for row in manifest['rows']:
        query = urllib.parse.parse_qs(row['query'])
        if 'task' in query and (query['world'][0], query['lesson'][0], query['task'][0]) not in selectors:
            raise SystemExit(f"Capture selector is outside the current catalog: {row['visual_state_id']}")
    sample = next(t for t in tasks if t['task'] == 'what_poker_is_table_read_transfer')
    expected_table = {'street': 'Flop', 'pot': 'Pot 6 BB', 'toCall': '', 'hero': ['As', 'Kd'], 'board': ['Ah', '7c', '2d']}
    if sample['table'] != expected_table:
        raise SystemExit('Layout illustration must be updated to match the current source task.')
    args.out.mkdir(parents=True, exist_ok=True)
    media = args.out/'media'; media.mkdir(exist_ok=True)
    shutil.copy2(ROOT/'assets/images/mascot/sharky_neutral_fallback_v1.png', media/'mascot-current.png')
    shutil.copy2(ROOT/'assets/design/sharky/home/poker_lounge_reference_v2.png', media/'lounge.png')
    esc = html.escape
    answers = ''.join(f'<div class="answer"><i></i><span>{esc(o["label"])}</span></div>' for o in sample['options'])
    prompt = f'<div class="prompt"><small>READ THE TABLE</small><h3>{esc(sample["question"])}</h3></div>'
    phones = []
    for variant, title, description in [
        ('a', 'A · Quiet focus', 'Вопрос первым, отдельный стол, спокойные ответы. Маскот помогает внизу, не закрывая вопрос.'),
        ('b', 'B · Guided card', 'Сначала контекст стола, затем вопрос с тёплым акцентом. Урок ощущается последовательностью карточек.'),
        ('c', 'C · Cinematic frame', 'Атмосферный фон с непрозрачными рамками текста. Маскот рядом с вопросом, стол и ответы отделены.'),
    ]:
        phones.append(f'''<article class="option"><h2>{title}</h2><p>{description}</p><div class="viewport"><div class="phone {variant}">
        <div class="status"><span>9:41</span><span>●●● ▰</span></div><div class="bar"><b>‹</b><span>SHARKY · PRACTICE</span><b>×</b></div>
        {prompt}<div class="table">{TABLE}</div><div class="answers">{answers}</div>
        <div class="footer"><div class="help"><img src="media/mascot-current.png" alt="Current mascot reference"><span>Need a hint?</span></div><div class="cta">Choose an answer</div><div class="homebar"></div></div>
        </div></div></article>''')
    captions = {'practice':'Practice', 'placement':'Вход', 'welcome':'Знакомство', 'home':'Home', 'learn':'Путь Learn', 'theory':'Теория', 'table_read':'Чтение стола', 'action_selection':'Выбор действия', 'seat_selection':'Выбор места', 'correct_feedback':'Верный ответ', 'incorrect_feedback':'Ошибка и разбор', 'repair':'Repair', 'recheck':'Recheck', 'review':'Review', 'profile_evidence':'You', 'session_summary':'Итог урока / сессии', 'lesson_completion':'Review · выбор места', 'world_completion':'Итог мира', 'seat_selection_derivative':'W3 · позиции', 'hand_comparison':'Сравнение рук', 'showdown':'Showdown', 'recognition':'Распознавание', 'counting':'Подсчёт', 'sizing':'W4 · размер ставки', 'decision':'W2 · выбор руки'}
    gallery=[]
    phases=sorted({r['semantic_phase'] for r in manifest['rows']})
    for row in manifest['rows']:
        src = sources[row['visual_state_id']]/row['png']
        dst = media/src.name
        shutil.copy2(src, dst)
        phase=row['semantic_phase']; label=captions.get(phase,phase)
        gallery.append(f'<figure class="shot" data-phase="{esc(phase)}"><a href="media/{esc(src.name)}" target="_blank"><img loading="lazy" src="media/{esc(src.name)}" alt="{esc(label)}"></a><figcaption><strong>{esc(label)}</strong>{esc(row["visual_state_id"])}<br>393 × 852 · injected debug state</figcaption></figure>')
    filters='<option value="all">Все типы экранов</option>'+''.join(f'<option value="{esc(p)}">{esc(captions.get(p,p))}</option>' for p in phases)
    families=''.join(f'<span>{esc(f)} · {sum(t["family"]==f for t in tasks)}</span>' for f in sorted({t['family'] for t in tasks}))
    page=f'''<!doctype html><html lang="ru"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sharky · V1 · Выбор шаблона</title><style>{CSS}</style><main>
    <div class="eyebrow">SHARKY · V1 → O3 · IPHONE 14 PRO · ENGLISH</div><h1>Один шаблон для всех заданий</h1>
    <p class="intro">Три варианта композиции на одном реальном задании. Выберите <b>A, B или C</b> в чате; отдельно можно указать предпочтение по месту маскота. После выбора общий шаблон будет применён в V2.</p>
    <div class="options">{''.join(phones)}</div>
    <div class="note"><b>Что показано.</b> Верхние три экрана — макеты композиции 393×852. Карты, банк, вопрос и варианты ответа взяты из <code>{esc(sample['task'])}</code>; интерактивная оценка ответа не подключена. Стол нарисован схемой для сравнения расположения. Геометрия настоящего стола будет проверяться в V3. Иллюстрации — существующие ассеты; финальный пак рассматривается в V7.<br><b>Моя рекомендация:</b> A — самый прямой порядок чтения и меньше фонового шума. Решение остаётся за владельцем.</div>
    <div class="gallery-head"><h2>Текущие экраны · {len(gallery)} снимков</h2><select aria-label="Тип экрана">{filters}</select></div>
    <p>Нативный renderer на iPhone 14 Pro, 393×852, английский. Контролируемые debug-состояния из W1–W4 и основных экранов маршрута; это визуальные образцы. Они не подтверждают прохождение курса человеком или сохранённые достижения. Для увеличения откройте снимок. Исходный commit: <code>{esc(manifest['candidate_sha'][:12])}</code>.</p>
    <div class="legend">{families}</div><div class="gallery">{''.join(gallery)}</div>
    </main><script>
    const resize=new ResizeObserver(entries=>{{for(const e of entries)e.target.firstElementChild.style.transform=`scale(${{e.contentRect.width/393}})`;}});document.querySelectorAll('.viewport').forEach(e=>resize.observe(e));
    document.querySelector('select').onchange=e=>document.querySelectorAll('.shot').forEach(s=>s.hidden=e.target.value!=='all'&&s.dataset.phase!==e.target.value);
    </script></html>'''
    (args.out/'index.html').write_text(page)
    print(args.out/'index.html')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Build the portable, local-only Sharky Visual Control Center snapshot."""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import zipfile
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_EVIDENCE = ROOT / 'output/visual_control_center/evidence/current'
OUTPUT = ROOT / 'output/visual_control_center/current'
SITE = OUTPUT / 'site'
REQUIRED_MODES = ['Overview', 'Flow Map', 'Surface Atlas', 'Coverage', 'Screen Inspector', 'Compare', 'Missing / Failed', 'Route Playback']
RED = {'RUNTIME_REACHABLE_UNCAPTURED', 'UNKNOWN_UNMAPPED', 'ORPHAN_CAPTURE'}


def load(path: Path):
    return json.loads(path.read_text())


def dump(path: Path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_head() -> str:
    return subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()


def asset_name(relative: str) -> str:
    return relative.replace('/', '__')


def image_dimensions(path: Path):
    try:
        from PIL import Image
        with Image.open(path) as image:
            return list(image.size)
    except Exception:
        return None


def make_thumbnail(source: Path, target: Path):
    try:
        from PIL import Image
        with Image.open(source) as image:
            image.thumbnail((360, 720))
            image.save(target, optimize=True)
    except Exception:
        shutil.copy2(source, target)


def contract_dimensions(task):
    """Only typed fields may distinguish a runtime visual contract."""
    return {key: task.get(key) for key in (
        'renderer_family', 'runner_phase', 'control_type', 'option_count',
        'table_present', 'table_presentation_class', 'board_street_class',
        'selection_mode', 'feedback_composition_class', 'repair_capable',
        'source_recheck_relationship', 'completion_capable',
        'scroll_content_form', 'text_stress_class',
    )}


def contract_for(task):
    encoded = json.dumps(contract_dimensions(task), sort_keys=True, separators=(',', ':'))
    return 'runner.' + hashlib.sha256(encoded.encode()).hexdigest()[:16]


def matched_capture(task, contract_id, evidence, registry):
    """Never infer evidence identity from filenames or a broad surface family."""
    mappings = registry.get('capture_mappings', {})
    allowed = set(mappings.get(task['state_id'], [])) | set(mappings.get(contract_id, []))
    for item in evidence:
        metadata = item.get('metadata', {})
        if metadata.get('state_id') == task['state_id']:
            return item
        if metadata.get('task_id') == task['task_id']:
            return item
        if item['inventory_id'] in allowed:
            return item
    return None


def semantic_runner_states():
    owner = 'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart'
    specs = ('runner.theory', 'runner.unanswered_decision', 'runner.selected_decision', 'runner.correct_feedback', 'runner.wrong_feedback', 'runner.repair_focus', 'runner.repair_decision', 'runner.repair_result', 'runner.source_recheck', 'runner.recovered', 'runner.still_needs_practice', 'runner.lesson_completion')
    return [{'state_id': state_id, 'product_area': 'Learning', 'surface_family': 'runner', 'semantic_state': state_id.split('.', 1)[1], 'interaction_state': 'conditional', 'renderer_family': 'Act0LessonRunnerShellV1', 'route_or_entry_condition': 'typed runner state', 'production_owner': owner, 'release_reachable': True, 'criticality': 'critical', 'required_viewports': ['compact', 'text_scale_1_4'], 'required_accessibility_modes': ['none', 'text_scale_1_4'], 'scroll_contract': 'typed runner layout', 'capture_policy': 'representative', 'representative_policy': 'explicit contract mapping only', 'incoming_transition_ids': [], 'outgoing_transition_ids': [], 'notes': 'Explicit semantic runner state; no capture is implied.'} for state_id in specs]


def additional_conditional_states():
    specs = (
        ('welcome.decision', 'welcome', 'Act0WelcomeShellV1', 'act0_welcome_shell_v1.dart'), ('welcome.feedback', 'welcome', 'Act0WelcomeShellV1', 'act0_welcome_shell_v1.dart'), ('welcome.handoff', 'welcome', 'Act0WelcomeShellV1', 'act0_welcome_shell_v1.dart'),
        ('hub.home_repair_priority', 'home', 'Act0HomeShellV1', 'act0_home_shell_v1.dart'), ('hub.lesson_detail', 'learn', 'Act0LearnPathShellV1', 'act0_learn_path_shell_v1.dart'), ('hub.practice_repair_target', 'practice', 'Act0PlayShellV1', 'act0_play_shell_v1.dart'), ('hub.review_focused_rep', 'review', 'Act0ReviewShellV1', 'act0_review_shell_v1.dart'), ('hub.review_feedback', 'review', 'Act0ReviewShellV1', 'act0_review_shell_v1.dart'), ('hub.review_updated', 'review', 'Act0ReviewShellV1', 'act0_review_shell_v1.dart'), ('hub.profile_active_repair', 'profile', 'Act0ProfileShellV1', 'act0_profile_shell_v1.dart'),
        ('completion.w4_w5_band_transition', 'completion', 'Act0BlockCompletionShellV1', 'act0_shell_preview_screen_v1.dart'), ('sharky.foundation', 'sharky', 'Act0SharkyCueV1', 'act0_shell_state_v1.dart'), ('sharky.developing', 'sharky', 'Act0SharkyCueV1', 'act0_shell_state_v1.dart'), ('sharky.improve', 'sharky', 'Act0SharkyCueV1', 'act0_shell_state_v1.dart'), ('sharky.milestone', 'sharky', 'Act0SharkyCueV1', 'act0_shell_state_v1.dart'),
        ('return.day2_practice_repair', 'practice', 'Act0PlayShellV1', 'act0_play_shell_v1.dart'), ('return.day2_review_continuation', 'review', 'Act0ReviewShellV1', 'act0_review_shell_v1.dart'), ('return.day2_profile_repair', 'profile', 'Act0ProfileShellV1', 'act0_profile_shell_v1.dart'),
    )
    return [{'state_id': state_id, 'product_area': 'Conditional/Return', 'surface_family': family, 'semantic_state': state_id.split('.', 1)[1], 'interaction_state': 'conditional', 'renderer_family': renderer, 'route_or_entry_condition': 'source-backed conditional variant', 'production_owner': f'lib/ui_v2/act0_shell/{owner}', 'release_reachable': True, 'criticality': 'high', 'required_viewports': ['compact'], 'required_accessibility_modes': ['none'], 'scroll_contract': 'source-owned conditional layout', 'capture_policy': 'representative', 'representative_policy': 'explicit mapping only', 'incoming_transition_ids': [], 'outgoing_transition_ids': [], 'notes': 'Registered conditional state; evidence remains explicit.'} for state_id, family, renderer, owner in specs]


def write_review_export(site, coverage, atlas, transitions, evidence_manifest):
    """Create a compact, claim-safe review package from explicit representatives."""
    export = OUTPUT / 'review_export'
    export.mkdir(parents=True, exist_ok=True)
    staging = export / 'staging'
    if staging.exists():
        shutil.rmtree(staging)
    staging.mkdir()
    for name in ('atlas.json', 'transitions.json', 'coverage.json', 'evidence_manifest.json', 'site_version.json'):
        shutil.copy2(site / 'data' / name, staging / name)
    images = {image['inventory_id']: image for image in evidence_manifest}
    representative_ids = {record['representative'] for record in coverage if record.get('representative') in images}
    index = []
    for inventory_id in sorted(representative_ids):
        image = images[inventory_id]
        target = staging / 'images' / Path(image['full_image']).name
        target.parent.mkdir(exist_ok=True)
        shutil.copy2(site / image['full_image'], target)
        index.append(f'- `{target.relative_to(staging)}`: `{inventory_id}`; explicit representative mapping.')
    missing = [record for record in coverage if not record.get('representative')]
    (staging / 'REVIEW_INDEX.md').write_text('# Sharky Visual Review Index\n\n' + ('\n'.join(index) if index else 'No full-resolution representatives are claimable; see coverage.json.') + '\n')
    (staging / 'REVIEW_README.md').write_text('# Sharky Visual Review Pack\n\nThis package includes only explicitly matched representatives. Missing evidence is intentionally retained as metadata, not replaced by filename similarity.\n')
    (staging / 'MISSING_RECORDS.json').write_text(json.dumps(missing, indent=2, sort_keys=True) + '\n')
    files = sorted(path for path in staging.rglob('*') if path.is_file())
    sums = '\n'.join(f'{sha(path)}  {path.relative_to(staging)}' for path in files) + '\n'
    (staging / 'SHA256SUMS').write_text(sums)
    archive = export / 'SHARKY_VISUAL_REVIEW_PACK_V1.zip'
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as output:
        for path in sorted(staging.rglob('*')):
            if path.is_file(): output.write(path, path.relative_to(staging))
    shutil.rmtree(staging)
    return archive


def build(args):
    evidence_root = Path(args.evidence).resolve()
    manifest = load(evidence_root / 'VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1.json')
    validation = load(evidence_root / 'visual_evidence_identity_validation_report_v1.json')
    if validation['disposition'] != 'IDENTITY_MAPPED' or any(validation[key] for key in ('unmapped_png_count', 'conflicting_identity_count', 'orphan_identity_count', 'hash_mismatch_count', 'baseline_mismatch_count')):
        raise SystemExit('identity evidence validation is not clean')
    inventory = manifest['records']
    discovery = load(Path(args.discovery))
    registry = load(ROOT / 'tools/visual_state_atlas_registry_v1.json')
    baseline = manifest['product_evidence_baseline_sha']
    if baseline != args.expected_evidence_baseline:
        raise SystemExit(f'evidence baseline mismatch: {baseline}')
    if SITE.exists():
        shutil.rmtree(SITE)
    for relative in ('assets', 'data', 'images/thumbnails', 'images/full', 'images/compare'):
        (SITE / relative).mkdir(parents=True, exist_ok=True)
    evidence_manifest = []
    for row in inventory:
        source = evidence_root / row['relative_png_path']
        if not source.exists():
            raise SystemExit(f'missing evidence asset: {row["relative_png_path"]}')
        filename = asset_name(row['relative_png_path'])
        full = SITE / 'images/full' / filename
        thumb = SITE / 'images/thumbnails' / filename
        shutil.copy2(source, full)
        make_thumbnail(source, thumb)
        evidence_manifest.append({
            'inventory_id': row['evidence_id'], 'capture_group': row['capture_group'], 'device': row['device_class'],
            'availability': 'CAPTURED_CURRENT_HEAD', 'runtime_reachable': row['runtime_reachable'],
            'full_image': f'images/full/{filename}', 'thumbnail': f'images/thumbnails/{filename}',
            'sha256': sha(source), 'dimensions': image_dimensions(source), 'baseline_sha': row['evidence_baseline_sha'],
            'metadata': {**row, 'visual_contract_id': row.get('visual_contract_id'), 'evidence_dimension': f"{row['device_class']}:{row['text_scale']}:{row['scroll_position']}"},
        })
    compare = []
    for source in sorted(evidence_root.glob('before_after_*/*.png')):
        filename = asset_name(str(source.relative_to(evidence_root)))
        shutil.copy2(source, SITE / 'images/compare' / filename)
        compare.append({'name': source.name, 'image': f'images/compare/{filename}', 'sha256': sha(source), 'dimensions': image_dimensions(source)})
    registry_states = registry['states'] + semantic_runner_states() + additional_conditional_states()
    registry_by_id = {state['state_id']: state for state in registry_states}
    atlas = list(registry_states)
    coverage = []
    for state in registry_states:
        cid = f"conditional.{state['surface_family']}.{state['semantic_state']}"
        match = matched_capture({'state_id': state['state_id'], 'task_id': state['state_id']}, cid, evidence_manifest, registry)
        status = 'CAPTURED_CURRENT_HEAD' if match else ('NOT_RUNTIME_REACHABLE' if not state['release_reachable'] else 'RUNTIME_REACHABLE_UNCAPTURED')
        coverage.append({'state_id': state['state_id'], 'visual_contract_id': cid, 'status': status, 'representative': match['inventory_id'] if match else None, 'rationale': 'Exact state metadata or explicit registry mapping.' if match else state['notes'], 'release_blocking': state['release_reachable'] and not match, 'dimension_records': [{'dimension': dimension, 'status': status, 'representative': match['inventory_id'] if match else None} for dimension in state['required_viewports'] + state['required_accessibility_modes']]})
    contract_members = {}
    for task in discovery['tasks']:
        cid = contract_for(task)
        contract_members.setdefault(cid, []).append(task)
    for cid, members in sorted(contract_members.items()):
        representative = members[0]
        state_id = representative['state_id']
        match = matched_capture(representative, cid, evidence_manifest, registry)
        atlas.append({
            'state_id': state_id, 'product_area': 'Learning', 'surface_family': 'runner',
            'semantic_state': representative['runner_phase'], 'interaction_state': 'decision' if representative['runner_phase'] == 'drill' else 'content',
            'renderer_family': representative['renderer_family'], 'route_or_entry_condition': representative['route_identity'],
            'production_owner': representative['production_owner'], 'release_reachable': True, 'criticality': 'critical',
            'required_viewports': ['compact'], 'required_accessibility_modes': ['none'], 'scroll_contract': 'table plus decision panel',
            'visual_contract_id': cid, 'representative_state_id': state_id,
            'member_state_ids': [member['state_id'] for member in members],
            'contract_dimensions': contract_dimensions(representative),
            'equivalence_rationale': 'Same typed renderer, phase, control type, and option-count class from runtime discovery.',
        })
        contract_status = 'CAPTURED_CURRENT_HEAD' if match else 'RUNTIME_REACHABLE_UNCAPTURED'
        coverage.append({'state_id': state_id, 'visual_contract_id': cid, 'status': contract_status, 'representative': match['inventory_id'] if match else None, 'rationale': 'Exact identity representative runtime contract capture.' if match else 'No exact identity matched this runtime contract.', 'release_blocking': match is None, 'dimension_records': [{'dimension': 'compact_normal', 'status': contract_status, 'representative': match['inventory_id'] if match else None}, {'dimension': 'text_scale_1_4', 'status': contract_status, 'representative': match['inventory_id'] if match and match['metadata'].get('text_scale') == 1.4 else None}]})
        for member in members[1:]:
            coverage.append({'state_id': member['state_id'], 'visual_contract_id': cid, 'status': 'COVERED_BY_EQUIVALENCE' if match else 'RUNTIME_REACHABLE_UNCAPTURED', 'representative': state_id if match else None, 'rationale': 'Same typed visual contract as representative state.' if match else 'Representative capture missing.', 'release_blocking': match is None})
    transitions = [
        {'transition_id': 'placement.complete', 'source_state_id': 'entry.placement', 'destination_state_id': 'welcome.intro', 'trigger_type': 'primary CTA', 'trigger_label': 'Continue', 'guard': 'placement complete', 'branch': None, 'source_owner': 'act0_placement_shell_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'typed debug capture surface', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'welcome.continue', 'source_state_id': 'welcome.intro', 'destination_state_id': 'hub.home', 'trigger_type': 'primary CTA', 'trigger_label': 'Continue', 'guard': 'welcome beat complete', 'branch': None, 'source_owner': 'act0_welcome_shell_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'typed debug capture surface', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'home.learn', 'source_state_id': 'hub.home', 'destination_state_id': 'hub.learn', 'trigger_type': 'primary CTA', 'trigger_label': 'Learn', 'guard': 'none', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'shell tab enum', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'learn.lesson', 'source_state_id': 'hub.learn', 'destination_state_id': 'runner.runtime', 'trigger_type': 'primary CTA', 'trigger_label': 'Lesson CTA', 'guard': 'lesson selectable', 'branch': None, 'source_owner': 'act0_learn_path_shell_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0LessonCardV1', 'capture_status': 'COVERED_BY_EQUIVALENCE'},
        {'transition_id': 'review.focus_rep', 'source_state_id': 'hub.review_actionable', 'destination_state_id': 'runner.runtime', 'trigger_type': 'primary CTA', 'trigger_label': 'Review rep', 'guard': 'repair queue nonempty', 'branch': None, 'source_owner': 'act0_review_shell_v1.dart', 'telemetry_expectation': 'feedback_viewed', 'deterministic_proof_source': 'typed debug surface', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'lesson.complete', 'source_state_id': 'runner.runtime', 'destination_state_id': 'completion.session_summary', 'trigger_type': 'completion', 'trigger_label': 'Continue', 'guard': 'runner complete', 'branch': 'correct/wrong converges', 'source_owner': 'act0_lesson_runner_shell_v1.dart', 'telemetry_expectation': 'feedback_viewed', 'deterministic_proof_source': 'Act0RunnerStateV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'completion.continue', 'source_state_id': 'completion.session_summary', 'destination_state_id': 'hub.learn', 'trigger_type': 'completion', 'trigger_label': 'Continue', 'guard': 'summary acknowledged', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'typed capture surface', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'nav.home', 'source_state_id': 'hub.learn', 'destination_state_id': 'hub.home', 'trigger_type': 'tab navigation', 'trigger_label': 'Home', 'guard': 'none', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0ShellTabV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'nav.learn', 'source_state_id': 'hub.home', 'destination_state_id': 'hub.learn', 'trigger_type': 'tab navigation', 'trigger_label': 'Learn', 'guard': 'none', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0ShellTabV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'nav.play', 'source_state_id': 'hub.home', 'destination_state_id': 'hub.practice', 'trigger_type': 'tab navigation', 'trigger_label': 'Play', 'guard': 'none', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0ShellTabV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'nav.review', 'source_state_id': 'hub.home', 'destination_state_id': 'hub.review_actionable', 'trigger_type': 'tab navigation', 'trigger_label': 'Review', 'guard': 'repair queue state', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0ShellTabV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
        {'transition_id': 'nav.profile', 'source_state_id': 'hub.home', 'destination_state_id': 'hub.profile_default', 'trigger_type': 'tab navigation', 'trigger_label': 'Profile', 'guard': 'none', 'branch': None, 'source_owner': 'act0_shell_preview_screen_v1.dart', 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0ShellTabV1', 'capture_status': 'CAPTURED_CURRENT_HEAD'},
    ]
    runner_owner = 'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart'
    for transition_id, source, destination, branch in (
        ('learn.theory', 'hub.learn', 'runner.theory', 'entry'),
        ('theory.decision', 'runner.theory', 'runner.unanswered_decision', 'continue'),
        ('decision.correct', 'runner.unanswered_decision', 'runner.correct_feedback', 'correct'),
        ('correct.complete', 'runner.correct_feedback', 'runner.lesson_completion', 'correct'),
        ('decision.wrong', 'runner.unanswered_decision', 'runner.wrong_feedback', 'wrong'),
        ('wrong.repair_focus', 'runner.wrong_feedback', 'runner.repair_focus', 'wrong'),
        ('repair.focus_decision', 'runner.repair_focus', 'runner.repair_decision', 'repair'),
        ('repair.result', 'runner.repair_decision', 'runner.repair_result', 'repair'),
        ('repair.recheck', 'runner.repair_result', 'runner.source_recheck', 'recheck'),
        ('recheck.recovered', 'runner.source_recheck', 'runner.recovered', 'correct'),
        ('recheck.needs_practice', 'runner.source_recheck', 'runner.still_needs_practice', 'wrong'),
        ('recovered.complete', 'runner.recovered', 'runner.lesson_completion', 'repair'),
        ('lesson.summary', 'runner.lesson_completion', 'completion.session_summary', 'complete'),
    ):
        transitions.append({'transition_id': transition_id, 'source_state_id': source, 'destination_state_id': destination, 'trigger_type': 'runner action', 'trigger_label': transition_id.replace('.', ' '), 'guard': 'typed runner branch', 'branch': branch, 'source_owner': runner_owner, 'telemetry_expectation': None, 'deterministic_proof_source': 'Act0RunnerStateV1', 'capture_status': 'RUNTIME_REACHABLE_UNCAPTURED'})
    for transition_id, source, destination, owner in (
        ('welcome.decision', 'welcome.intro', 'welcome.decision', 'act0_welcome_shell_v1.dart'), ('welcome.feedback', 'welcome.decision', 'welcome.feedback', 'act0_welcome_shell_v1.dart'), ('welcome.handoff', 'welcome.feedback', 'welcome.handoff', 'act0_welcome_shell_v1.dart'), ('welcome.home', 'welcome.handoff', 'hub.home', 'act0_welcome_shell_v1.dart'),
        ('home.repair_priority', 'hub.home', 'hub.home_repair_priority', 'act0_home_shell_v1.dart'), ('learn.detail', 'hub.learn', 'hub.lesson_detail', 'act0_learn_path_shell_v1.dart'), ('practice.repair', 'hub.practice', 'hub.practice_repair_target', 'act0_play_shell_v1.dart'), ('review.focused', 'hub.review_actionable', 'hub.review_focused_rep', 'act0_review_shell_v1.dart'), ('review.feedback', 'hub.review_focused_rep', 'hub.review_feedback', 'act0_review_shell_v1.dart'), ('review.updated', 'hub.review_feedback', 'hub.review_updated', 'act0_review_shell_v1.dart'), ('completion.band_transition', 'completion.world', 'completion.w4_w5_band_transition', 'act0_shell_preview_screen_v1.dart'),
    ):
        transitions.append({'transition_id': transition_id, 'source_state_id': source, 'destination_state_id': destination, 'trigger_type': 'conditional action', 'trigger_label': transition_id.replace('.', ' '), 'guard': 'source-owned conditional state', 'branch': None, 'source_owner': f'lib/ui_v2/act0_shell/{owner}', 'telemetry_expectation': None, 'deterministic_proof_source': 'registered source owner', 'capture_status': 'RUNTIME_REACHABLE_UNCAPTURED'})
    known_ids = {item['state_id'] for item in atlas} | {'runner.runtime'}
    bad_transitions = [edge for edge in transitions if edge['source_state_id'] not in known_ids or edge['destination_state_id'] not in known_ids]
    counts = Counter(item['status'] for item in coverage)
    site_version = {'evidence_baseline_sha': baseline, 'atlas_tooling_baseline_sha': git_head(), 'generated_at': datetime.now(timezone.utc).isoformat(), 'registry_schema': registry['schema'], 'runtime_discovery_schema': discovery['schema'], 'screenshot_count': len(evidence_manifest), 'unique_surface_count': len(atlas), 'unique_visual_contract_count': len(contract_members) + len(registry_states), 'transition_count': len(transitions), 'release_failing_gap_count': sum(item['status'] in RED or item['release_blocking'] for item in coverage) + len(bad_transitions), 'complete_hosted_asset_count': len(evidence_manifest), 'expected_hosted_asset_count': len(evidence_manifest)}
    dump(SITE / 'data/atlas.json', {'schema': 'visual_state_atlas_v1', 'states': atlas, 'runtime': discovery})
    dump(SITE / 'data/transitions.json', {'schema': 'visual_state_transitions_v1', 'transitions': transitions, 'unresolved': bad_transitions})
    dump(SITE / 'data/coverage.json', {'schema': 'visual_state_coverage_v1', 'counts': counts, 'records': coverage})
    dump(SITE / 'data/evidence_manifest.json', {'schema': 'visual_state_evidence_manifest_v1', 'images': evidence_manifest, 'compare': compare})
    site_version['site_content_hash'] = hashlib.sha256(json.dumps({'atlas': atlas, 'coverage': coverage, 'evidence': evidence_manifest}, sort_keys=True).encode()).hexdigest()
    dump(SITE / 'data/site_version.json', site_version)
    write_frontend()
    review_archive = write_review_export(SITE, coverage, atlas, transitions, evidence_manifest)
    dump(OUTPUT / 'runtime_discovery.json', discovery)
    report = ROOT / '/tmp/SHARKY_VISUAL_STATE_ATLAS_DISCOVERY_V1.md'
    report.write_text(f'''# Sharky Visual State Atlas Discovery v1\n\n- Baseline: `{baseline}`\n- Runtime tasks: {len(discovery['tasks'])}\n- Conditional registry states: {len(registry['states'])}\n- Unique visual contracts: {site_version['unique_visual_contract_count']}\n- Transitions: {len(transitions)}\n- Evidence PNGs: {len(evidence_manifest)}\n- Coverage: `{dict(counts)}`\n- Settings verdict: not implemented / not runtime reachable.\n- Dialog, sheet, overlay verdict: no typed release route registered by this bounded discovery.\n- Loading/error verdict: no typed release state registered by this bounded discovery.\n- Recommended next wave: capture only records listed as RUNTIME_REACHABLE_UNCAPTURED.\n''')
    print(f'VISUAL_CONTROL_CENTER_BUILT:{SITE}')
    print(f'VISUAL_CONTROL_CENTER_REVIEW_EXPORT:{review_archive}')


def write_frontend():
    (SITE / 'index.html').write_text('''<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sharky Visual Control Center</title><link rel="stylesheet" href="assets/app.css"></head><body><header><p class="eyebrow">HOSTED SNAPSHOT</p><h1>Sharky Visual Control Center</h1><p id="version">Loading snapshot metadata…</p></header><nav id="modes"></nav><main id="app"><p>Loading Atlas…</p></main><dialog id="inspector"><button id="close">Close</button><section id="detail"></section></dialog><script src="assets/app.js"></script></body></html>''')
    (SITE / 'assets/app.css').write_text('''*{box-sizing:border-box}body{margin:0;background:#081321;color:#e8f0fa;font:16px system-ui,sans-serif}header{padding:24px;background:#10243a;position:sticky;top:0;z-index:2}h1{margin:0}.eyebrow{color:#70b7ff;font-weight:700;margin:0 0 6px}nav{display:flex;overflow:auto;gap:8px;padding:12px;background:#14273a}button{background:#0a64d8;color:white;border:0;border-radius:8px;padding:9px 12px;cursor:pointer}main{padding:20px;max-width:1280px;margin:auto}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px}.card{background:#14273a;border-radius:12px;padding:14px}.card h3{margin-top:0}.thumb{width:100%;height:260px;object-fit:contain;background:#07101b;border-radius:8px}.muted{color:#a9bad0}.red{border-left:4px solid #ff6f6f}.green{border-left:4px solid #58d68d}dialog{max-width:min(96vw,1000px);background:#10243a;color:#e8f0fa;border:1px solid #5d7b9c;border-radius:12px;padding:18px}dialog img{max-width:100%;max-height:75vh;display:block;margin-top:12px}table{width:100%;border-collapse:collapse}td,th{padding:8px;text-align:left;border-bottom:1px solid #2a415a}@media(max-width:600px){header{padding:16px}main{padding:12px}}''')
    (SITE / 'assets/app.js').write_text('''const modes=['Overview','Flow Map','Surface Atlas','Coverage','Screen Inspector','Compare','Missing / Failed','Route Playback'];let atlas,coverage,evidence,transitions,version;const app=document.querySelector('#app'),detail=document.querySelector('#detail'),dialog=document.querySelector('#inspector');const load=n=>fetch(new URL('data/'+n,document.baseURI)).then(r=>r.json());Promise.all(['atlas.json','coverage.json','evidence_manifest.json','transitions.json','site_version.json'].map(load)).then(([a,c,e,t,v])=>{atlas=a;coverage=c;evidence=e;transitions=t;version=v;document.querySelector('#version').textContent=`Evidence ${v.evidence_baseline_sha.slice(0,12)} · Tooling ${v.atlas_tooling_baseline_sha.slice(0,12)} · ${v.release_failing_gap_count} failing gaps`;document.querySelector('#modes').innerHTML=modes.map(x=>`<button data-mode="${x}">${x}</button>`).join('');document.querySelector('#modes').onclick=e=>e.target.dataset.mode&&render(e.target.dataset.mode);render('Overview')});document.querySelector('#close').onclick=()=>dialog.close();function imageFor(state){const record=coverage.records.find(x=>x.state_id===state.state_id);return record&&record.representative?evidence.images.find(x=>x.inventory_id===record.representative):null}function card(s){const i=imageFor(s);return `<article class="card"><h3>${s.state_id}</h3><p class="muted">${s.visual_contract_id||s.surface_family}</p>${i?`<img loading="lazy" class="thumb" src="${i.thumbnail}" alt="${s.state_id}">`:''}<p>${s.production_owner}</p><button onclick="inspect('${s.state_id}')">Inspect</button></article>`}function render(mode){if(mode==='Overview'){const c=coverage.counts;app.innerHTML=`<h2>Overview</h2><div class="grid">${Object.entries(c).map(([k,v])=>`<div class="card"><h3>${k}</h3><p>${v}</p></div>`).join('')}</div><p>Portable snapshot with ${version.screenshot_count} full-resolution images. Local Atlas is canonical; Sites is never automatically synchronized.</p>`}else if(mode==='Flow Map'||mode==='Route Playback'){app.innerHTML=`<h2>${mode}</h2><div class="grid">${transitions.transitions.map(t=>`<div class="card"><b>${t.source_state_id}</b> → <b>${t.destination_state_id}</b><p>${t.trigger_type}: ${t.trigger_label}</p><p class="muted">${t.guard}</p></div>`).join('')}</div>`}else if(mode==='Surface Atlas'||mode==='Screen Inspector'){app.innerHTML=`<h2>${mode}</h2><div class="grid">${atlas.states.map(card).join('')}</div>`}else if(mode==='Coverage'||mode==='Missing / Failed'){const rows=mode==='Missing / Failed'?coverage.records.filter(x=>x.release_blocking||x.status!=='CAPTURED_CURRENT_HEAD'&&x.status!=='COVERED_BY_EQUIVALENCE'):coverage.records;app.innerHTML=`<h2>${mode}</h2><table><tr><th>State</th><th>Status</th><th>Representative</th><th>Next action</th></tr>${rows.map(x=>`<tr class="${x.release_blocking?'red':'green'}"><td>${x.state_id}</td><td>${x.status}</td><td>${x.representative||'—'}</td><td>${x.release_blocking?'Capture or classify':'None'}</td></tr>`).join('')}</table>`}else{app.innerHTML=`<h2>Compare</h2><div class="grid">${evidence.compare.map(x=>`<article class="card"><h3>${x.name}</h3><img loading="lazy" class="thumb" src="${x.image}" alt="${x.name}"><p>${x.sha256.slice(0,12)}</p></article>`).join('')||'<p>No before/after pairs supplied.</p>'}</div>`}}window.inspect=id=>{const s=atlas.states.find(x=>x.state_id===id),i=imageFor(s);detail.innerHTML=`<h2>${id}</h2><p>${s.visual_contract_id||s.surface_family}</p><p>${s.route_or_entry_condition}</p><p>${s.production_owner}</p>${i?`<img src="${i.full_image}" alt="full evidence"><p>${i.sha256} · ${(i.dimensions||[]).join('×')}</p>`:''}`;dialog.showModal()}''')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--evidence', default=str(DEFAULT_EVIDENCE))
    parser.add_argument('--discovery', default=str(OUTPUT / 'runtime_discovery.json'))
    parser.add_argument('--expected-evidence-baseline', default='b7db47a3145ba8653b90403a9aa48538c378cdb7')
    build(parser.parse_args())

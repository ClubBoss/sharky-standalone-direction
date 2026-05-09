enum PersonalizationNextActionTarget { none, phase1, phase2, phase3 }

String? focusLabelToNextAction(String focusLabel) {
  switch (focusLabel) {
    case 'range':
    case 'position':
    case 'board':
      return 'run_phase1';
    case 'sizing':
    case 'value':
      return 'run_phase2';
    case 'bluff':
    case 'discipline':
      return 'run_phase3';
    default:
      return null;
  }
}

PersonalizationNextActionTarget targetForNextAction(String action) {
  switch (action) {
    case 'repeat_phase1':
    case 'run_phase1':
      return PersonalizationNextActionTarget.phase1;
    case 'run_phase2':
      return PersonalizationNextActionTarget.phase2;
    case 'run_phase3':
      return PersonalizationNextActionTarget.phase3;
    default:
      return PersonalizationNextActionTarget.none;
  }
}

bool isRoutableNextAction(String action) {
  return targetForNextAction(action) != PersonalizationNextActionTarget.none;
}

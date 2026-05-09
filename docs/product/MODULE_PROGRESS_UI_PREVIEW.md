# Module Progress Tracking - UI Preview

## Module Catalog Screen

```
╔════════════════════════════════════════════════╗
║  ← Training Module Catalog            ☰ Filter ║
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │ [✓] Bankroll Management              ✓   │ ║ ← Completed module
║  │     core • core_bankroll_management   >  │ ║   (green check)
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │ [C] 3-Bet Pot OOP                      > │ ║ ← Not completed
║  │     cash • cash_3bet_pot_oop             │ ║   (category letter)
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │ [M] Push/Fold Ranges                   > │ ║
║  │     mtt • mtt_push_fold                  │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │ [✓] ICM Basics                        ✓  │ ║ ← Completed module
║  │     icm • icm_basics                   >  │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
╚════════════════════════════════════════════════╝
```

## Module Detail Screen - Not Completed

```
╔════════════════════════════════════════════════╗
║  ← Bankroll Management                    ○   ║ ← Outline icon
╠════════════════════════════════════════════════╣
║  Theory  |  Drills  |  Demos                  ║
╠════════════════════════════════════════════════╣
║                                                ║
║  What it is                                    ║
║  ─────────────────────                         ║
║  A bankroll is the dedicated money set aside   ║
║  for poker. Proper bankroll management (BRM)   ║
║  helps you survive variance...                 ║
║                                                ║
║  Why it matters                                ║
║  ──────────────                                ║
║  Without proper BRM, even skilled players      ║
║  risk going broke during downswings...         ║
║                                                ║
║  Rules of thumb                                ║
║  ───────────────                               ║
║  • Cash games: 20-30 buy-ins                   ║
║  • Tournaments: 50-100 buy-ins                 ║
║  • Move down if bankroll drops 25%             ║
║                                                ║
║                                                ║
║                                    [scroll...] ║
║                                                ║
╠════════════════════════════════════════════════╣
║  ┌──────────────────────────────────────────┐ ║
║  │       ✓  Mark as Completed               │ ║ ← Sticky button
║  └──────────────────────────────────────────┘ ║   (green)
╚════════════════════════════════════════════════╝
```

## Module Detail Screen - Completed

```
╔════════════════════════════════════════════════╗
║  ← Bankroll Management                    ✓   ║ ← Green check icon
╠════════════════════════════════════════════════╣
║  Theory  |  Drills  |  Demos                  ║
╠════════════════════════════════════════════════╣
║                                                ║
║  What it is                                    ║
║  ─────────────────────                         ║
║  A bankroll is the dedicated money set aside   ║
║  for poker...                                  ║
║                                                ║
║                                    [scroll...] ║
║                                                ║
╠════════════════════════════════════════════════╣
║  ┌──────────────────────────────────────────┐ ║
║  │       ⟲  Mark as Incomplete              │ ║ ← Sticky button
║  └──────────────────────────────────────────┘ ║   (grey)
╚════════════════════════════════════════════════╝
```

## Interaction Flow

### Scenario 1: Marking Module as Completed

1. User opens "Bankroll Management" module
2. User reads through theory tab
3. User scrolls to bottom
4. User taps green "Mark as Completed" button
5. Button changes to grey "Mark as Incomplete"
6. AppBar icon changes from ○ to ✓ (green)
7. User returns to catalog
8. Module now shows with green checkmark in list

### Scenario 2: Un-marking Completed Module

1. User opens completed "ICM Basics" module (shows ✓ in AppBar)
2. User taps ✓ icon in AppBar OR taps "Mark as Incomplete" button
3. Icon changes to ○, button changes to "Mark as Completed"
4. User returns to catalog
5. Module no longer shows checkmark

### Scenario 3: Viewing Progress

```
Filter Menu:
┌───────────────────────┐
│ ○ All Categories      │
├───────────────────────┤
│ ● Core (3/15)         │ ← Shows 3 of 15 completed
│   Cash (2/18)         │
│   MTT (1/12)          │
│   ICM (0/3)           │
│   ...                 │
└───────────────────────┘
```

## Visual Indicators

### Catalog List Item States

**Not Started:**
```
┌──────────────────────────────────┐
│ [C] Module Title              >  │  Avatar: Category letter
│     category • module_id         │  No checkmark
└──────────────────────────────────┘
```

**Completed:**
```
┌──────────────────────────────────┐
│ [✓] Module Title              ✓  │  Avatar: Green ✓
│     category • module_id      >  │  Title checkmark
└──────────────────────────────────┘
```

### Detail Screen AppBar States

**Not Completed:** `○` (outline circle)  
**Completed:** `✓` (filled green check)

### Theory Tab Button States

**Not Completed:**
- Text: "Mark as Completed"
- Icon: ✓
- Color: Green (#4CAF50)

**Completed:**
- Text: "Mark as Incomplete"
- Icon: ⟲ (replay)
- Color: Grey (#9E9E9E)

## Accessibility

- ✅ Touch target: 48dp minimum (Material Guidelines)
- ✅ Color contrast: Green (#4CAF50) on white background
- ✅ Semantic labels: Completion icons have tooltips
- ✅ Safe area: Button respects device notches
- ✅ Screen reader: All icons have descriptive labels

## Animation (Future Enhancement)

When marking as completed:
1. Button scales slightly (0.95 → 1.0)
2. Checkmark animates in with fade + scale
3. Subtle haptic feedback
4. Success message (optional snackbar)

## Dark Mode Support

The UI automatically adapts to dark theme:
- Green checkmarks remain visible (#66BB6A)
- Button uses theme-appropriate backgrounds
- Shadows adjust for dark surfaces

## Performance

- No lag on button tap (async operation)
- Instant UI feedback
- Background save to SharedPreferences
- Cache invalidation ensures fresh data

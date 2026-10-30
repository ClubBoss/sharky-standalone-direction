# #334 L11 patch B (apply after patch A): displayed Pot = total committed at the
# decision, including the outstanding bet (pre-accepted owner policy).
import sys
src=open(sys.argv[1]).read(); out=sys.argv[2]
lines=src.split('\n')
def off(line): return sum(len(l)+1 for l in lines[:line-1])
def find_after(text, anchor_pat):
    a=src.index(anchor_pat); j=src.find(text,a); assert j>=0 and j-a<6000,(anchor_pat,text); return j
edits=[
 ("lessonId: 'w11_checkpoint_mixed_table_line'","potLabel: 'Pot 8 BB',","potLabel: 'Pot 13 BB',"),
 ("lessonId: 'w11_trigger_bad_price_fold'","potLabel: 'Pot 12 BB',","potLabel: 'Pot 24 BB',"),
 ("lessonId: 'w11_trigger_small_price_continue'","potLabel: 'Pot 8 BB',","potLabel: 'Pot 10 BB',"),
 ("lessonId: 'w12_checkpoint_full_loop_line'","potLabel: 'Pot 8 BB',","potLabel: 'Pot 10 BB',"),
 ("lessonId: 'w12_pretty_hand_bad_price_fold'","potLabel: 'Pot 20 BB',","potLabel: 'Pot 38 BB',"),
 ("lessonId: 'w12_revenge_raise_trap'","potLabel: 'Pot 8 BB',","potLabel: 'Pot 10 BB',"),
 ("lessonId: 'w4_bad_price_fold'","caption: 'Pot is 8 BB. To call is 7 BB with a weak pair.',","caption: 'Pot is 15 BB after the 7 BB bet. To call is 7 BB with a weak pair.',"),
 ("lessonId: 'w4_bad_price_fold'","(the 8 BB pot plus the 7 BB bet) needs about 32% equity. A weak pair is too thin","(8 BB before the bet plus the 7 BB bet) needs about 32% equity. A weak pair is too thin"),
 ("lessonId: 'w4_bad_price_fold'","(the 8 BB pot plus the 7 BB bet), so it needs","(8 BB before the bet plus the 7 BB bet), so it needs"),
 ("lessonId: 'w4_bad_price_fold'","potLabel: 'Pot 8 BB',","potLabel: 'Pot 15 BB',"),
 ("lessonId: 'w4_big_price_marginal_fold'","caption: 'Pot is 9 BB. To call is 6 BB with top pair, weak kicker.',","caption: 'Pot is 15 BB after the 6 BB bet. To call is 6 BB with top pair, weak kicker.',"),
 ("lessonId: 'w4_big_price_marginal_fold'","(the 9 BB pot plus the 6 BB bet)","(9 BB before the bet plus the 6 BB bet)"),
 ("lessonId: 'w4_big_price_marginal_fold'","compared with the 9 BB pot and this marginal hand.","compared with the 9 BB that was in before the bet and this marginal hand."),
 ("lessonId: 'w4_big_price_marginal_fold'","potLabel: 'Pot 9 BB',","potLabel: 'Pot 15 BB',"),
]
spans=[]
for anchor,old,new in edits:
    j=find_after(old,anchor); spans.append((j,j+len(old),new))
spans.sort()
for a,b in zip(spans,spans[1:]): assert a[1]<=b[0]
s=src
for j,k,new in reversed(spans): s=s[:j]+new+s[k:]
open(out,'w').write(s); print('edits',len(spans))

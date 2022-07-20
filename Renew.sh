#!/bin/bash
SPB=$(find ~/Загрузки/ -iname 'SmartProxy*.json' -printf '%TY-%Tm-%Td %TT ^%p^\n' | sort -r | cut -d '^' -f 2 | head -n 1)
base64 -d PR_b64.rls > PR_pt_temp1.rls
grep -Po '"hostName":".*?",' "$SPB" | cut -d '"' -f 4 >> PR_pt_temp1.rls
awk '!seen[$0]++' PR_pt_temp1.rls > PR_pt_temp2.rls
nano PR_pt_temp2.rls && base64 PR_pt_temp2.rls > PR_b64.rls
rm PR_pt_temp*
git add -A -f; git commit -a -m "$(date)"; git push origin main

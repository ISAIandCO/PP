#!/bin/bash
base64 -d PR_b64.rls > PR_pt_temp.rls
echo "PR_b64.rls.ru" >> PR_pt_temp.rls
#cp PR_pt.rls PR_pt_temp.rls
grep -Po '"hostName":".*?",' SmartProxy*.json | cut -d '"' -f 4 >> PR_pt_temp.rls
awk '!seen[$0]++' PR_pt_temp.rls | base64 > PR_b64.rls
rm PR_pt_temp.rls
echo "PR_pt.rls.ru" > PR_pt.rls

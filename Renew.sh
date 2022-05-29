#!/bin/bash
cp PR_pt.rls PR_pt_temp.rls
grep -Po '"hostName":".*?",' SmartProxy*.json | cut -d '"' -f 4 >> PR_pt_temp.rls
awk '!seen[$0]++' PR_pt_temp.rls > PR_pt.rls
base64 PR_pt.rls > PR_b64.rls
rm PR_pt_temp.rls

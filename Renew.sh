#!/bin/bash
grep -Po '"hostName":".*?",' SmartProxy-RulesBackup.json | cut -d '"' -f 4 > PR_pt.rls
base64 PR_pt.rls > PR_b64.rls

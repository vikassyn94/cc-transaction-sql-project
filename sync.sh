#!/bin/bash

cd /Users/vikassingh/Documents/credit-card-transaction-analysis
git pull origin main --allow-unrelated-histories --no-rebase
git add .
git commit -m "Auto-sync: $(date)"
git push

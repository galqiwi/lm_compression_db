#!/bin/bash

set -eux pipefail

PUBLISHER="$1"
echo "$PUBLISHER"
MODEL="$2"
echo "$MODEL"

mkdir -p "./$PUBLISHER/$MODEL"

run_one_task() {
  TASK="$1"
  NUM_FEWSHOT="$2"
  echo TASK="$TASK"
  python3 run_lm_eval.py --model_name "$PUBLISHER/$MODEL" --save_json "./$PUBLISHER/$MODEL/""$TASK"_"$NUM_FEWSHOT".json --task "$TASK"
}

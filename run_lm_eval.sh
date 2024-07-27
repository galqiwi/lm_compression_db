#!/bin/bash

set -eu

echo "$#"

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

run_one_task mmlu_continuation_high_school_government_and_politics 1
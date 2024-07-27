#!/bin/bash

set -eu

echo "$#"

PUBLISHER="$1"
echo PUBLISHER="$PUBLISHER"
MODEL="$2"
echo MODEL="$MODEL"
BATCH_SIZE="$3"

mkdir -p "./models/$PUBLISHER/$MODEL"

run_one_task() {
  TASK="$1"
  NUM_FEWSHOT="$2"
  echo TASK="$TASK"_"$NUM_FEWSHOT"
  python3 run_lm_eval.py --model_name "$PUBLISHER/$MODEL" --save_json "./models/$PUBLISHER/$MODEL/""$TASK"_"$NUM_FEWSHOT".json --task "$TASK" --batch_size "$BATCH_SIZE"
}

run_one_task winogrande 1
run_one_task piqa 1
run_one_task hellaswag 1
run_one_task arc_easy 1
run_one_task arc_challenge 1
run_one_task mmlu 1
run_one_task mmlu 5

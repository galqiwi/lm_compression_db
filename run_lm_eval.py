import os
import subprocess
import json
import os
import tempfile
from transformers import AutoModelForCausalLM


def exec_command(command, env=None) -> str:
    if env is None:
        env = os.environ.copy()

    process = subprocess.run(command, capture_output=True, env=env)

    if process.returncode == 0:
        return process.stdout.decode() + '\n' + process.stderr.decode()

    raise Exception('command {} failed\nstdout:\n{}\nstderr:\n{}'.format(
        command,
        process.stdout.decode(),
        process.stderr.decode(),
    ))


def trim_lm_eval_output(output):
    return {
        'model_name': output['model_name'],
        'config': output['config'],
        'configs': output['configs'],
        'results': output['results'],
    }


def get_model_size(model):
    output = 0
    for param in model.parameters():
        output += param.nelement() * param.element_size()
    for buffer in model.buffers():
        output += buffer.nelement() * buffer.element_size()
    return output


def run_lm_eval(model_name, task, num_fewshot=1, batch_size=16):
    with tempfile.TemporaryDirectory() as tmpdirname:
        cmd = ['lm_eval']

        cmd.extend(['--model', 'hf'])
        cmd.extend(['--model_args', f'pretrained={model_name}'])
        cmd.extend(['--tasks', task])
        cmd.extend(['--batch_size', str(batch_size)])
        cmd.extend(['--output_path', tmpdirname])
        cmd.extend(['--num_fewshot', str(num_fewshot)])

        exec_command(cmd)

        def get_ony_dir_entry(path):
            entries = os.listdir(path)
            assert len(entries) == 1
            return entries[0]

        path = tmpdirname
        path = os.path.join(path, get_ony_dir_entry(path))
        path = os.path.join(path, get_ony_dir_entry(path))

        with open(path, 'r') as file:
            output = trim_lm_eval_output(json.load(file))

        output['model_size'] = get_model_size(AutoModelForCausalLM.from_pretrained(
            model_name,
            trust_remote_code=True, low_cpu_mem_usage=True,
        ))

        return output


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument('model_name', type=str, help='name of the language model to evaluate.')
    parser.add_argument('task', type=str, help='NLP task for evaluation.')
    parser.add_argument('num_fewshot', type=int, default=1, help='number of few-shot examples')
    parser.add_argument('batch_size', type=int, default=16, help='batch size for evaluation')
    parser.add_argument('save_json', type=str, required=True, help='path to json output')

    args = parser.parse_args()

    output = run_lm_eval(args.model_name, args.task, args.num_fewshot, args.batch_size)

    with open(args.save_json, 'w') as file:
        json.dump(output, file, indent=4)


if __name__ == '__main__':
    main()

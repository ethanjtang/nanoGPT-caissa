#!/bin/bash 
#SBATCH -p general ## Partition
#SBATCH -q public  ## QOS
#SBATCH -N 1      ## Number of Sol Nodes
#SBATCH -c 8     ## Number of Cores
#SBATCH --mem=32G  ## Memory (GB)
#SBATCH --time=10  ## Minutes of compute
#SBATCH -G 1        ## Number of GPUs
#SBATCH --job-name=ood-example-python
#SBATCH --output=slurm.%j.out  ## job /dev/stdout record (%j expands -> jobid)
#SBATCH --error=slurm.%j.err   ## job /dev/stderr record 
#SBATCH --export=NONE          ## keep environment clean
#SBATCH --mail-type=ALL        ## notify <asurite>@asu.edu for any job state change

echo "=========================================="
echo "Mini Caissa Test"
echo "=========================================="

# Load environment
module load mamba/latest
source activate caissa-env

# Install dependencies
echo "Installing mamba stuffs"
if ! mamba env list | grep -q "caissa-env"; then
    echo "Creating new mamba environment caissa-env"
    mamba create -y -n caissa-env python=3.10
fi

echo "Installing Python stuffs"
pip install torch numpy transformers datasets tiktoken wandb tqdm

# Prepare training data
echo "Preparing training data"
python data/annotated-games/prepare.py

# Train LLM
echo "Training LLM on data"
python train.py config/train_caissa.py

# Sample from LLM
echo "Test sample LLM without prompt"
python sample.py --out_dir=out-annotated-games

echo "Test sample LLM with prompt"
python sample.py --start="FILE:./prompts/pgn_fen_single_test.txt" --out_dir=out-annotated-games



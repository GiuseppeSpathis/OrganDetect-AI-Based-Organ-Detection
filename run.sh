#!/bin/bash

set -e
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

INSTALL_DIR="$HOME/miniconda3"
CONDA_SH="$INSTALL_DIR/miniconda.sh"

# Install conda if not already installed
if ! command -v conda &> /dev/null; then
    echo "Conda is not installed. Installing Miniconda..."

    mkdir -p "$INSTALL_DIR"

    if [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "arm64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o "$CONDA_SH"
    elif [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "x86_64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o "$CONDA_SH"
    elif [[ "$OS_TYPE" == "Linux" && "$ARCH" == "x86_64" ]]; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$CONDA_SH"
    else
        echo "Unsupported OS or architecture. Exiting."
        exit 1
    fi

    bash "$CONDA_SH" -b -u -p "$INSTALL_DIR"
    rm "$CONDA_SH"
else
    echo "Conda is installed, proceeding with the script."
fi

# Initialize Conda
echo "Initializing Conda..."
source "$INSTALL_DIR/etc/profile.d/conda.sh"
conda init bash || true
source ~/.bashrc || true

# Create environment from environment.yml (if it doesn't already exist)
echo "Creating Conda environment from environment.yml..."
conda activate base
conda env create -f environment.yml || echo "Environment may already exist."

# Open tutorial.nb with the appropriate command based on OS
echo "Attempting to open tutorial.nb..."
if [[ "$OS_TYPE" == "Darwin" ]]; then
    open tutorial.nb
elif [[ "$OS_TYPE" == "Linux" ]]; then
    xdg-open tutorial.nb
else
    echo "Unsupported OS $OS_TYPE for opening the notebook. Please open it manually."
fi



#!/bin/bash


set -e
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

if command -v conda &> /dev/null
then
    echo "Conda is installed, proceeding with the script."
else
    echo "Conda is not installed. Please install it first."
    mkdir -p ~/miniconda3
    if [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "arm64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
    elif [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "x86_64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
    elif [[ "$OS_TYPE" == "Linux" && "$ARCH" == "x86_64" ]]; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
    else
        echo "Unsupported OS or architecture. Exiting."
        exit 1
    fi
fi

# lanuch mathematica file "tutorial.nb" in the current directory
if [[ "$OS_TYPE" == "Darwin" ]]; then
    open tutorial.nb
elif [[ "$OS_TYPE" == "Linux" ]]; then
    xdg-open tutorial.nb
else
    echo "Unsupported OS for opening the notebook. Please open it manually."
fi

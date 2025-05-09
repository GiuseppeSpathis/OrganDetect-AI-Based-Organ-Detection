#!/bin/bash

# Setta l'ambiente per l'esecuzione del codice
set -e

# Controlla il tipo di sistema operativo e architettura. I sistemi operativi supportati sono MacOS (sia x86_64 che arm64) e Linux (x86_64).
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

# Stampa informazioni sul sistema
INSTALL_DIR="$HOME/miniconda3" # directory d'installazione di Miniconda
CONDA_SH="$INSTALL_DIR/miniconda.sh" # file di installazione di Miniconda
CONDA_BIN="$INSTALL_DIR/bin/conda" # percorso del binario di Conda

# Installa Miniconda se non è già installato
#if ! command -v conda &> /dev/null ; then
if [[ ! -f "$CONDA_BIN" ]]; then # Controlla se il binary di Conda esiste
    echo "Conda is not installed. Installing Miniconda..."

    mkdir -p "$INSTALL_DIR" # Crea la directory di installazione se non esiste

    if [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "arm64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o "$CONDA_SH"
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
    elif [[ "$OS_TYPE" == "Darwin" && "$ARCH" == "x86_64" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o "$CONDA_SH"
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh
    elif [[ "$OS_TYPE" == "Linux" && "$ARCH" == "x86_64" ]]; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$CONDA_SH"
        # Inizializza Conda
        echo "Initializing Conda..."
        source "$INSTALL_DIR/etc/profile.d/conda.sh"
        conda init bash || true
        source ~/.bashrc || true

        # Crea l'ambiente Conda e controlla se esiste già
        echo "Creating Conda environment from environment.yml..."
        conda activate base
        conda env create -f environment.yml || echo "Environment may already exist."
    else
        echo "Unsupported OS or architecture. Exiting."
        exit 1
    fi

    bash "$CONDA_SH" -b -u -p "$INSTALL_DIR" # Installa Miniconda
    rm "$CONDA_SH" # Rimuovi il file di installazione
else
    echo "Conda is installed, proceeding with the script."
fi


# Apri il notebook di Mathematica. Se viene aperto con un sistema operativo diverso da MacOS o Linux, mostra un messaggio di errore.
echo "Attempting to open tutorial.nb..."
if [[ "$OS_TYPE" == "Darwin" ]]; then
    open tutorial.nb
elif [[ "$OS_TYPE" == "Linux" ]]; then
    xdg-open tutorial.nb
else
    echo "Unsupported OS $OS_TYPE for opening the notebook. Please open it manually."
fi



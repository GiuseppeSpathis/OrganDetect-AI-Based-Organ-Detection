@echo off
setlocal enabledelayedexpansion

:: Setta ambiente per l'esecuzione
echo Setting up environment...

:: Controlla se Conda è già installato
where conda >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Conda is not installed. Installing Miniconda...
    
    set "INSTALL_DIR=%USERPROFILE%\miniconda3"
    set "CONDA_EXE=%TEMP%\miniconda.exe"
    
    :: Scarica installer di Miniconda
    echo Downloading Miniconda...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe' -OutFile '%CONDA_EXE%'}"
    
    :: Installa Miniconda
    echo Installing Miniconda...
    start /wait "" "%CONDA_EXE%" /S /InstallationType=JustMe /AddToPath=1 /RegisterPython=1 /D=%INSTALL_DIR%
    
    :: Clean up
    del "%CONDA_EXE%"
) else (
    echo Conda is installed, proceeding with the script.
)

:: Inizializza Conda
echo Initializing Conda...
call "%USERPROFILE%\miniconda3\Scripts\activate.bat"

:: Crea ambiente Conda dal file environment.yml
echo Creating Conda environment from environment.yml...
call conda activate base
call conda env create -f environment.yml || echo Environment may already exist.

:: Apri il notebook Mathematica se possibile
echo Attempting to open tutorial.nb...
if exist "tutorial.nb" (
    start "" "tutorial.nb"
) else (
    echo Could not find tutorial.nb, please open it manually.
)

echo.
echo Script completed. Press any key to exit.
pause > nul

endlocal

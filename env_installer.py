import subprocess
import sys
import os
import platform

def conda_installed():
    try:
        subprocess.run(["conda", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except Exception:
        return False

def create_conda_env(env_file="environment.yml"):
    if not os.path.exists(env_file):
        print(f"Error: '{env_file}' not found.")
        sys.exit(1)

    try:
        subprocess.run(["conda", "env", "create", "-f", env_file], check=True)
        print("Conda environment created successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to create Conda environment:\n{e}")
        sys.exit(1)

def main():
    print("Checking for Conda installation...")
    if not conda_installed():
        print("Conda is not installed or not in PATH. Please install Anaconda or Miniconda.")
        sys.exit(1)

    print(f"Detected platform: {platform.system()}")
    create_conda_env()

if __name__ == "__main__":
    main()


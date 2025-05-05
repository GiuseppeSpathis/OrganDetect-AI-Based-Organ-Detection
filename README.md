# OrganDetect-AI-Based-Organ-Detection
Organ detection based on ultrasound images using deep learning algorithms, implemented in Wolfram Mathematica.

# Installation

- Install [conda](https://www.anaconda.com/docs/getting-started/miniconda/install#quickstart-install-instructions)
- While in the miniconda base environment, in the root folder of the project, run:

```bash
conda env create -f environment.yml
```

# Usage
To run the Organ detection tool, execute `tutorial.nb`

# Notes
- Introduction -> task goal, definizione del problema, finding 2d thyroids
- Tutorial -> the contents of this md file, update with run bash, UI introduction with tons of images
- Approaches -> failed finetune in mathematica, successive implementation with python
- Data processing | training -> Yolov8 x segmentazione, dataset di ecografie di 16 pazienti con relative ground truth, file division (eg. OrganDetection.m holds python-mathematica recall functions, dcm2jpg to dataset preprocessing)
- Finetune -> 100 epoche, split 704-176 80-20, su python (reference filename), usando Colab
- results -> nella cartella results in results.csv, descrivere csv (gpt aiuta), detection in 2d non e' perfetta rispetto alla 3d https://pubmed.ncbi.nlm.nih.gov/36830918/
- inferenza -> pesi = best.pt, file richiamato per predizione su una nuova foto
- evaluation -> todo
- progetti futuri -> aumentare il dataset, detection di altri organi
import argparse
from ultralytics import YOLO
import os
import sys
import torch # Per controllare la GPU
import cv2   # Importa OpenCV per salvare l'immagine manualmente

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="YOLOv8 Segmentation Inference Script")
    # Valori di default rimossi dagli argomenti --weights e --image per renderli obbligatori o gestiti da chi chiama lo script
    parser.add_argument("--weights", default="best.pt", help="Path to YOLOv8 model weights (.pt file)")
    parser.add_argument("--image", default="uno100.jpg", help="Path to the input image")
    # output_dir e run_name non sono più usati per il percorso di salvataggio dell'immagine
    # Potrebbero servire se si salvano altri tipi di output (es. log, txt dei risultati)
    # parser.add_argument("--output_dir", default="mathematica_runs", help="Base directory (no longer used for image save path)")
    # parser.add_argument("--run_name", default="predict", help="Specific run name (no longer used for image save path)")
    parser.add_argument("--conf", type=float, default=0.5, help="Confidence threshold for prediction")
    args = parser.parse_args()

    try:
        print(f"Python Script: Starting inference...")
        print(f"Python Script: Using weights: {args.weights}")
        print(f"Python Script: Processing image: {args.image}")
        # print(f"Python Script: Default save structure would be: {os.path.join(args.output_dir, args.run_name)}") # Commentato
        print(f"Python Script: Confidence threshold: {args.conf}")
        print(f"Python Script: Torch version: {torch.__version__}")
        print(f"Python Script: GPU available: {torch.cuda.is_available()}")
        if torch.cuda.is_available():
             print(f"Python Script: GPU name: {torch.cuda.get_device_name(0)}")

        # Verifica esistenza file
        if not os.path.exists(args.weights):
             raise FileNotFoundError(f"Model weights not found: {args.weights}")
        if not os.path.exists(args.image):
             raise FileNotFoundError(f"Input image not found: {args.image}")

        # Carica il modello
        model = YOLO(args.weights)

        # Esegui la predizione SENZA salvare automaticamente l'immagine
        results = model.predict(
            source=args.image,
            save=False, # <--- Imposta save a False!
            # project=args.output_dir, # Non più necessario per l'immagine
            # name=args.run_name,      # Non più necessario per l'immagine
            exist_ok=True, # Utile se predict crea comunque cartelle temporanee
            conf=args.conf
        )

        # --- Salvataggio Manuale dell'Immagine Annotata ---
        if results and len(results) > 0:
            # Ottieni il primo (e probabilmente unico) oggetto risultato
            result = results[0]

            # Genera l'immagine con le predizioni disegnate sopra.
            # Il metodo .plot() restituisce un array NumPy in formato BGR.
            annotated_image_bgr = result.plot()

            # Costruisci il nuovo nome del file di output
            base_name = os.path.basename(args.image)           # Es: 'uno100.jpg'
            name_part, extension = os.path.splitext(base_name) # Es: ('uno100', '.jpg')
            output_filename = f"{name_part}predicted{extension}" # Es: 'uno100predicted.jpg'

            # Ottieni il percorso assoluto per salvarlo nella directory corrente dello script
            # os.getcwd() potrebbe essere più predicibile di '.' a seconda di come viene lanciato lo script
            # output_save_path = os.path.join(os.getcwd(), output_filename)
            output_save_path = os.path.abspath(output_filename) # Salva nella dir corrente da cui è lanciato lo script

            # Salva l'immagine annotata usando OpenCV
            try:
                save_success = cv2.imwrite(output_save_path, annotated_image_bgr)
            except Exception as write_error:
                 print(f"Python Script Error: Failed during cv2.imwrite to {output_save_path}: {write_error}", file=sys.stderr)
                 sys.exit(1)


            if save_success:
                print(f"Python Script: Inference complete.")
                # Stampa il percorso effettivo dove l'immagine è stata salvata
                print(f"SAVED_IMAGE_PATH:{output_save_path}") # Usa un prefisso chiaro
            else:
                # Questo blocco potrebbe non essere mai raggiunto se imwrite fallisce sollevando eccezione
                print(f"Python Script Error: cv2.imwrite failed to save to {output_save_path} but did not raise an exception.", file=sys.stderr)
                sys.exit(1)

        else:
             print(f"Python Script Error: Prediction did not return any results for image {args.image}.", file=sys.stderr)
             sys.exit(1) # Esce con errore se non ci sono risultati

        sys.exit(0) # Esce con successo

    except Exception as e:
        print(f"Python Script Error: An unexpected error occurred: {str(e)}", file=sys.stderr) # Stampa errori su stderr
        sys.exit(1) # Esce con codice di errore
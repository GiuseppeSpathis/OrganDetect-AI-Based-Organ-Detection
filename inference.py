import argparse
from ultralytics import YOLO
import os
import sys
import torch # Per controllare la GPU
import cv2   # Importa OpenCV per salvare l'immagine manualmente
import numpy as np # Importa numpy

# Aggiungi qui la definizione della tua funzione
def rileva_poligono_blu(immagine_path, precision=0.02):
    # Carica l'immagine
    img = cv2.imread(immagine_path)

    # Controlla se l'immagine è stata caricata correttamente
    if img is None:
        print(f"Python Script Error: Impossibile caricare l'immagine da {immagine_path}", file=sys.stderr)
        return [] # Restituisce lista vuota in caso di errore

    # Ottieni le dimensioni dell'immagine per la trasformazione delle coordinate
    height, width, _ = img.shape

    # Converti in HSV per l'isolamento del colore
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Definisce i limiti del colore blu in HSV (potrebbero richiedere fine-tuning)
    lower_blue = np.array([100, 150, 50])
    upper_blue = np.array([140, 255, 255])

    # Crea una maschera per il blu
    mask = cv2.inRange(img_hsv, lower_blue, upper_blue)

    # Trova i contorni
    # RETR_EXTERNAL recupera solo i contorni esterni
    # CHAIN_APPROX_SIMPLE comprime segmenti orizzontali, verticali e diagonali
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        # Print non necessario qui, gestito dal chiamante
        return []

    # Seleziona il contorno più grande (presumibilmente il poligono blu che cerchiamo)
    contorno_principale = max(contours, key=cv2.contourArea)

    # Approssima il contorno con la precisione data per ottenere i vertici
    # epsilon è la massima distanza dal contorno originale al contorno approssimato
    epsilon = precision * cv2.arcLength(contorno_principale, True)
    poligono = cv2.approxPolyDP(contorno_principale, epsilon, True)

    # Estrae e trasforma le coordinate dei vertici nel formato [x, y] per Mathematica Graphics
    # OpenCV restituisce [colonna, riga] da top-left.
    # Mathematica Graphics usa [x, y] da bottom-left.
    # Assumiamo che x sia la colonna e y sia la riga. La trasformazione y è: image_height - row
    coordinate_cv2 = poligono.reshape(-1, 2) # [colonna, riga] da top-left

    # Trasforma le coordinate per Mathematica Graphics (x, AltezzaImmagine - y)
    coordinate_math = [[int(p[0]), int(height - p[1])] for p in coordinate_cv2]


    return coordinate_math # Restituisce le coordinate trasformate come lista di liste

# Resto dello script principale
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="YOLOv8 Segmentation Inference Script")
    parser.add_argument("--weights", default="best.pt", help="Path to YOLOv8 model weights (.pt file)")
    parser.add_argument("--image", default="uno100.jpg", help="Path to the input image")
    parser.add_argument("--conf", type=float, default=0.5, help="Confidence threshold for prediction")
    args = parser.parse_args()

    try:
        print(f"Python Script: Starting inference...")
        print(f"Python Script: Using weights: {args.weights}")
        print(f"Python Script: Processing image: {args.image}")
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
            exist_ok=True,
            conf=args.conf
        )

        # --- Salvataggio Manuale dell'Immagine Annotata ---
        output_save_path = None # Inizializza a None
        if results and len(results) > 0:
            # Ottieni il primo (e probabilmente unico) oggetto risultato
            result = results[0]

            # Genera l'immagine con le predizioni disegnate sopra.
            annotated_image_bgr = result.plot(boxes=False, labels=False, conf=False)

            # Costruisci il nuovo nome del file di output
            base_name = os.path.basename(args.image)
            name_part, extension = os.path.splitext(base_name)
            output_filename = f"{name_part}predicted{extension}"

            # Ottieni il percorso assoluto per salvarlo
            output_save_path = os.path.abspath(output_filename)

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

                # --- Chiama la funzione per rilevare il poligono blu ---
                print(f"Python Script: Attempting to detect blue polygon in {output_save_path}...")
                polygon_verts = rileva_poligono_blu(output_save_path, precision=0.02)

                # Stampa le coordinate in un formato parsabile da Mathematica ({ {x1, y1}, {x2, y2}, ... })

                # Formatta manualmente la lista di liste usando parentesi graffe
                # Esempio: '{{108, 204}, {164, 160}, {180, 114}, {194, 114}, {196, 166}}'
                polygon_string_math_format = '{' + ', '.join(['{' + ', '.join(map(str, point)) + '}' for point in polygon_verts]) + '}'

                print(f"DETECTED_POINTS:{polygon_string_math_format}")


            else:
                print(f"Python Script Error: cv2.imwrite failed to save to {output_save_path}.", file=sys.stderr)
                sys.exit(1)

        else:
             print(f"Python Script Error: Prediction did not return any results for image {args.image}.", file=sys.stderr)
             sys.exit(1)

        sys.exit(0) # Esce con successo

    except Exception as e:
        print(f"Python Script Error: An unexpected error occurred: {str(e)}", file=sys.stderr)
        sys.exit(1) # Esce con codice di errore
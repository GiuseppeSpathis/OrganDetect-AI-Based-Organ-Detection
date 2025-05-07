import argparse
#Importa il modulo 'argparse', utilizzato per analizzare gli argomenti passati allo script dalla riga di comando.
from ultralytics import YOLO
#Importa la classe YOLO dalla libreria 'ultralytics', necessaria per caricare ed eseguire i modelli YOLO.
import os
#Importa il modulo 'os', che fornisce funzioni per interagire con il sistema operativo (es. gestione di percorsi, verifica esistenza file).
import sys
#Importa il modulo 'sys', che fornisce accesso a variabili e funzioni specifiche del sistema, come 'sys.stderr' per gli errori e 'sys.exit' per terminare lo script.
import torch 
#Importa la libreria PyTorch ('torch'), usata qui principalmente per verificare la disponibilità della GPU.
import cv2   
#Importa la libreria OpenCV ('cv2'), utilizzata per l'elaborazione di immagini, inclusi il caricamento, la manipolazione e il salvataggio manuale.
import numpy as np 
#Importa la libreria NumPy e le assegna l'alias 'np', fondamentale per operazioni numeriche, specialmente con array (usata qui per definire i range di colore e manipolare i contorni).


def rileva_poligono_blu(immagine_path, precision=0.02):
    '''
   Firma della funzione: rileva_poligono_blu(immagine_path, precision=0.02)
   - def: Parola chiave per definire una funzione.
   - rileva_poligono_blu: Nome della funzione.
   - immagine_path: Parametro in input. Stringa che rappresenta il percorso del file immagine da processare.
   - precision: Parametro in input opzionale, con valore predefinito 0.02. È un fattore che determina la precisione dell'approssimazione del poligono (usato con cv2.approxPolyDP).
   Scopo: Questa funzione carica un'immagine, tenta di isolare e rilevare il più grande poligono di colore blu presente.
          Successivamente, approssima i vertici di questo poligono e trasforma le loro coordinate dal sistema di riferimento di OpenCV (origine in alto a sinistra)
          a un sistema di riferimento compatibile con Mathematica Graphics (origine in basso a sinistra).
   Ritorna: Una lista di liste contenente le coordinate [x, y] dei vertici del poligono blu rilevato, trasformate per Mathematica.
            Restituisce una lista vuota se l'immagine non può essere caricata o se non vengono trovati contorni blu.
    '''
    img = cv2.imread(immagine_path)
    #Carica l'immagine dal percorso specificato usando OpenCV. 'img' sarà un array NumPy che rappresenta l'immagine.

    if img is None:
    # Commento: Verifica se il caricamento dell'immagine è fallito (cv2.imread restituisce None in caso di errore).
        print(f"Python Script Error: Impossibile caricare l'immagine da {immagine_path}", file=sys.stderr)
        return [] 
        #Termina la funzione e restituisce una lista vuota per segnalare l'errore.


    height, width, _ = img.shape
    # Estrae l'altezza ('height') e la larghezza ('width') dell'immagine. Il terzo valore (numero di canali) 
    # viene ignorato con '_'. Queste dimensioni sono necessarie per la successiva trasformazione delle coordinate y.
    

    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # Converte l'immagine dallo spazio colore BGR (usato di default da OpenCV) allo spazio colore HSV 
    # (Hue, Saturation, Value). Lo spazio HSV è spesso più efficace per il rilevamento di colori specifici.

    lower_blue = np.array([100, 150, 50])
    # Definisce il limite inferiore del range di colore blu in HSV. 
    
    
    upper_blue = np.array([140, 255, 255])
    # Definisce il limite superiore del range di colore blu in HSV.


    mask = cv2.inRange(img_hsv, lower_blue, upper_blue)
    # Crea una maschera binaria. I pixel dell'immagine HSV che rientrano nel range definito 
    # da 'lower_blue' e 'upper_blue' diventano bianchi (valore 255) nella maschera, gli altri neri (valore 0).


    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    # Trova i contorni nell'immagine della maschera binaria.
    # - 'mask': Immagine sorgente (la maschera blu).
    # - 'cv2.RETR_EXTERNAL': Modalità di recupero, prende solo i contorni più esterni.
    # - 'cv2.CHAIN_APPROX_SIMPLE': Metodo di approssimazione, rimuove i punti ridondanti.
    # 'contours' è una lista dei contorni trovati. Il secondo valore restituito (la gerarchia) è ignorato con '_'.

    if not contours:
    # Controlla se non sono stati trovati contorni.
        return []
        # Se non ci sono contorni, restituisce una lista vuota.


    contorno_principale = max(contours, key=cv2.contourArea)
    # Trova il contorno con l'area maggiore tra tutti quelli rilevati, assumendo che sia l'oggetto di interesse. 
    # 'cv2.contourArea' è usato come funzione chiave per dire su cosa fare il massimo.

 
    
    epsilon = precision * cv2.arcLength(contorno_principale, True)
    # Calcola il valore di 'epsilon' per l'approssimazione. 
    # epsilon è la massima distanza dal contorno originale al contorno approssimato
    # È una frazione ('precision') della lunghezza del 'contorno_principale'. 
    # 'True' indica che il contorno è chiuso.
    
    
    poligono = cv2.approxPolyDP(contorno_principale, epsilon, True)
    # Approssima il 'contorno_principale' a un poligono con un numero ridotto di vertici, 
    # in base alla 'precisione' (epsilon). 'True' indica che il poligono approssimato deve essere chiuso.


    coordinate_cv2 = poligono.reshape(-1, 2) 
    # Riformatta l'array 'poligono' (che ha forma [numero_punti, 1, 2]) 
    # in un array 2D [numero_punti, 2], dove ogni riga è [colonna, riga] con origine in alto a sinistra.
    


    coordinate_math = [[int(p[0]), int(height - p[1])] for p in coordinate_cv2]
    # Itera su ogni punto [colonna, riga] in 'coordinate_cv2'.
    # Mantiene la coordinata x (colonna) invariata.
    # Trasforma la coordinata y (riga) calcolando 'altezza_immagine - riga' per invertire l'asse y 
    # (da origine in alto a sinistra a origine in basso a sinistra).
    # Converte entrambe le coordinate in interi. Il risultato è una lista di liste [x, y_trasformata].
    #questo passaggio è necessario per la compatibilità con Mathematica, che usa un sistema di coordinate diverso da OpenCV.

    return coordinate_math
    # Restituisce la lista delle coordinate dei vertici del poligono, pronte per essere usate in Mathematica.


# Script principale main
if __name__ == "__main__":
# if __name__ == "__main__" è un costrutto standard Python che assicura che il codice seguente venga 
# eseguito solo quando lo script è lanciato direttamente (non quando importato come modulo).

    parser = argparse.ArgumentParser(description="YOLOv8 Segmentation Inference Script")
    # Crea un oggetto ArgumentParser per gestire gli argomenti da riga di comando, con una descrizione dello script.
    
    
    parser.add_argument("--weights", default="best.pt", help="Path to YOLOv8 model weights (.pt file)")
    # Aggiunge un argomento opzionale '--weights'. Se non fornito, usa "best.pt" come default. 'help' descrive l'argomento.
    
    
    parser.add_argument("--image", default="uno100.jpg", help="Path to the input image")
    # Aggiunge un argomento opzionale '--image'. Se non fornito, usa "uno100.jpg" come default.
    
    
    parser.add_argument("--conf", type=float, default=0.5, help="Confidence threshold for prediction")
    # Aggiunge un argomento opzionale '--conf' (soglia di confidenza). Deve essere un float, default 0.5.
    
    
    args = parser.parse_args()
    # Analizza gli argomenti forniti dalla riga di comando e li memorizza nell'oggetto 'args'.

    try:
    # Inizia un blocco try-except per catturare e gestire eventuali eccezioni che potrebbero verificarsi 
    # durante l'esecuzione.
    
    
        print(f"Python Script: Starting inference...")
        print(f"Python Script: Using weights: {args.weights}")
        print(f"Python Script: Processing image: {args.image}")
        print(f"Python Script: Confidence threshold: {args.conf}")
        print(f"Python Script: Torch version: {torch.__version__}")
        print(f"Python Script: GPU available: {torch.cuda.is_available()}")
        
        if torch.cuda.is_available():
            # Controlla se una GPU è disponibile.
            print(f"Python Script: GPU name: {torch.cuda.get_device_name(0)}")

        if not os.path.exists(args.weights):
        # Controlla se il file dei pesi del modello specificato non esiste.
            raise FileNotFoundError(f"Model weights not found: {args.weights}")
            # Se non esiste, solleva un'eccezione FileNotFoundError, che interromperà il blocco 'try' 
            # e passerà al blocco 'except'.
        if not os.path.exists(args.image):
        # Controlla se il file immagine di input specificato non esiste.
            raise FileNotFoundError(f"Input image not found: {args.image}")
            # Se non esiste, solleva un'eccezione FileNotFoundError.

        model = YOLO(args.weights)
        # Carica il modello YOLO utilizzando il percorso dei pesi fornito ('args.weights').

        results = model.predict(
        # Esegue l'inferenza del modello sull'immagine sorgente.
            source=args.image,
            # 'source': Specifica il percorso dell'immagine di input.
            save=False, # 
            # 'save=False': Cruciale. Impedisce al metodo 'predict' di salvare automaticamente 
            # l'immagine con le annotazioni. Il salvataggio sarà gestito manualmente.
            exist_ok=True,
            # 'exist_ok=True': Se 'save' fosse True e si stesse salvando in una directory di progetto,
            # questo eviterebbe errori se la directory esistesse già. Qui ha meno impatto diretto dato save=False.
            conf=args.conf
            # 'conf': Imposta la soglia di confidenza minima per le predizioni.
        )
        # 'results' è una lista di oggetti Result, ognuno contenente le predizioni per un'immagine.

        # --- Salvataggio Manuale dell'Immagine Annotata ---
        output_save_path = None 
        # Inizializza la variabile che conterrà il percorso di salvataggio dell'immagine annotata a None
        if results and len(results) > 0:
        # Controlla che la lista 'results' non sia vuota e contenga almeno un elemento.
        
        
            result = results[0]
            # Estrae il primo (e solitamente unico, per una singola immagine di input) oggetto Result dalla lista.

            annotated_image_bgr = result.plot(boxes=False, labels=False, conf=False)
            # Utilizza il metodo 'plot()' dell'oggetto 'result' per generare un'immagine con le annotazioni 
            # (segmentazioni, in questo caso).
            # 'boxes=False', 'labels=False', 'conf=False': Disabilita il disegno dei bounding box, 
            # delle etichette testuali e dei punteggi di confidenza sull'immagine, 
            # mostrando probabilmente solo le maschere di segmentazione.
            # 'annotated_image_bgr' è un array NumPy (immagine in formato BGR).

            base_name = os.path.basename(args.image)
            #  Estrae il nome del file (con estensione) dal percorso dell'immagine di input.
            
            
            name_part, extension = os.path.splitext(base_name)
            #Separa il nome del file dalla sua estensione.
            
            
            output_filename = f"{name_part}predicted{extension}"
            # Crea il nuovo nome del file di output aggiungendo "predicted" al nome originale 
            # (es. "input.jpg" -> "inputpredicted.jpg").


            output_save_path = os.path.abspath(output_filename)
            #Converte il nome del file di output in un percorso assoluto nella directory corrente.

            try:
            # Inizia un blocco try-except specifico per l'operazione di scrittura del file.
            
                save_success = cv2.imwrite(output_save_path, annotated_image_bgr)
                # Salva l'immagine annotata ('annotated_image_bgr') nel percorso 'output_save_path' 
                # usando OpenCV. 'cv2.imwrite' restituisce True se il salvataggio ha successo.
                
                
            except Exception as write_error:
            # Cattura eventuali eccezioni durante il tentativo di scrittura del file.
            
                print(f"Python Script Error: Failed during cv2.imwrite to {output_save_path}: {write_error}", file=sys.stderr)
                sys.exit(1)
                # Termina lo script con un codice di errore 1.

            if save_success:
            # Se 'cv2.imwrite' ha avuto successo.
            
                print(f"Python Script: Inference complete.")
                print(f"SAVED_IMAGE_PATH:{output_save_path}") # Usa un prefisso chiaro
                print(f"Python Script: Attempting to detect blue polygon in {output_save_path}...")
                polygon_verts = rileva_poligono_blu(output_save_path, precision=0.02)
                # Chiama la funzione 'rileva_poligono_blu', passandole il percorso dell'immagine 
                # annotata e salvata, e una precisione di 0.02.
                # 'polygon_verts' conterrà la lista delle coordinate dei vertici del poligono.

               
                polygon_string_math_format = '{' + ', '.join(['{' + ', '.join(map(str, point)) + '}' for point in polygon_verts]) + '}'
                # Questa riga formatta la lista di coordinate 'polygon_verts' in una stringa che assomiglia 
                # alla sintassi delle liste di Mathematica.
                # Per ogni punto (lista di due interi) in 'polygon_verts', converte gli interi in stringhe e 
                # li unisce con ", ".
                # Racchiude ogni coppia di coordinate tra "{}" (es. "{108, 204}").
                # Unisce tutte queste stringhe di punti con ", ".
                # Infine, racchiude l'intera stringa tra "{}" esterne.

                print(f"DETECTED_POINTS:{polygon_string_math_format}")

            else:
            # Se 'cv2.imwrite' non ha avuto successo (save_success è False).
                print(f"Python Script Error: cv2.imwrite failed to save to {output_save_path}.", file=sys.stderr)
                sys.exit(1)
                # Termina lo script con un codice di errore 1.

        else:
        # Se 'results' è vuoto o None (cioè, il modello non ha prodotto risultati).
            print(f"Python Script Error: Prediction did not return any results for image {args.image}.", file=sys.stderr)
            sys.exit(1)
            # Termina lo script con un codice di errore 1.

        sys.exit(0) # Esce con successo
        # Se tutto è andato a buon fine, termina lo script con un codice di uscita 0 (successo).

    except Exception as e:
    # Cattura qualsiasi altra eccezione non gestita precedentemente nel blocco 'try'.
    
    
        print(f"Python Script Error: An unexpected error occurred: {str(e)}", file=sys.stderr)
        sys.exit(1) # Esce con codice di errore
        #Termina lo script con un codice di errore 1.
(* ::Package:: *)

 


(*:Title: OrganDetection *)
(*:Context: OrganDetection` *)
(*:Authors: Giuseppe Spathis, Federico Augelli, Emanuele Di Sante, Matteo Fontana, Alessandro Mencarelli *)
(*:Summary: Organ detection based on ultrasound images using deep learning algorithms, implemented in Wolfram Mathematica. *)
(*:Copyright: GS 2025 *)
(*:Package Version: 1 *)
(*:Mathematica Version: 14  *)
(*:History: last modified 14/3/2025 ... da sistemare *)
(*:Keywords: Organ detection, ultrasound images *)
(*:Sources: biblio *)
(*:Limitations: this is for educational purposes only. *)
(*:Discussion: *)
(*:Requirements: *)
(*:Warning: package Context is not defined *)

BeginPackage["ObjectDetection`"]

(* Package ObjectDetection:
   Espone funzioni per il rilevamento di organi in immagini tramite uno script Python esterno. *)

(* Funzione main: rilevamento organi *)
OrganDetection::usage = 
  "OrganDetection[imagePath] esegue il rilevamento degli organi sull'immagine specificata.\n" <> 
  "  - imagePath (Opzionale, String): percorso dell'immagine di input. Deve esistere. " <> 
  "Se omesso, usa un'immagine di esempio incorporata.";

Begin["`Private`"]




OrganDetection[ Optional[imageToProcessPath_String?(FileExistsQ), Null] ] := Module[
(* Definizione della main function 'OrganDetection'.
    - Optional[pattern, defaultValue]: Definisce un argomento opzionale.
    - imageToProcessPath_String?(FileExistsQ): Il pattern per l'argomento.
        - imageToProcessPath_: Nome dell'argomento.
        - _String: Specifica che l'argomento deve essere una stringa.
        - ?(FileExistsQ): \[CapitalEGrave] un test di pattern. Se l'argomento viene fornito, deve essere una stringa che rappresenta un percorso a un file esistente (FileExistsQ deve restituire True).
    - Null: Se l'argomento non viene fornito o non supera il test del pattern, il suo valore sar\[AGrave] 'Null'.
     *)
  {condaOK, envName, ymlPath, envOK, pythonExecutablePath, inferenceResult,scriptPath, modelWeightsPath, effectiveImageToProcessPath, basePath,
    pythonSubPath
  (*  Dichiarazione delle variabili locali:
      - condaOK: Flag per indicare se Conda \[EGrave] installato correttamente.
      - envName: Nome dell'ambiente Conda da utilizzare/creare.
      - ymlPath: Percorso al file YAML per la creazione dell'ambiente.
      - envOK: Flag per indicare se l'ambiente Conda \[EGrave] pronto.
      - pythonExecutablePath: Percorso all'eseguibile Python nell'ambiente.
      - inferenceResult: Risultato dell'inferenza. 
      - scriptPath: Percorso allo script Python di inferenza.
      - modelWeightsPath: Percorso ai pesi del modello.
      - effectiveImageToProcessPath: Percorso effettivo dell'immagine da processare.
      - basePath: Percorso base per la directory dell'ambiente Conda.
      - pythonSubPath: Sottopercorso per l'eseguibile Python (dipendente dal SO).
      *)
    }, 
    

  envName = "yolo_inference";
  (* Imposta il nome dell'ambiente Conda desiderato a "yolo_inference". *)
  
  
  ymlPath =  "environment.yml";
  (* Imposta il nome del file YAML per la definizione dell'ambiente. *)
  
  
  scriptPath = "inference.py";
  (* Imposta il nome dello script Python che eseguir\[AGrave] l'inferenza. *)
  
  
  modelWeightsPath = "best.pt";
  (* Imposta il nome del file contenente i pesi del modello addestrato. *)
  

  effectiveImageToProcessPath = If[imageToProcessPath === Null,
  (* Controlla se 'imageToProcessPath' (l'argomento opzionale della funzione) \[EGrave] 'Null'. *)
      "uno100.jpg", 
      (* Se 'imageToProcessPath' \[EGrave] 'Null', usa "uno100.jpg" come percorso dell'immagine di default. *)
      
      imageToProcessPath 
      (* Altrimenti, usa il percorso dell'immagine fornito come argomento. *)
    ];


  (* 0. Controlla esistenza file necessari *)

  If[! FileExistsQ[ymlPath], Print["Errore: environment.yml non trovato."]; Return[$Failed]];
  (* Se il file 'environment.yml' non esiste, stampa un errore e termina la funzione restituendo '$Failed'. *)
  
  If[! FileExistsQ[scriptPath], Print["Errore: inference.py non trovato."]; Return[$Failed]];
  (* Se il file 'inference.py' non esiste, stampa un errore e termina. *)
  
  If[! FileExistsQ[modelWeightsPath], Print["Errore: best.pt non trovato."]; Return[$Failed]];
  (*Se il file 'best.pt' (pesi del modello) non esiste, stampa un errore e termina. *)
  
  If[! FileExistsQ[effectiveImageToProcessPath], Print["Errore: Immagine input non trovata: ", effectiveImageToProcessPath]; Return[$Failed]];
  (* Se il file immagine da processare ('effectiveImageToProcessPath') non esiste, stampa un errore e termina. *)

  (* 1. Controllo installazione Conda *)
 
  condaOK = CheckCondaInstallation[];
  (* Chiama la funzione helper 'CheckCondaInstallation' per verificare se Conda \[EGrave] installato. *)
  
  
  If[! condaOK, Print["Installare Miniconda."]; Return[$Failed]];
  (* Se 'condaOK' \[EGrave] 'False' (o 'Null' interpretato come 'False'), stampa un messaggio per installare Miniconda e termina. *)

  (* 2. Controllo/Creazione Ambiente conda *)
  envOK = EnsureCondaEnvFromFile[envName, ymlPath];
  (* Chiama la funzione helper 'EnsureCondaEnvFromFile' per assicurarsi che l'ambiente esista o per crearlo. *)
  
  If[! envOK, Print["Impossibile usare l'ambiente Conda '", envName, "'."]; Return[$Failed]];
  (* Se 'envOK' \[EGrave] 'False' , stampa un errore e termina.  *)


  
  (* trova path di python *)
  basePath = FileNameJoin[{$HomeDirectory, "miniconda3", "envs", envName}];
  (* Ricostruisce il percorso base dell'ambiente Conda specificato. $HomeDirectory \[EGrave] la directory home dell'utente. *)
  
    pythonSubPath = Switch[$OperatingSystem,
    (* Determina il sottopercorso relativo per l'eseguibile Python all'interno della cartella dell'ambiente, a seconda del sistema operativo ($OperatingSystem). *)
    
        "Windows", "python.exe",
        (* Su Windows, \[EGrave] "python.exe". *)
        
        "MacOSX" | "Unix", FileNameJoin[{"bin", "python"}],
        (* Su MacOSX o sistemi Unix-like, \[EGrave] "bin/python". *)
        
        _, Print["OS non supportato per GetUserPythonExecutable"]; Return[$Failed]
        (* Se il sistema operativo non \[EGrave] tra quelli elencati, stampa un errore e termina. *)
        
    ];
    pythonExecutablePath = FileNameJoin[{basePath, pythonSubPath}];
    (* Unisce il 'basePath' e 'pythonSubPath' per formare il percorso completo all'eseguibile Python.  *)
    
  
  (* 4. Esecuzione Inferenza usando il percorso specifico *)
 
  inferenceResult = RunInferenceWithExecutable[
  (* Chiama la funzione helper 'RunInferenceWithExecutable' per eseguire lo script Python. *)
  
      pythonExecutablePath, 
      (* Passa il percorso dell'eseguibile Python determinato. *)
      
      scriptPath,
      (* Passa il percorso dello script di inferenza. *)
      
      modelWeightsPath,
      (* Passa il percorso dei pesi del modello. *)
      
      effectiveImageToProcessPath  
      (* Passa il percorso dell'immagine da processare. *)
  ];
  
  

  (* 5. Gestione Risultato Inferenza *)
  If[ImageQ[inferenceResult["ResultImage"]],
  (* Controlla se il campo "ResultImage" dell'associazione 'inferenceResult' (restituita da RunInferenceWithExecutable) \[EGrave] effettivamente un oggetto Immagine (ImageQ). *)
    
    
    inferenceResult 
    (* Se \[EGrave] un'immagine valida, la funzione 'OrganDetection' restituisce l'intera associazione 'inferenceResult' (che contiene l'immagine e potenzialmente altri dati come le coordinate). *)
    ,
    Print["Inferenza fallita."];
    (* Se 'inferenceResult["ResultImage"]' non \[EGrave] un'immagine, stampa un messaggio di fallimento. *)
    
    $Failed
    (* E restituisce '$Failed'. *)
  ]
] (* Fine della funzione main OrganDetection  *)


(* FUNZIONI HELPER *)

(* funzione che fa l'inferenza del modello di detection lanciando il file inference.py *)
RunInferenceWithExecutable[
    pythonExecutable_String?FileExistsQ,
    (* Parametro: percorso dell'eseguibile Python; deve essere una stringa e il file deve esistere. *)
    
    scriptPath_String?FileExistsQ,
    (* Parametro: percorso dello script Python; deve essere una stringa e il file deve esistere. *)
    
    modelWeightsPath_String?FileExistsQ,
    (* Parametro: percorso dei pesi del modello; deve essere una stringa e il file deve esistere. *)
    
    imageToProcessPath_String?FileExistsQ] := Module[
    (* Parametro: percorso dell'immagine da processare; deve essere una stringa e il file deve esistere.  *)
    
  {
    process, commandArgs, exitCode, outputLog, outputLines,
    (* Dichiarazione delle variabili locali:
        - process: Oggetto che rappresenta il processo esterno avviato.
        - commandArgs: Lista degli argomenti da passare allo script Python.
        - exitCode: Codice di uscita del processo Python.
        - outputLog: Output standard (stdout) dello script Python.
        - outputLines: 'outputLog' diviso in una lista di righe. *)
        
    savedPathLine, savedCoordinates, outputImagePath, outputCoordinates, resultImage
    (* Altre variabili locali:
        - savedPathLine: Riga dall'output contenente "SAVED_IMAGE_PATH:".
        - savedCoordinates: Riga dall'output contenente "DETECTED_POINTS:".
        - outputImagePath: Percorso effettivo dell'immagine salvata dallo script Python.
        - outputCoordinates: Stringa delle coordinate rilevate.
        - resultImage: Oggetto Immagine importato da 'outputImagePath'.
         *)
    },


  (* Definisci gli argomenti per lo script Python *)
  commandArgs = {
  (* Crea una lista di stringhe che saranno gli argomenti per lo script Python. *)
      scriptPath,
      (* Il primo argomento \[EGrave] lo script stesso. inference.py *)
      "--weights", modelWeightsPath,
      (* Argomento per specificare i pesi del modello. *)
      
      "--image", imageToProcessPath
      (* Argomento per specificare l'immagine di input. *)
  };



  process = RunProcess[
  (* Avvia un processo esterno. *)
      Join[{pythonExecutable}, commandArgs]
      (* Il comando da eseguire \[EGrave] formato unendo il percorso dell'eseguibile Python con la lista degli argomenti ('commandArgs'). *)
        ];
  


  exitCode = process["ExitCode"];
  (* Ottiene il codice di uscita del processo. 0 solitamente indica successo. *)
  
  
   outputLog = process["StandardOutput"];
  (* Ottiene l'intero output standard del processo come una singola stringa. *)
  
  
  (* Controlla se il processo \[EGrave] terminato con successo *)
  If[exitCode =!= 0,
  (* Se il codice di uscita \[EGrave] diverso da 0 (indica un errore) *)
  
      Print["\:274c Errore: Lo script Python \[EGrave] terminato con codice di uscita non zero: ", exitCode];
      (* Stampa un messaggio di errore con il codice di uscita. *)
      
      Return[$Failed]
      (* Termina la funzione e restituisce '$Failed'. *)
  ];



(* Cerca il percorso dell'immagine salvata nell'output standard *)
  outputLines = StringSplit[outputLog, {"\n", "\r\n", "\r"}]; (* Gestisce diversi tipi di newline *)
  (* Divide la stringa 'outputLog' in una lista di righe, gestendo diversi formati di "a capo". *)
  
  
  
  savedPathLine = SelectFirst[outputLines, Function[line, StringStartsQ[line, "SAVED_IMAGE_PATH:"]], Missing["NotFound"]];
(* Cerca la prima riga in 'outputLines' che inizia con la stringa "SAVED_IMAGE_PATH:".
    - Function[line, StringStartsQ[line, "SAVED_IMAGE_PATH:"]]: Funzione esplicita. 'line' \[EGrave] l'argomento che rappresenta la riga corrente.
    - Missing["NotFound"]: Valore da restituire se nessuna riga soddisfa la condizione. *)
  
  savedCoordinates = SelectFirst[outputLines, Function[line, StringStartsQ[line, "DETECTED_POINTS:"]], Missing["NotFound"]];
(* Similmente, cerca la prima riga che inizia con "DETECTED_POINTS:". *)
  
  
	
  If[MissingQ[savedPathLine],
  (* Controlla se 'savedPathLine' \[EGrave] 'Missing["NotFound"]' (cio\[EGrave] la riga non \[EGrave] stata trovata). *)
  
      Print["\:274c Errore: Impossibile trovare la riga 'SAVED_IMAGE_PATH:' nell'output dello script Python."];
      (* Stampa un messaggio di errore. *)
      
      Return[$Failed];
      (* Termina e restituisce '$Failed'. *)
  ];
  
  If[MissingQ[savedCoordinates],
  (* Controlla se 'savedCoordinates' \[EGrave] 'Missing["NotFound"]'. *)
  
      Print["\:274c Errore: Impossibile trovare la riga 'DETECTED_POINTS:' nell'output dello script Python."];
      (*Stampa un messaggio di errore. *)
          
      Return[$Failed];
      (* Termina e restituisce '$Failed'. *)
  ];

  (* Estrai il percorso del file dall'output *)
  outputImagePath = StringTrim[savedPathLine, "SAVED_IMAGE_PATH:"];
  (* Rimuove il prefisso "SAVED_IMAGE_PATH:" dalla stringa 'savedPathLine' per ottenere il percorso puro dell'immagine. *)
  
  outputCoordinates = StringTrim[savedCoordinates, "DETECTED_POINTS:"];
  (* Rimuove il prefisso "DETECTED_POINTS:" da 'savedCoordinates' per ottenere la stringa delle coordinate. *)
  
	
  (* Verifica finale se il file immagine esiste davvero *)
  If[!FileExistsQ[outputImagePath],
  (* Controlla se il file immagine specificato da 'outputImagePath' NON esiste. *)
  
      Print["\:274c Errore Critico: Lo script ha indicato il percorso '", outputImagePath, "', ma il file non esiste!" ];
      (* Stampa un messaggio di errore critico. *)
      
      Return[$Failed];
      (* Termina e restituisce '$Failed'. *)
  ];


  (* Importa l'immagine risultante *)
  resultImage = Check[Import[outputImagePath], $Failed];
  (* Tenta di importare l'immagine dal percorso 'outputImagePath'. Se 'Import' fallisce, 'Check' fa s\[IGrave] che 'resultImage' diventi '$Failed'. *)


  If[FailureQ[resultImage] || !ImageQ[resultImage],
  (* Controlla se 'resultImage' \[EGrave] un oggetto 'Failure' (come '$Failed') o se non \[EGrave] un oggetto Immagine valido (ImageQ). *)
  
      Print["\:274c Errore: Impossibile importare l'immagine da '", outputImagePath, "' o il risultato non \[EGrave] un'immagine."];
      (* Stampa un messaggio di errore. *)
      
      Return[$Failed];
      (* Termina e restituisce '$Failed'. *)
  ];

 

    Return[<|"ResultImage" -> resultImage, "DetectedPoints" -> outputCoordinates|>] 
    (* Restituisce un'Associazione (simile a un dizionario/oggetto).
        - "ResultImage" -> resultImage: Associa la chiave "ResultImage" all'immagine importata.
        - "DetectedPoints" -> outputCoordinates: Associa la chiave "DetectedPoints" alla stringa delle coordinate.
        *)
]; 

(* piccola funzione helper che serve a controllare se miniconda \[EAcute] installato in locale
	variabili locali:
	- basePath rappresenta il path base in cui \[EGrave] installato miniconda nel file system
*)
CheckCondaInstallation[] := Module[{basePath},
	
    basePath = FileNameJoin[{$HomeDirectory, "miniconda3"}];
    (* Costruisce un percorso ipotetico per la directory base di Miniconda (assumendo si chiami "miniconda3" e sia nella home dell'utente). *)
    
    
    Return[DirectoryQ[basePath]]
    (* Restituisce 'True' se 'basePath' \[EGrave] una directory esistente, 'False' altrimenti. *)
    
  ] 

(* Funzione helper per verificare/creare l'ambiente Conda *)

EnsureCondaEnvFromFile[envName_String:"yolo_inference", envYmlPath_String : "environment.yml"] := 
(* Definizione della funzione helper 'EnsureCondaEnvFromFile'.
    - envName_String:"yolo_inference": Parametro nome ambiente, stringa, di default \[EAcute] "yolo_inference".
    - envYmlPath_String : "environment.yml": Parametro percorso file YML, stringa, di default \[EAcute] "environment.yml". *)
    
  Module[{minicondaPath, condaPath, envsDir, envDir, createProcess, createSuccess},
  (* Dichiarazione delle variabili locali:
        - minicondaPath: percorso base dell\[CloseCurlyQuote]installazione Miniconda (in home directory)
        - condaPath:    percorso completo all\[CloseCurlyQuote]eseguibile 'conda'
        - envsDir:      directory che contiene tutti gli ambienti Conda
        - envDir:       directory specifica per l\[CloseCurlyQuote]ambiente 'envName'
        - createProcess: risultati del processo esterno lanciato da RunProcess
        - createSuccess: Flag Boolean che indica se la creazione dell\[CloseCurlyQuote]ambiente \[EGrave] andata a buon fine
    *)


  minicondaPath = Switch[$OperatingSystem,
  (* Determina il percorso base di Miniconda in base al sistema operativo. *)
  
    "Windows"| "MacOSX" | "Unix", FileNameJoin[{$HomeDirectory, "miniconda3"}],
    (* Per i sistemi supportati, assume "miniconda3" nella home directory. *)
    
    _, Print["Unsupported OS"]; Return[$Failed];
    (* Se il SO non \[EGrave] supportato, stampa errore e termina. *)
  ];

  condaPath = FileNameJoin[{minicondaPath, "bin", "conda"}];
  (* Costruisce il percorso all'eseguibile 'conda' per sistemi non Windows. *)
  
  If[$OperatingSystem === "Windows",
  (* Se il sistema operativo \[EGrave] Windows... *)
  
    condaPath = FileNameJoin[{minicondaPath, "conda.exe"}]
    (* ...il percorso all'eseguibile \[EGrave] direttamente sotto 'minicondaPath' e si chiama 'conda.exe'.
     Nota: su Windows, spesso si trova in "Scripts/conda.exe" o "condabin/conda.bat" a seconda della versione/setup di Conda. *)
  ];



  envsDir = FileNameJoin[{minicondaPath, "envs"}];
  (* Percorso alla directory che contiene tutti gli ambienti Conda. *)
  
  envDir = FileNameJoin[{envsDir, envName}];
  (* Percorso specifico per l'ambiente 'envName'. *)
  

  If[DirectoryQ[envDir], Return[True]]; 
  (* Se la directory dell'ambiente ('envDir') esiste gi\[AGrave], la funzione termina immediatamente restituendo 'True'. 
  Questo significa che l'ambiente \[EGrave] considerato esistente e utilizzabile. *)

  (* Se non esiste l'ambiente, tenta di crearlo *)
   
    Print["Ambiente '", envName, "' non trovato. Tentativo di creazione da: ", envYmlPath, " (potrebbe richiedere tempo)..."];
    (* Stampa un messaggio che informa l'utente che l'ambiente non \[EGrave] stato trovato e si tenter\[AGrave] di crearlo. *)
    
    
    createProcess = RunProcess[{condaPath, "env", "create", "-f", envYmlPath, "-y"}];
    (* Esegue il comando 'conda env create' per creare l'ambiente dal file YML specificato.
        - "-f envYmlPath": Specifica il file di ambiente.
        - "-y": Risponde automaticamente 's\[IGrave]' a eventuali prompt. *)

    Print["--- Output Creazione Ambiente ---"];
    
    Print[createProcess["StandardOutput"]];
  
    If[StringLength[createProcess["StandardError"]] > 0, Print["--- Error Creazione Ambiente ---"]; Print[createProcess["StandardError"]];];
    (* Se c'\[EGrave] output di errore, stampa un'intestazione e l'errore stesso. *)
    
    Print["-------------------------------"];
   

    If[createProcess["ExitCode"] == 0,
    (* Se il codice di uscita del processo di creazione \[EGrave] 0 (successo) *)
    
    Print["Creazione ambiente '", envName, "' completata con successo."];
    (* Stampa un messaggio di successo. *)
    createSuccess = True,
    (* Imposta 'createSuccess' a 'True'. *)
    
    Print["Errore durante la creazione dell'ambiente '", envName, "' (Exit Code: ", createProcess["ExitCode"], "). Controlla l'output/error."];
    (* Altrimenti (se il codice di uscita non \[EGrave] 0), stampa un messaggio di errore. *)
    
    createSuccess = False
    (* Imposta 'createSuccess' a 'False'. *)
    
    ];
    Return[createSuccess]
    (* Restituisce lo stato di successo ('True' o 'False') della creazione. *)
  ] 



End[]
EndPackage[]

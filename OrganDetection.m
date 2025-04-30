(* ::Package:: *)

 


(*:Title: OrganDetection *)
(*:Context: OrganDetection` *)
(*:Authors: Giuseppe Spathis, Federico Augelli, Emanuele Di Sante, ... *)
(*:Summary: Organ detection based on ultrasound images using deep learning algorithms, implemented in Wolfram Mathematica. *)
(*:Copyright: GS 2025 da sistemare *)
(*:Package Version: 1 *)
(*:Mathematica Version: 14 ...da vedere *)
(*:History: last modified 14/3/2025 ... da sistemare *)
(*:Keywords: Organ detection, ultrasound images *)
(*:Sources: biblio *)
(*:Limitations: this is for educational purposes only. *)
(*:Discussion: *)
(*:Requirements: *)
(*:Warning: package Context is not defined *)

BeginPackage["ObjectDetection`"]

ResourceFunction["DarkMode"][]

(* Definition of public functions *)
MaskToXML::usage = "pippo"
XMLToMask::usage = "pippo"
(*
Normalize::usage = "Normalize[f, {x0, x1, ...}]
	test function for normalizing functions"
*)
Inference::usage = "Inference[f, g, h]
	function for inference of the model"

Begin["Private`"]

(* Implementation of all function *)
(*
Normalize[] :=
Module[],

code...
*)



Inference[ Optional[imageToProcessPath_String?(FileExistsQ), Null] ] := Module[
  {condaOK, envName, ymlPath, envOK, pythonExecutablePath, resultImage,
   scriptPath, modelWeightsPath, effectiveImageToProcessPath, basePath,
   pythonSubPath}, (* Variabili locali *)

  envName = "yolo_inference";
  ymlPath =  "environment.yml";
  scriptPath = "inference.py";
  modelWeightsPath = "best.pt";

  (* Usa l'immagine passata come argomento, o un default se l'argomento \[EGrave] Null *)
  effectiveImageToProcessPath = If[imageToProcessPath === Null,
        "uno100.jpg", (* Immagine di default *)
        imageToProcessPath (* Immagine specificata *)
    ];

  (* 0. Controlla file necessari *)
  If[! FileExistsQ[ymlPath], Print["Errore: environment.yml non trovato."]; Return[$Failed]];
  If[! FileExistsQ[scriptPath], Print["Errore: inference.py non trovato."]; Return[$Failed]];
  If[! FileExistsQ[modelWeightsPath], Print["Errore: best.pt non trovato."]; Return[$Failed]];
  If[! FileExistsQ[effectiveImageToProcessPath], Print["Errore: Immagine input non trovata: ", effectiveImageToProcessPath]; Return[$Failed]];

  (* 1. Controlla Conda 
  condaOK = CheckCondaInstallation[];
  If[! condaOK, Print["Installare Miniconda."]; Return[$Failed]];

  (* 2. Controlla/Crea Ambiente *)
  envOK = EnsureCondaEnvironment[envName, ymlPath];
  If[! envOK, Print["Impossibile usare l'ambiente Conda '", envName, "'."]; Return[$Failed]];
*)
  (* 3. Trova l'eseguibile Python nell'ambiente creato/verificato *)
  (* Assumiamo miniconda3 come base, CAMBIA SE HAI ANACONDA3 *)

  pythonExecutablePath = GetUserPythonExecutable["miniconda3", envName];
  If[FailureQ[pythonExecutablePath],
      Print["Impossibile trovare l'eseguibile Python per l'ambiente '", envName, "'."];
      Return[$Failed]
  ];
  
  basePath = FileNameJoin[{$HomeDirectory, "miniconda3", "envs", envName}];
    pythonSubPath = Switch[$OperatingSystem,
        "Windows", "python.exe",
        "MacOSX" | "Unix", FileNameJoin[{"bin", "python"}],
        _, Print["OS non supportato per GetUserPythonExecutable"]; Return[$Failed]
    ];
    pythonExecutablePath = FileNameJoin[{basePath, pythonSubPath}];
    
  Print["Eseguibile Python per l'ambiente trovato: ", pythonExecutablePath];

	
  (* 4. Esegui Inferenza usando il percorso specifico *)
  Print["\nAvvio inferenza usando l'eseguibile Python specifico..."];
  resultImage = RunInferenceWithExecutable[
      pythonExecutablePath, (* Passa il percorso specifico trovato *)
      scriptPath,
      modelWeightsPath,
      effectiveImageToProcessPath  (* Usa il percorso dell'immagine determinato *)
  ];
  
  

  (* 5. Gestisci Risultato Inferenza *)
  If[ImageQ[resultImage],
    Print["Inferenza completata con successo!"];
    resultImage (* Restituisce l'immagine *)
    ,
    Print["Inferenza fallita."];
    $Failed
  ]
]

(* funzioni helper *)

RunInferenceWithExecutable[
    pythonExecutable_String?FileExistsQ,
    scriptPath_String?FileExistsQ,
    modelWeightsPath_String?FileExistsQ,
    imageToProcessPath_String?FileExistsQ] := Module[
    {
     process, commandArgs, exitCode, outputLog, errorLog, outputLines,
     savedPathLine, outputImagePath, resultImage, startTime, endTime, duration
     },

    Print["  \:23f3 Avvio processo Python..."];

    (* Definisci gli argomenti per lo script Python *)
    (* Assicurati che questi corrispondano a quelli attesi da inference.py *)
    commandArgs = {
       scriptPath,
       "--weights", modelWeightsPath,
       "--image", imageToProcessPath
       (* Puoi aggiungere altri argomenti qui se necessario, es: *)
       (* , "--conf", "0.6" *)
    };

    (* Esegui il processo esterno *)
    process = RunProcess[
        Join[{pythonExecutable}, commandArgs],
        ProcessDirectory -> NotebookDirectory[] (* Esegui nella directory del Notebook *)
    ];
   

    (* Recupera output, errori e codice di uscita *)
    exitCode = process["ExitCode"];
    outputLog = process["StandardOutput"];
    errorLog = process["StandardError"];


    (* Controlla se il processo \[EGrave] terminato con successo *)
    If[exitCode =!= 0,
        Print["\:274c Errore: Lo script Python \[EGrave] terminato con codice di uscita non zero: ", exitCode];
        Print["   Controllare l'output e l'errore standard sopra per i dettagli."];
        Return[$Failed]
    ];

    (* Cerca il percorso dell'immagine salvata nell'output standard *)
    outputLines = StringSplit[outputLog, {"\n", "\r\n", "\r"}]; (* Gestisce diversi tipi di newline *)
    savedPathLine = SelectFirst[outputLines, StringStartsQ[#, "SAVED_IMAGE_PATH:"] &, Missing["NotFound"]];

    If[MissingQ[savedPathLine],
        Print["\:274c Errore: Impossibile trovare la riga 'SAVED_IMAGE_PATH:' nell'output dello script Python."];
        Print["   Assicurati che lo script '", FileNameTake[scriptPath], "' stampi correttamente il percorso."];
        Return[$Failed];
    ];

    (* Estrai il percorso del file dall'output *)
    outputImagePath = StringTrim[savedPathLine, "SAVED_IMAGE_PATH:"];

    (* Verifica finale se il file immagine esiste davvero *)
    If[!FileExistsQ[outputImagePath],
        Print["\:274c Errore Critico: Lo script ha indicato il percorso '", outputImagePath, "', ma il file non esiste!" ];
        Return[$Failed];
    ];

    (* Importa l'immagine risultante *)
    resultImage = Check[Import[outputImagePath], $Failed];

    (* Controlla se l'importazione \[EGrave] andata a buon fine e se \[EGrave] un'immagine *)
    If[FailureQ[resultImage] || !ImageQ[resultImage],
        Print["\:274c Errore: Impossibile importare l'immagine da '", outputImagePath, "' o il risultato non \[EGrave] un'immagine."];
        Return[$Failed];
    ];

    Print["\:2705 Immagine importata con successo!"];

    Return[resultImage] (* Restituisce l'immagine importata *)

];

CheckCondaInstallation[] := Module[{process, exitCode},
   Print["Verifica installazione Conda..."];
   process = RunProcess[{"conda", "--version"}, ProcessDirectory -> NotebookDirectory[]];
   exitCode = process["ExitCode"];
   If[exitCode == 0,
    Print["Conda trovato: ", StringTrim@process["StandardOutput"]]; True,
    Print["Comando 'conda' non trovato o non funzionante. Assicurati che Miniconda/Anaconda sia installato e nel PATH di sistema."]; False
   ]
  ]

(* Funzione per verificare/creare l'ambiente Conda *)
EnsureCondaEnvironment[envName_String, ymlFile_String?FileExistsQ] := Module[
   {condaExe = "conda", envListProcess, envListOutput, envExists = False, createProcess, createSuccess = False},

   Print["Verifica esistenza ambiente Conda: '", envName, "'..."];
   envListProcess = RunProcess[{condaExe, "info", "--envs"}];
   If[envListProcess["ExitCode"] =!= 0,
    Print["Errore nell'eseguire 'conda info --envs'."]; Return[False]
   ];
   envListOutput = envListProcess["StandardOutput"];
   (* Cerca il nome ambiente seguito da spazio o alla fine riga *)
   envExists = StringContainsQ[envListOutput, envName ~~ (" " | EndOfLine)];

   If[envExists,
    Print["Ambiente '", envName, "' trovato."];
    Return[True]
   ];

   (* Se non esiste, tenta di crearlo *)
   Print["Ambiente '", envName, "' non trovato. Tentativo di creazione da: ", ymlFile, " (potrebbe richiedere tempo)..."];
   createProcess = RunProcess[{condaExe, "env", "create", "-f", ymlFile, "-y"}, TimeConstraint -> 1800]; (* Timeout 30 min *)

   Print["--- Output Creazione Ambiente ---"];
   Print[createProcess["StandardOutput"]];
   If[StringLength[createProcess["StandardError"]] > 0, Print["--- Error Creazione Ambiente ---"]; Print[createProcess["StandardError"]];];
   Print["-------------------------------"];

   If[createProcess["ExitCode"] == 0,
    Print["Creazione ambiente '", envName, "' completata con successo."];
    createSuccess = True,
    Print["Errore durante la creazione dell'ambiente '", envName, "' (Exit Code: ", createProcess["ExitCode"], "). Controlla l'output/error."];
    createSuccess = False
   ];
   Return[createSuccess]
  ]

(* Funzione helper per trovare l'eseguibile Python nell'ambiente specificato *)
(* Prende il nome della cartella base di conda (es. "miniconda3") e il nome dell'ambiente *)
GetUserPythonExecutable[condaBaseDirName_String:"miniconda3", envName_String _] := Module[
    {basePath, pythonSubPath, fullPath},
    basePath = FileNameJoin[{$HomeDirectory, condaBaseDirName, "envs", envName}];
    pythonSubPath = Switch[$OperatingSystem,
        "Windows", "python.exe",
        "MacOSX" | "Unix", FileNameJoin[{"bin", "python"}],
        _, Print["OS non supportato per GetUserPythonExecutable"]; Return[$Failed]
    ];
    fullPath = FileNameJoin[{basePath, pythonSubPath}];

    (* Verifica finale se il file esiste effettivamente *)
    If[FileExistsQ[fullPath],
        Return[fullPath],
        Print["Errore: Eseguibile Python NON trovato al percorso calcolato: ", fullPath];
        Return[$Failed]
    ]
];



(* Fine tuning function 
FineTune[] :=
Module[
  {
   baseModel, trainingData, validationData, fineTunedNet, modelResource, fullNet, maskHead,
   clsLoss, boxLoss, maskLoss, trainingNet, modelRes, detectUninit, frozenNet, protoNet
   },
   
  (*ResourceRemove[ResourceObject["YOLO V8 Segment Trained on MS-COCO Data"]]*)
  Print["downloading..."];
  baseModel = NetModel["YOLO V8 Segment Trained on MS-COCO Data", "UninitializedEvaluationNet"];

Print[Information[baseModel]];
Print[NetGraph[baseModel]];

decoderLayer = NetExtract[baseModel, "Decoder"];

Print[NetGraph[decoderLayer]];
  
(* Verifica se il caricamento \[EGrave] andato a buon fine *)
If[FailureQ[baseModel],
    Print["Errore: Impossibile caricare il modello base YOLO V8."];
    Throw[$Failed]; (* Interrompi l'esecuzione se il modello non carica *)
];
Print["Base model loaded successfully."];


(* --- Prepara i dati usando la tua funzione --- *)
Print["Preparing datasets..."];
{trainingData, validationData} = PreprocessingForFineTuning[];



(* Verifica che i set non siano vuoti *)
If[Length[trainingData] == 0 || Length[validationData] == 0,
    Print["Errore: Uno dei set di dati (training o validation) \[EGrave] vuoto dopo il preprocessing."];
    Throw[$Failed];
];
Print["Datasets ready."];


(* --- Esegui il Fine-Tuning --- *)
Print["Starting fine-tuning for 100 epochs..."];

(*Print[trainingData, validationData]*)

(* Imposta un seed per NetTrain se desideri riproducibilit\[AGrave] anche nell'addestramento *)
SeedRandom[5678];




fineTunedNet = NetTrain[
  baseModel,
  trainingData,
  All,
  ValidationSet -> validationData,
  BatchSize -> 4,
  MaxTrainingRounds -> 50,
  LearningRate -> 0.0001,
  TargetDevice -> "CPU"
];
Print["Fine-tuning process completed."];

(* Verifica se NetTrain ha prodotto un risultato valido *)
If[FailureQ[fineTunedNet],
    Print["Errore: NetTrain non \[EGrave] riuscito a completare l'addestramento."];
    {
 {Print[Internal`$LastInternalFailure];}
}
    Throw[$Failed];
];

Print["Fine-tuned model created successfully!"];
Print["Il modello fine-tuned \[EGrave] ora disponibile nella variabile 'fineTunedNet'."];
]
*)


(* Defnition of auxiliary functions *)
(*
AuxFunction[] := 
Module[]
*)
(*
MaskToXML[maskPath_String, xmlPath_String] := Module[
  {img, grayImg, binImg, whitePixelCoordsYX, whitePixelCoordsXY, xml, doc},

  Print["Attempting to import: ", maskPath];
  img = Import[maskPath];
  {width, height} = ImageDimensions[img];
  (* Check if import was successful *)
  If[!ImageQ[img],
    Print["Error: Failed to import image or not a valid image object from ", maskPath];
    Return[$Failed]; (* Esce dalla funzione se l'import fallisce *)
  ];

  Print["Image imported successfully. Converting to grayscale..."];
  grayImg = ColorConvert[img, "Grayscale"];

  Print["Binarizing image..."];
  (* Assicurati che Binarize produca pixel 0 (neri) e 1 (bianchi) *)
  binImg = Binarize[grayImg, 0.5]; (* Puoi aggiustare la soglia 0.5 se necessario *)

  Print["Finding white pixel coordinates (value = 1)..."];
  (* PixelValuePositions restituisce le coordinate come {riga, colonna}, che corrisponde a {y, x} *)
  whitePixelCoordsYX = PixelValuePositions[binImg, 1];

  (* Controlla se sono stati trovati pixel bianchi *)
  If[whitePixelCoordsYX === {},
     Print["Warning: No white pixels (value=1) found after binarization in ", maskPath];
     (* Crea una annotazione XML vuota se non ci sono pixel bianchi *)
     xml = XMLElement["annotation", {}, {}];
  ,
     (* Se sono stati trovati pixel bianchi *)
     Print[Length[whitePixelCoordsYX], " white pixels found."];

     (* Converte la lista da {y, x} a {x, y} per l'XML *)
     (* Usiamo Reverse per ogni coppia {y,x} -> {x,y} *)
     (*whitePixelCoordsXY = Reverse /@ whitePixelCoordsYX;*)
     whitePixelCoordsXY = whitePixelCoordsYX;

     Print["Generating XML structure for pixel coordinates..."];
     xml = XMLElement["annotation", {}, { (* Un solo elemento annotation *)
       XMLElement["object", {}, {         (* Un solo elemento object *)
         XMLElement["pointcloud", {},     (* Sostituisce <polygon> con <pointcloud> *)
           Table[ (* Crea un elemento <pt> per ogni pixel bianco *)
             XMLElement["pt", {}, {
               XMLElement["x", {}, {ToString[Round[p[[1]]]]}], (* x \[EGrave] la colonna *)
               XMLElement["y", {}, {ToString[Round[height-p[[2]]]]}]  (* y \[EGrave] la riga *)
             }],
             {p, whitePixelCoordsXY} (* Itera sulla lista di coordinate {x, y} *)
           ]
         ]
       }]
     }];
   ]; (* Fine del blocco If whitePixelCoordsYX === {} *)


  Print["Exporting XML to: ", xmlPath];
  doc = ExportString[xml, "XML", "ElementFormatting" -> Automatic];
  Export[xmlPath, doc, "Text"];
  Print["XML Export complete."];

]
XMLToMask[xmlPath_String, imageWidth_Integer?Positive, imageHeight_Integer?Positive, outputImagePath_String] := Module[
  {xmlObj, rootXMLElement, ptElements, coordsXYStr, coordsXY, coordsYX, rules, imgData, maskImage, validCoords},

  Print["Checking file existence for: ", xmlPath];
  Print["File exists: ", FileExistsQ[xmlPath]];

  If[!FileExistsQ[xmlPath],
     Print["Error: File does not exist at path: ", xmlPath];
     Return[$Failed];
  ];

  Print["Importing XML from: ", xmlPath];
  xmlObj = Import[xmlPath, "XMLObject"];

 


  (* Controlla se Import ha restituito la struttura XMLObject["Document"] attesa *)
  (* La struttura \[EGrave] XMLObject["Document"][prolog, rootElement, epilog] *)
  (* Verifichiamo che il rootElement sia un XMLElement *)
  If[!MatchQ[xmlObj, XMLObject["Document"][_, _XMLElement, _]],
     Print["Error: Failed to import XML or unexpected XMLObject structure from ", xmlPath ];
     Return[$Failed];
  ];

  (* Estrai il vero elemento radice XML (es. <annotation>...) *)
  (* \[CapitalEGrave] il secondo elemento della struttura XMLObject["Document"] *)
  rootXMLElement = xmlObj[[2]];

  Print["Extracting pixel coordinates from XML root element..."];
  (* Cerca gli elementi <pt> all'interno dell'elemento radice estratto *)
  ptElements = Cases[rootXMLElement,
    XMLElement["pt", _, {XMLElement["x", _, {x_String}], XMLElement["y", _, {y_String}]}],
    Infinity (* Cerca a qualsiasi profondit\[AGrave] *)
  ];

  (* --- Il resto del codice da qui in poi rimane invariato --- *)

  (* Controlla se sono stati trovati elementi <pt> *)
  If[ptElements === {},
     Print["Warning: No <pt> elements with <x> and <y> found in XML file: ", xmlPath];
     imgData = ConstantArray[0, {imageHeight, imageWidth}];
     validCoords = 0;
  ,
     (* Estrai le coppie di stringhe {x, y} *)
     coordsXYStr = ptElements /. XMLElement["pt", _, {XMLElement["x", _, {x_String}], XMLElement["y", _, {y_String}]}] -> {x, y};

     (* Converti le stringhe in numeri (coordinate x, y) *)
     coordsXY = Quiet @ Check[ToExpression[#], $Failed] & /@ coordsXYStr;
     coordsXY = DeleteCases[coordsXY, {$Failed, _} | {_, $Failed} | $Failed];

     (* Converti in coordinate {riga, colonna} == {y, x} intere *)
     coordsYX = {Round[#[[2]]], Round[#[[1]]]} & /@ coordsXY;

     (* Filtra le coordinate per assicurarsi che siano dentro i limiti *)
     coordsYX = Select[coordsYX, (1 <= #[[1]] <= imageHeight && 1 <= #[[2]] <= imageWidth) &];
     validCoords = Length[coordsYX];

     If[validCoords == 0,
        Print["Warning: No valid coordinates found within image bounds [", imageWidth, "x", imageHeight, "] after filtering."];
        imgData = ConstantArray[0, {imageHeight, imageWidth}];
     ,
        Print[validCoords, " valid pixel coordinates extracted."];
        (* Crea le regole per SparseArray: {riga, colonna} -> valore (1 per bianco) *)
        rules = (# -> 1) & /@ coordsYX;
        Print["Creating image data (Width=", imageWidth, ", Height=", imageHeight, ")..."];
        imgData = SparseArray[rules, {imageHeight, imageWidth}, 0];
     ]
  ];

  Print["Converting data to Image object..."];
  maskImage = Image[imgData];
  

  Print["Exporting image to: ", outputImagePath];
  Export[outputImagePath, maskImage, "JPG"];
  Print["Image export complete."];

  Return[maskImage];

]


PreprocessingForFineTuning[] :=
 Module[
  {
   imageDir, maskDir, imageFiles, maskFiles,
   getId, imageIDs, maskIDs,
   imagePaths, maskPaths, numTraining,
   commonIDs, classNames, numClasses, listToSample,
   inputImageSize, dataList, dataset, trainingData, validationData
   },

  (* Define directories *)
  imageDir = "dataset/originali01";
  maskDir = "dataset/groundtruth01";
  Print["Current Directory: ", Directory[]]; (* Check working directory *)
  Print["Image Directory: ", ExpandFileName[imageDir]]; (* Check absolute path *)
  Print["Mask Directory: ", ExpandFileName[maskDir]];   (* Check absolute path *)


  (* Find files *)
  imageFiles = FileNames["uno*.jpg", imageDir];
  Print["Found ", Length[imageFiles], " image files. First 5: ", Take[imageFiles, 5]]; (* DEBUG *)
  maskFiles = FileNames["unogt*.jpg", maskDir];
  Print["Found ", Length[maskFiles], " mask files. First 5: ", Take[maskFiles, 5]]; (* DEBUG *)

  (* Function to extract numeric ID from filename *)
  getId[file_, prefix_] :=
   StringReplace[
    FileBaseName[file],
    {prefix -> "", ".jpg" -> ""} (* Ensure .jpg is removed correctly *)
   ];

  (* Extract IDs *)
  imageIDs = getId[#, "uno"] & /@ imageFiles;
  Print["Extracted ", Length[imageIDs], " image IDs. First 10: ", Take[imageIDs, 10]]; (* DEBUG *)
  maskIDs = getId[#, "unogt"] & /@ maskFiles;
  Print["Extracted ", Length[maskIDs], " mask IDs. First 10: ", Take[maskIDs, 10]]; (* DEBUG *)


  (* Build associations: ID -> full path *)
  imagePaths = AssociationThread[imageIDs, imageFiles];
  maskPaths = AssociationThread[maskIDs, maskFiles];

  (* Match on common numeric IDs *)
  commonIDs = Intersection[Keys[imagePaths], Keys[maskPaths]];
  Print["Found ", Length[commonIDs], " common IDs. First 10: ", Take[commonIDs, 10]]; (* CRITICAL DEBUG *)

  (* === If Length[commonIDs] is 0 here, the rest will fail === *)
  If[Length[commonIDs] == 0,
     Print["Error: No common IDs found between images and masks. Cannot proceed."];
     Return[$Failed]; (* Stop execution *)
  ];


  (* Define classes *)
  classNames = {"background", "tiroide"};
  numClasses = Length[classNames]; (* Usually numClasses = number of actual classes + background *)
                 (* Check if NetTrain needs numClasses or numClasses+1 depending on background handling *)


  (* Set input image size for preprocessing (adjust as needed) *)
  inputImageSize = {640, 640};

  (* Create the list of preprocessed samples *)
  Print["Preprocessing samples..."];
  dataList = Table[
     Check[ (* Added Check to see if preprocessSample fails *)
        preprocessSample[imagePaths[id], maskPaths[id], inputImageSize],
        $FailedPreprocess],
     {id, commonIDs}
  ];
  Print["Preprocessing complete. dataList length: ", Length[dataList]]; (* DEBUG *)
  Print["Number of failed preprocess steps: ", Count[dataList, $FailedPreprocess]]; (* DEBUG *)
  dataList = DeleteCases[dataList, $FailedPreprocess]; (* Remove failed samples *)
  Print["dataList length after removing failures: ", Length[dataList]]; (* DEBUG *)

  (* === If dataList is empty here (e.g., all preprocess failed), the rest will fail === *)
   If[Length[dataList] == 0,
     Print["Error: dataList is empty after preprocessing. Cannot proceed."];
     Return[$Failed]; (* Stop execution *)
  ];


  (* Create dataset object *)
  dataset = Dataset[dataList];
  Print["Dataset created. Length: ", Length[dataset]]; (* DEBUG *)


Print["Converting dataset to Normal list before sampling..."];
listToSample = Normal[dataset];
Print["Length of listToSample: ", Length[listToSample]];
Print["Dimensions of listToSample: ", Dimensions[listToSample]];

numTraining = Floor[0.8 * Length[listToSample]];
trainingData = RandomSample[listToSample, numTraining];

validationData = Complement[listToSample, trainingData];

Print["RandomSample completed successfully."]; (* Add confirmation *)

  Print["Numero campioni training: ", Length[trainingData]];
  Print["Numero campioni validation: ", Length[validationData]];

  (* Return something useful, e.g., the split datasets *)
  (*<|"Training" -> trainingData, "Validation" -> validationData|>                          Cambio perche import non corretto*)
  {trainingData, validationData}
 ]
 preprocessSample[imgFile_, maskFile_, inputImageSize_] := Module[{img, mask, targetData, comp,
 bboxList,boundingBox, xmin, ymin, xmax, ymax, classNames, classIndex},
   img = Import[imgFile];
   mask = Import[maskFile];
   mask = ColorConvert[mask, "Grayscale"];
   
   mask = Binarize[mask];

   (* Ridimensiona se necessario *)
   img = ImageResize[img, inputImageSize];
   mask = ImageResize[mask, inputImageSize, Resampling -> "Nearest"]; (* Usa Nearest per non alterare gli indici! *)
   (* etichetta le componenti con MorphologicalComponents *)
	comp      = MorphologicalComponents[mask];
	(* misuro la bounding\[Hyphen]box della componente \[OpenCurlyDoubleQuote]1\[CloseCurlyDoubleQuote]  *)
	bboxList  = ComponentMeasurements[comp, "BoundingBox"];
	(* bboxList \[EGrave] tipo {{1 -> {l,b,w,h}}}, ne estraggo i valori *)
	{{xmin, ymin}, {xmax, ymax}} = First[bboxList][[2]];
	xmin = Round[xmin];
	ymin = Round[ymin];
	xmax = Round[xmax];
	ymax = Round[ymax];

	(* e costruisci il Rectangle *)
	boundingBox = Rectangle[{xmin, ymin}, {xmax, ymax}];
	   
	classNames = {"background", "tiroide"};
	classIndex = Position[classNames, "tiroide"][[1, 1]];
	<|
  "Input"  -> img,
  "Target" -> <|
     "Boxes"   -> {{xmin,ymin,xmax,ymax}},
     "Classes" -> {classIndex},
     "Masks" -> {mask}
  |>
|>



   (* Restituisci l'associazione per NetTrain 
    <|"Input" -> img, "Target" -> mask|>*)
    
];*)



End[]
EndPackage[]

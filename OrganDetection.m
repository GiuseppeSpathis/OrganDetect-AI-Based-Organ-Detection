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
FineTune::usage = "FineTune[f, g, h]
	function for fine tuning the model"

Begin["Private`"]

(* Implementation of all function *)
(*
Normalize[] :=
Module[],

code...
*)


(* Fine tuning function *)
FineTune[] :=
Module[
  {
   baseModel, trainingData, validationData, fineTunedNet, modelResource
   },
   
  (*ResourceRemove[ResourceObject["YOLO V8 Segment Trained on MS-COCO Data"]]*)
  Print["downloading..."];
  baseModel = NetModel["YOLO V8 Segment Trained on MS-COCO Data"]; 


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

inputSpec = Information[baseModel, "InputPorts"];
outputSpec = Information[baseModel, "OutputPorts"];
Print["Input specification: ", inputSpec];
Print["Output specification: ", outputSpec];

fineTunedNet = NetTrain[
    baseModel,                      (* Modello da cui partire *)
    trainingData,                   (* Dati di addestramento *)
    All,                            (* Fine-tuning: addestra tutti i layers partendo dai pesi attuali *)
    ValidationSet -> validationData, (* Dati per la validazione *)
    MaxTrainingRounds -> 100,       (* Numero di epoche *)

    (* --- Opzioni Consigliate --- *)
    TargetDevice -> "CPU",          (* Usa la GPU se disponibile, altrimenti "CPU" *)
    BatchSize -> 8,                 (* Prova valori come 4, 8, 16 in base alla memoria GPU *)
                                    (* Se ottieni errori Out-of-Memory, riduci il BatchSize *)
    LearningRate -> 10^-4         (* Learning rate iniziale per fine-tuning (prova 10^-4 o 10^-5) *)
                                    (* Potrebbe richiedere aggiustamenti *)
];
Print["Fine-tuning process completed."];

(* Verifica se NetTrain ha prodotto un risultato valido *)
If[FailureQ[fineTunedNet],
    Print["Errore: NetTrain non \[EGrave] riuscito a completare l'addestramento."];
    Throw[$Failed];
];

Print["Fine-tuned model created successfully!"];
Print["Il modello fine-tuned \[EGrave] ora disponibile nella variabile 'fineTunedNet'."];
]


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
*)

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
  inputImageSize = {353, 253};

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
 preprocessSample[imgFile_, maskFile_, inputImageSize_] := Module[{img, mask},
   img = Import[imgFile];
   mask = Import[maskFile];
   mask = ColorConvert[mask, "Grayscale"];
   
   mask = Binarize[mask];

   (* Ridimensiona se necessario *)
   img = ImageResize[img, inputImageSize];
   mask = ImageResize[mask, inputImageSize, Resampling -> "Nearest"]; (* Usa Nearest per non alterare gli indici! *)

   (* Restituisci l'associazione per NetTrain *)
    <|"Input" -> img, "Target" -> mask|>
];



End[]
EndPackage[]

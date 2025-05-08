(* ::Package:: *)

(* ::Package:: *)
(* File: OrganDetectionUI.m *)
(* Descrizione: Package per l'interfaccia utente di Organ Detection *)


BeginPackage["OrganDetectionUI`"];


(* ::Usage:: *)
(**)


LaunchOrganDetectionUI::usage = "LaunchOrganDetectionUI[] avvia l'interfaccia utente grafica per lo strumento di rilevamento degli organi.";


(* ::Subsubsection:: *)
(* Inizia la sezione privata del package *)


Begin["`Private`"];

(* Package OrganDetection.m *)
Get["OrganDetection.m"];

(* Definizione della funzione pubblica che crea e lancia la UI *)
LaunchOrganDetectionUI[] := DynamicModule[
  {
    file = "",
    fileSet = False,
    errorMsg = "",
    imgPreview = None,
    originalImg = None, (* Questa variabile serve per memorizzare l'immagine da analizzare *)
    detectedPoints = {}, (* Lista per l'inserimento delle coordinate dei vertici della maschera della tiroide*)
    editMode = False, (* Variabile booleana per attivare/disattivare la sezione di modifica della maschera della tiroide *)
    isProcessing = False,
    updateFileState,
    organDetect,
    taskObject = None
  },


(* Funzione di aggiornamento dello stato dell'immagine *)
  updateFileState[newFile_String] := (
    file = newFile;
    errorMsg = "";
    imgPreview = None; (* Reset dell'anteprima dell'immagine *)
    detectedPoints = {}; (* Reset punti rilevati *)
    fileSet = False; (* Reset dello stato del file *)
    isProcessing = False;
    (* Rimuovi il reset di showMessage: showMessage = False; *)

    If[StringTrim[file] == "", Return[]]; (* Esci se il percorso del file \[EGrave] vuoto *)

    If[FileExistsQ[file],
      Module[{ext = ToLowerCase@FileExtension[file], importedContent},
        If[StringMatchQ[ext, "png" | "jpg" | "jpeg"],
          Check[
            importedContent = Import[file]; 
            If[ImageQ[importedContent],
              imgPreview = importedContent;
              originalImg = importedContent; (* Viene assegnata l'immagine "importedContent" alla variabile "originalImg" *)
              fileSet = True;,
              errorMsg = "File non \[EGrave] un'immagine PNG/JPG valida.";
              imgPreview = None;
              originalImg = None; (* La variabile "originalImg" \[EGrave] None, se "importedContent" non \[EGrave] in un formato immagine valido*)
              ],
            errorMsg = "Errore durante l'importazione dell'immagine.";
            imgPreview = None;
            originalImg = None; (* La variabile "originalImg" \[EGrave] None, se c'\[EGrave] stato un errore durante l'importazione dell'immagine*)
            ];
          ,
          errorMsg = "Tipo file non supportato (solo .png, .jpg, .jpeg).";
          imgPreview = None;
          originalImg = None; (* La variabile "originalImg" \[EGrave] None, se il tipo di file non \[EGrave] supportato*)
          ];
        ],
      errorMsg = "File non trovato.";
      imgPreview = None;
      originalImg = None; (* La variabile "originalImg" \[EGrave] None, se non esiste alcun file con quel nome*)
      ];
    If[errorMsg =!= "", fileSet = False]; (* Aggiorna fileSet se c'\[EGrave] stato un errore *)
    );


 (* Funzione di rilevamento degli organi *)
  organDetect[imagePath_String] := Module[{detectionResult},
    detectionResult = Check[
      OrganDetection[imagePath],
      "Errore durante l'esecuzione di OrganDetection."
     ];
     
    (* Aggiorna imgPreview con la nuova immagine, ovvero, il risultato del rilevamento *)
    imgPreview = detectionResult["ResultImage"];
    
    (* Converte da stringa ad array, la lista delle coordinate dei vertici della maschera della tiroide rilevata*)
    detectedPoints = ToExpression[detectionResult["DetectedPoints"]];
    
    (* Si mantiene editMode a False dopo il rilevamento per mostrare il risultato *)
    editMode = False;
    
	(* Questo blocco apre una finestra di dialogo per notificare la mancata rilevazione di tiroidi. *)
	If[Length[detectedPoints] == 0,
	    (* Funzione che apre una nuova finestra di dialogo con l'utente. *)
	    CreateDialog[
	      Panel[
	        Grid[{
	          {Style["Nessun organo tiroideo rilevato!!", Red, 14]},
	          {Spacer[{0, 15}]},
	          {DefaultButton[]}
	        }, Alignment -> {Center, Center}, Spacings -> {0, 2}],
	        ImageSize -> 280,
	        Alignment -> Center
	      ],
	      WindowTitle -> "Risultato Detection",
	      WindowSize -> {300, 150},
	      WindowMargins -> {{Automatic, Automatic}, {Automatic, Automatic}},
	      WindowElements -> {"StatusArea" -> False},
	      Background -> White
	    ];
	];
	];


  (* UI - Creazione della finestra di dialogo *)
  CreateDialog[
    Panel[
      Item[
        Column[{
          (* Titolo dell'app *)
          Style[" Organ Detection Tool", 30, Bold, FontFamily -> "Helvetica"],
          Spacer[20],

          (* Seleziona file immagine *)
          Row[{
            Style["Seleziona file immagine: ", 16],
            FileNameSetter[
              Dynamic[file, (updateFileState[#]) &],
              "Open",
              {"Immagini (PNG, JPG)" -> {"*.png", "*.jpg", "*.jpeg"}}
              ]
            }, Spacer[10]],

          (* Stato del file selezionato *)
          Dynamic[
            If[fileSet,
              Style["File selezionato: " <> FileNameTake[file], Darker@Green, 14],
              If[errorMsg != "", Style[errorMsg, Red, 14], Style["Nessun file selezionato.", Gray, 14]]
              ]
            ],

          Spacer[15],

          (* Anteprima/Modifica immagine selezionata *)
          Dynamic[
          (* Se \[EGrave] presente un'immagine di anteprima, allora pu\[OGrave] essere mostrata la sezione *)
            If[ImageQ[imgPreview],
            (* La variabile *)
              If[editMode == False,
                (* Modalit\[AGrave] Anteprima *)
                Column[{
                  Style["Anteprima: (Clicca per ingrandire)", Italic, 16],
                  Button[
                    Dynamic[Image[imgPreview, ImageSize -> 353]], +
                    CreateDialog[
                      Image[imgPreview, ImageSize -> Full],
                      WindowTitle -> "Anteprima Ingrandita - " <> FileNameTake[file],
                      WindowSize -> Automatic
                      ],
                    Appearance -> None, BaseStyle -> {}
                    ]
                  }, Alignment -> Center]
                ,
                (* Modalit\[AGrave] Modifica *)  (* Imposta l'intestazione della sezione di modifica *)
				DynamicModule[
				  {points = N[detectedPoints],  (* Inizializza "points" con le coordinate numeriche dei punti della maschera tiroidea rilevata *)
				   mode = "edit",             (* Imposta la modalit\[AGrave] iniziale su "edit" per modificare i vertici *)
				   selectedPointIndex = None,   (* Nessun punto selezionato all'avvio *)
				   imgSize = {353, 253},        (* Definisce la dimensione dell'immagine di anteprima in pixel *)
				   img = imgPreview,            (* Carica l'immagine di anteprima come sfondo per la modifica *)
				   clickThreshold = 10.0        (* Soglia di distanza per selezionare o aggiungere punti *)
				  },
				  Column[{                   (* Organizza i controlli e l'area grafica in colonna *)
				    (*---Controlli---*)
				    Row[{                    (* Riga per selezione modalit\[AGrave] *)
				      Style["Modalit\[AGrave]: ", Bold],  (* Etichetta in grassetto per il menu modalit\[AGrave] *)
				      PopupMenu[
				        Dynamic[mode],      (* Collega la variabile "mode" al menu *)
				        {"edit" -> "Modifica points",   (* Opzione per modificare vertici esistenti *)
				         "add" -> "Aggiungi punto",      (* Opzione per inserire un nuovo punto *)
				         "remove" -> "Rimuovi punto"},  (* Opzione per cancellare un punto *)
				        Appearance -> "Button"       (* Stile a bottone per il menu *)
				      ]
				    }, Spacer[10]],           (* Spazio orizzontale dopo i controlli *)
				    (*---Grafica Interattiva---*)
				    EventHandler[
				      Graphics[
				        {
				          (*1. Immagine Sfondo*)
				          Inset[img, Scaled[{0, 0}], {Left, Bottom}, Scaled[{1, 1}]],  (* Inserisce l'immagine di sfondo scalata *)
				          (*2. Poligono (per la visualizzazione in modifica) *)
				          Dynamic@If[Length[points] >= 3, 
				            {EdgeForm[{Darker@Green, Thick, Opacity[1.0]}],  (* Bordo del poligono verde scuro, spesso e opaco *)
				             FaceForm[None], Polygon[points]},             (* Nessun riempimento, solo bordo *)
				            {}],
				          (*3. Punti base (per la visualizzazione in modifica) *)
				          Dynamic@Switch[mode,
				            "edit",  {PointSize[Medium], Darker@Blue, Point[points]},  (* Punti blu medi in modifica *)
				            "add",   {PointSize[Medium], Darker@Blue, Point[points]},  (* Stessa visualizzazione in aggiunta *)
				            "remove",{PointSize[Medium], Darker@Blue, Point[points]},  (* Stessa visualizzazione in rimozione *)
				            _,       {PointSize[Medium], Red, Point[points]}            (* Altre modalit\[AGrave]: punti rossi *)
				          ],
				          (*4. Evidenzia punto selezionato (per la visualizzazione in modifica) *)
				          Dynamic@If[mode === "edit" && IntegerQ[selectedPointIndex] &&
				                    1 <= selectedPointIndex <= Length[points],
				            {Blue, PointSize[Large], Point[points[[selectedPointIndex]]]},  (* Punto selezionato grande e blu *)
				            {}]
				        },
				        PlotRange -> {{0, imgSize[[1]]}, {0, imgSize[[2]]}},  (* Limiti di visualizzazione secondo dimensioni immagine *)
				        AspectRatio -> Automatic, ImageSize -> imgSize, PlotRangePadding -> None,
				        ImageMargins -> 0
				      ],
				      (*---Gestori Eventi Mouse---*)
				      (* Nel momento in cui viene cliccato/premuto il tasto sinistro del mouse, vengono memorizzate le coordinate della posizione del cursore all'interno di "pt"*)
				      {"MouseDown" :> Module[{pt = MousePosition["Graphics"], idx, dist},
				         If[pt === None, Return[]];        (* Esci se il clic non \[EGrave] sulla grafica *)
				         pt = N[pt];                       (* Converti in numerico *)
				         Switch[mode,
				           "edit", (* Branch per la modalit\[AGrave] \[OpenCurlyDoubleQuote]modifica punti\[CloseCurlyDoubleQuote] *)
				             idx = SelectFirst[Range[Length[points]],
				                    (EuclideanDistance[pt, points[[#]]] < clickThreshold) &, None]; (* Seleziona il punto pi\[UGrave] vicino se entro soglia *)
				             selectedPointIndex = idx;     
				           ,
				           "add", (* Branch per la modalit\[AGrave] \[OpenCurlyDoubleQuote]aggiunta punti\[CloseCurlyDoubleQuote] *)
				             If[Length[points] >= 2, (* Solo se ci sono almeno 2 punti esistenti (serve almeno un segmento) *)
				               Module[{distances, minSegmentIdx, insertPos},     (* Calcola la distanza di pt da ognuno dei segmenti definiti dai punti esistenti *)
				                 distances = Table[RegionDistance[Line[{points[[i]],
				                                    points[[Mod[i, Length[points]] + 1]]}], pt],
				                                   {i, Length[points]}];  (* Distanze dai segmenti *)
				                                   
				                 (* Trova l\[CloseCurlyQuote]indice del segmento pi\[UGrave] vicino, ossia dove inserire il nuovo punto *)
				                 minSegmentIdx = Ordering[distances, 1][[1]];
				                 
				                 (* Determina la posizione nella lista points: subito dopo il primo estremo del segmento pi\[UGrave] vicino *)         
				                 insertPos = Mod[minSegmentIdx, Length[points]] + 1;
				                 
				                 (* Inserisce il nuovo punto pt nella lista alla posizione calcolata *)
				                 points = Insert[points, pt, insertPos]; 
				                 
				                 (* Deseleziona ogni punto precedentemente selezionato *)
				                 selectedPointIndex = None;
				               ];
				             ];
				           ,
				           "remove", (* Branch per la modalit\[AGrave] \[OpenCurlyDoubleQuote]rimozione punti\[CloseCurlyDoubleQuote] *)
							If[Length[points] > 3,                      (* Controlla che i punti siano pi\[UGrave] di 3, altrimenti non si pu\[OGrave] formare un poligono *)
							  Module[{nearestIdxList},                  (* Inizia un contesto locale per calcolare l\[CloseCurlyQuote]indice del punto pi\[UGrave] vicino *)
							    nearestIdxList =                        (* Trova l\[CloseCurlyQuote]indice del punto in \[OpenCurlyQuote]points\[CloseCurlyQuote] pi\[UGrave] vicino al clic *)
							      Nearest[points -> "Index", pt, 1];
							    If[Length[nearestIdxList] > 0,           (* Verifica che sia stato trovato almeno un punto vicino *)
							      idx = First@nearestIdxList;            (* Prende il primo (e unico) indice restituito *)
							      dist = EuclideanDistance[              (* Calcola la distanza tra il clic \[OpenCurlyQuote]pt\[CloseCurlyQuote] e il punto selezionato *)
							        points[[idx]], pt
							      ];
							      If[dist < clickThreshold,              (* Se la distanza \[EGrave] inferiore alla soglia di tolleranza *)
							        points = Delete[points, idx];        (*   Rimuove il punto all\[CloseCurlyQuote]indice \[OpenCurlyQuote]idx\[CloseCurlyQuote] dalla lista *)
							        selectedPointIndex = None;           (*   Deseleziona qualsiasi punto fosse selezionato *)
							      ];                                     (* Chiude il controllo sulla soglia di distanza *)
							    ];                                       (* Chiude il controllo su nearestIdxList non vuoto *)
							  ];                                         (* Fine del Module *)
							];                                           (* Chiude il controllo sul numero minimo di punti *)
				           ,
				           _, selectedPointIndex = None        (* Default: deseleziona tutto *)
				         ]
				      ],
				       "MouseDragged" :> Module[{pt = MousePosition["Graphics"]},
				         If[pt =!= None && selectedPointIndex =!= None,
				           points = ReplacePart[points, selectedPointIndex -> pt]  (* Muove il punto selezionato con il drag *)
				         ]
				       ],
				       "MouseUp" :> (selectedPointIndex = None)   (* Rilasciando il pulsante deseleziona il punto *)
				      }
				    ],
				    (*---Pulsante Salva Immagine---*)
				    Button["Salva Immagine",
				      Module[{imageToSave},
				        (* Cattura la grafica per il salvataggio con poligono blu trasparente *)
				        imageToSave = Graphics[
				          {
				            (*1. Immagine Sfondo*)
				            Inset[originalImg, Scaled[{0, 0}], {Left, Bottom}, Scaled[{1, 1}]],
				            (* Disegna il poligono blu trasparente se ci sono abbastanza punti *)
				            If[Length[points] >= 3,
				              {Blue, FaceForm[Blue], Opacity[0.5], EdgeForm[None], Polygon[points]},
				              {}                       (* Nessun poligono se meno di 3 punti *)
				            ]
				          },
				          PlotRange -> {{0, imgSize[[1]]}, {0, imgSize[[2]]}}, AspectRatio -> Automatic,
				          ImageSize -> imgSize, PlotRangePadding -> None, ImageMargins -> 0
				        ];
				        imgPreview = Rasterize[imageToSave];   (* Aggiorna l'anteprima con il poligono salvato *)
				        editMode = False;                       (* Disattiva la modalit\[AGrave] di modifica *)
				        (* Esporta la grafica come immagine sul disco *)
				        Export[FileNameJoin[{Directory[], "maschera_salvata.png"}], imageToSave];
				        (* Finestra di conferma salvataggio *)
				        CreateDialog[{TextCell["Immagine salvata in:\n" <>
				                     FileNameJoin[{Directory[], "maschera_salvata.png"}]], DefaultButton[]}]
				      ], Method -> "Queued"]
				  }, Alignment -> Center]
				]]
              ,
              (* Nessuna immagine valida *)
              Style["Anteprima immagine non disponibile.", Gray, 14] (* Improved placeholder *)
              ]
            ],

          Spacer[25],

          (* Bottone per eseguire il rilevamento *)
          Button[
            "Esegui Organ Detection",
            isProcessing = True;
            (* Uso la CriticalSection dentro TimeConstrained per evitare situazioni di UI freeze. *)
            taskObject = SessionSubmit[
              TimeConstrained[
                CriticalSection[{},
                  organDetect[file]; (* Avvio detection *)
                ],
                300, (* tempo massimo di detection = 5 minuti *)
                (isProcessing = False;
                 MessageDialog["L'operazione ha impiegato troppo tempo ed \[EGrave] stata interrotta."])
              ],
              HandlerFunctions -> <|
                "TaskFinished" -> (isProcessing = False; taskObject = None; &)
              |>
            ];,
            ImageSize -> {300, 50},
            Enabled -> Dynamic[fileSet && !isProcessing], (* Abilita solo se un file valido \[EGrave] selezionato E non in elaborazione *)
            Background -> Dynamic[If[isProcessing, Gray, LightBlue]],
            BaseStyle -> {FontSize -> 16}
            ],

          (* Indicatore di caricamento *)
          Dynamic[
            If[isProcessing,
              Column[{
                TextCell["Elaborazione in corso...", Italic, 14],
                ProgressIndicator[Appearance -> "Indeterminate"]
                }, Alignment -> Center],
              Spacer[0]
              ]
            ],

          Spacer[15],
          (* Spazio per bottone Modifica Maschera *)
          Dynamic[
            If[Length[detectedPoints] > 0,
              (* Bottone per attivare/disattivare la modalit\[AGrave] Modifica *)
              Button[
                Dynamic[If[editMode, "Esci da Modifica", "Modifica Maschera"]], (* Check sulla modalit\[AGrave] del bottone *)
                If[ImageQ[imgPreview], editMode = ! editMode], (* attiva solo se l'immagine \[EGrave] stata caricata *)
                ImageSize -> {300, 50},
                Enabled -> Dynamic[fileSet && ImageQ[imgPreview] && !isProcessing], (* Abilita solo se file valido, immagine caricata e non in elaborazione *)
                Background -> Dynamic[If[editMode, Orange, Green]],
                BaseStyle -> {FontSize -> 16}
              ],
              Column[{}] (* Utilizzo un Column vuoto per non mostrare nulla *)
            ]
          ],
          Spacer[25]
          },
        Alignment -> Center
        ],
      Alignment -> {Center, Center} 
      ],
    Background -> GrayLevel[0.95]
    ],
    WindowTitle -> "Organ Detection Tool",
    WindowMargins -> {{500, Automatic}, {Automatic, 0}}
    ]; (* Fine CreateDialog *)
]; (* Fine LaunchOrganDetectionUI *)

(* Fine della sezione privata *)
End[];

(* Fine del package *)
EndPackage[];

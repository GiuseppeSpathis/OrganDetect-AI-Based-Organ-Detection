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
    originalImg = None,
    detectedPoints = {}, (* Inizializzato a lista vuota per nascondere il bottone inizialmente *)
    editMode = False,
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
              originalImg = importedContent;
              fileSet = True;,
              errorMsg = "File non \[EGrave] un'immagine PNG/JPG valida.";
              imgPreview = None;
              originalImg = None;
              ],
            errorMsg = "Errore durante l'importazione dell'immagine.";
            imgPreview = None;
            originalImg = None;
            ];
          ,
          errorMsg = "Tipo file non supportato (solo .png, .jpg, .jpeg).";
          imgPreview = None;
          originalImg = None;
          ];
        ],
      errorMsg = "File non trovato.";
      imgPreview = None;
      originalImg = None;
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
            If[ImageQ[imgPreview],
              If[editMode == False,
                (* Modalit\[AGrave] Anteprima *)
                Column[{
                  Style["Anteprima: (Clicca per ingrandire)", Italic, 16],
                  Button[
                    Dynamic[Image[imgPreview, ImageSize -> 353]], (* Wrapped Image with Dynamic *)
                    CreateDialog[
                      Image[imgPreview, ImageSize -> Full],
                      WindowTitle -> "Anteprima Ingrandita - " <> FileNameTake[file],
                      WindowSize -> Automatic, WindowResizable -> True, WindowCentered -> True
                      ],
                    Appearance -> None, BaseStyle -> {}
                    ]
                  }, Alignment -> Center]
                ,
                (* Modalit\[AGrave] Modifica *)
                DynamicModule[
                  {
                    points = N[detectedPoints],
                    mode = "edit",
                    selectedPointIndex = None,
                    imgSize = {353, 253},
                    img = imgPreview,
                    clickThreshold = 10.0
                    },
                  Column[{
                    (*---Controlli---*)
                    Row[{
                      Style["Modalit\[AGrave]: ", Bold],
                      PopupMenu[
                        Dynamic[mode],
                        {
                         "edit" -> "Modifica points",
                         "add" -> "Aggiungi punto",
                         "remove" -> "Rimuovi punto"}, Appearance -> "Button"
                        ]
                      }, Spacer[10]],
                    (*---Grafica Interattiva---*)
                    EventHandler[
                      Graphics[
                        {
                          (*1. Immagine Sfondo*)
                          Inset[img, Scaled[{0, 0}], {Left, Bottom}, Scaled[{1, 1}]],
                          (*2. Poligono (per la visualizzazione in modifica) *)
                          Dynamic@If[Length[points] >= 3,
                            {
                             EdgeForm[{Darker@Green, Thick, Opacity[1.0]}],
                             FaceForm[None], Polygon[points]
                             },
                            {}
                            ],
                          (*3. Punti base (per la visualizzazione in modifica) *)
                          Dynamic@Switch[mode,
                            "edit", {PointSize[Medium], Darker@Blue, Point[points]},
                            "add", {PointSize[Medium], Darker@Blue, Point[points]},
                            "remove", {PointSize[Medium], Darker@Blue, Point[points]},
                            _, {PointSize[Medium], Red, Point[points]}
                            ],
                          (*4. Evidenzia punto selezionato (per la visualizzazione in modifica) *)
                          Dynamic@If[mode === "edit" && IntegerQ[selectedPointIndex] && 1 <= selectedPointIndex <= Length[points],
                            {
                             Blue,
                             PointSize[Large],
                             Point[points[[selectedPointIndex]]]
                             },
                            {}
                            ]
                          },
                        PlotRange -> {{0, imgSize[[1]]}, {0, imgSize[[2]]}},
                        AspectRatio -> Automatic,
                        ImageSize -> imgSize,
                        PlotRangePadding -> None,
                        ImageMargins -> 0
                        ],
                      (*---Gestori Eventi Mouse---*)
                      {"MouseDown" :> Module[{pt = MousePosition["Graphics"], idx, dist},
                         If[pt === None, Return[]];
                         pt = N[pt];
                         Switch[mode,
                           "edit",
                           idx = SelectFirst[Range[Length[points]], (EuclideanDistance[pt, points[[#]]] < clickThreshold) &, None];
                           selectedPointIndex = idx;,
                           "add",
                           If[Length[points] >= 2,
                             Module[{distances, minSegmentIdx, insertPos},
                               distances = Table[RegionDistance[Line[{points[[i]], points[[Mod[i, Length[points]] + 1]]}], pt], {i, Length[points]}];
                               minSegmentIdx = Ordering[distances, 1][[1]];
                               insertPos = Mod[minSegmentIdx, Length[points]] + 1;
                               points = Insert[points, pt, insertPos];
                               selectedPointIndex = None;
                               ];
                             ];
                           ,
                           "remove",
                           If[Length[points] > 3,
                             Module[{nearestIdxList},
                               nearestIdxList = Nearest[points -> "Index", pt, 1];
                               If[Length[nearestIdxList] > 0,
                                 idx = First@nearestIdxList;
                                 dist = EuclideanDistance[points[[idx]], pt];
                                 If[dist < clickThreshold,
                                   points = Delete[points, idx];
                                   selectedPointIndex = None;
                                   ];
                                 ];
                               ];
                             ];
                           ,
                           _,
                           selectedPointIndex = None;
                           ]
                         ],
                       "MouseDragged" :> Module[{pt = MousePosition["Graphics"]},
                         If[pt =!= None && selectedPointIndex =!= None,
                           points = ReplacePart[points, selectedPointIndex -> pt]
                           ]
                         ],
                       "MouseUp" :> (selectedPointIndex = None)
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
                              {
                               Blue, (* Imposta il colore a blu *)
                               FaceForm[Blue], (* Riempie il poligono con blu *)
                               Opacity[0.5], (* Imposta l'opacit\[AGrave] *)
                               EdgeForm[None], (* Rimuove il bordo *)
                               Polygon[points]
                               },
                              {} (* Nessun poligono se meno di 3 punti *)
                              ]
                            (* I punti base e il punto selezionato non vengono inclusi in questa grafica di salvataggio *)
                            },
                          PlotRange -> {{0, imgSize[[1]]}, {0, imgSize[[2]]}},
                          AspectRatio -> Automatic,
                          ImageSize -> imgSize,
                          PlotRangePadding -> None,
                          ImageMargins -> 0
                          ];
                          imgPreview = Rasterize[imageToSave];
                          editMode = False;
                        (* Esporta la grafica come immagine *)
                        Export[FileNameJoin[{Directory[], "maschera_salvata.png"}], imageToSave]; (* Puoi cambiare l'estensione in ".jpg" se preferisci *)
                        (* Mostra una finestra di dialogo di conferma *)
                        CreateDialog[{TextCell["Immagine salvata in:\n" <> FileNameJoin[{Directory[], "maschera_salvata.png"}]], DefaultButton[]}]
                        ], Method -> "Queued"]
                    }, Alignment -> Center]
                  ]
                ]
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

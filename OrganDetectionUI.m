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
(* Carica il package di rilevamento effettivo *)
(* Assicurati che OrganDetection.m sia in un percorso accessibile da Mathematica *)
(* Quiet[<< OrganDetection.m, Print["Errore: Impossibile caricare OrganDetection.m. Assicurati che sia nel $Path di Mathematica."]; Abort[]]; *)

(* Definizione della funzione pubblica che crea e lancia la UI *)
LaunchOrganDetectionUI[] := DynamicModule[
  {
   file = "",
   fileSet = False,
   errorMsg = "",
   imgPreview = None,
   editMode = False,
   isProcessing = False,
   updateFileState,
   organDetect,
   taskObject = None
   },

  (* Funzione di aggiornamento dello stato del file *)
  updateFileState[newFile_String] := (
    file = newFile;
    errorMsg = "";
    imgPreview = None; (* Reset dell'anteprima dell'immagine *)
    fileSet = False; (* Reset dello stato del file *)
    isProcessing = False;

    If[StringTrim[file] == "", Return[]]; (* Esci se il percorso del file \[EGrave] vuoto *)

    If[FileExistsQ[file],
      Module[{ext = ToLowerCase@FileExtension[file], importedContent},
        If[StringMatchQ[ext, "png" | "jpg" | "jpeg"],
          Check[
            importedContent = Import[file];
            If[ImageQ[importedContent],
              imgPreview = importedContent;
              fileSet = True;,
              errorMsg = "File non \[EGrave] un'immagine PNG/JPG valida.";
              imgPreview = None; (* Assicura reset anche qui *)
              ],
            errorMsg = "\:274c Errore durante l'importazione dell'immagine.";
            imgPreview = None;
            ];
          ,
          errorMsg = "\:274c Tipo file non supportato (solo .png, .jpg, .jpeg).";
          imgPreview = None;
          ];
        ],
      errorMsg = "\:274c File non trovato.";
      imgPreview = None;
      ];
    If[errorMsg =!= "", fileSet = False]; (* Aggiorna fileSet se c'\[EGrave] stato un errore *)
    );

  (* Funzione di rilevamento degli organi *)
  (* Questa funzione ora chiama quella definita nel package OrganDetection.m *)
  organDetect[imagePath_String] := Module[{detectionResult},
    (* Qui si assume che OrganDetection.m definisca una funzione globale OrganDetection[] *)
    (* Se il nome \[EGrave] diverso, aggiornalo qui *)

    detectionResult = Check[
      OrganDetection[imagePath],
      "\:274c Errore durante l'esecuzione di OrganDetection."
      ];

    (* Aggiorna imgPreview con il risultato del rilevamento *)
    imgPreview = detectionResult;
    (* Mantieni editMode a False dopo il rilevamento per mostrare il risultato *)
    editMode = False;
    ];

  (* UI - Creazione della finestra di dialogo *)
  CreateDialog[
    Panel[
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
            Style["\:2705 File selezionato: " <> FileNameTake[file], Darker@Green, 14],
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
              (* Modalit\[AGrave] Modifica - Implementazione placeholder/semplificata *)
              DynamicModule[
                {
                  punti = N[{{50, 50}, {300, 50}, {300, 200}, {50, 200}}],
                  mode = "none",
                  selectedPointIndex = None,
                  imgSize = {353, 253},
                  img = imgPreview,
                  filePath = FileNameJoin[{$TemporaryDirectory, "punti_salvati.wdx"}],
                  clickThreshold = 10.0
                  },
                Column[{
                  (*---Controlli---*)
                  Row[{
                    Style["Modalit\[AGrave]: ", Bold],
                    PopupMenu[
                      Dynamic[mode],
                      {"none" -> "Nessuna",
                       "edit" -> "Modifica punti",
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
                        (*2. Poligono*)
                        Dynamic@If[Length[punti] >= 3,
                          {
                           EdgeForm[{Darker@Green, Thick, Opacity[1.0]}],
                           FaceForm[None], Polygon[punti]
                           },
                          {}
                          ],
                        (*3. Punti base*)
                        Dynamic@Switch[mode,
                          "edit", {PointSize[Medium], Darker@Blue, Point[punti]},
                          "add", {PointSize[Medium], Darker@Blue, Point[punti]},
                          "remove", {PointSize[Medium], Darker@Blue, Point[punti]},
                          _, {PointSize[Medium], Red, Point[punti]}
                          ],
                        (*4. Evidenzia punto selezionato*)
                        Dynamic@If[mode === "edit" && IntegerQ[selectedPointIndex] && 1 <= selectedPointIndex <= Length[punti],
                          {
                           Blue,
                           PointSize[Large],
                           Point[punti[[selectedPointIndex]]]
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
                         idx = SelectFirst[Range[Length[punti]], (EuclideanDistance[pt, punti[[#]]] < clickThreshold) &, None];
                         selectedPointIndex = idx;,
                         "add",
                         If[Length[punti] >= 2,
                           Module[{distances, minSegmentIdx, insertPos},
                             distances = Table[RegionDistance[Line[{punti[[i]], punti[[Mod[i, Length[punti]] + 1]]}], pt], {i, Length[punti]}];
                             minSegmentIdx = Ordering[distances, 1][[1]];
                             insertPos = Mod[minSegmentIdx, Length[punti]] + 1;
                             punti = Insert[punti, pt, insertPos];
                             selectedPointIndex = None;
                             ];
                           ];
                         ,
                         "remove",
                         If[Length[punti] > 3,
                           Module[{nearestIdxList},
                             nearestIdxList = Nearest[punti -> "Index", pt, 1];
                             If[Length[nearestIdxList] > 0,
                               idx = First@nearestIdxList;
                               dist = EuclideanDistance[punti[[idx]], pt];
                               If[dist < clickThreshold,
                                 punti = Delete[punti, idx];
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
                         punti = ReplacePart[punti, selectedPointIndex -> pt]
                         ]
                       ],
                     "MouseUp" :> (selectedPointIndex = None)
                     }
                    ],
                  (*---Pulsante Salva---*)
                  Button["Salva punti",
                    Export[filePath, punti];
                    CreateDialog[{TextCell["Punti salvati in:\n" <> filePath], DefaultButton[]}], Method -> "Queued"]
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
          (* Action to start processing *)
          isProcessing = True;
          (* Use a CriticalSection wrapped in TimeConstrained to prevent UI freezing *)
          taskObject = SessionSubmit[
            TimeConstrained[
              CriticalSection[{},
                organDetect[file]; (* Run the detection *)
              ],
              300, (* Time limit - 5 minutes *)
              (isProcessing = False; 
               MessageDialog["L'operazione ha impiegato troppo tempo ed \[EGrave] stata interrotta."])
            ],
            HandlerFunctions -> <|
              "TaskFinished" -> (isProcessing = False; taskObject = None; &),
              "TaskFailed" -> (isProcessing = False; 
                              MessageDialog["Si \[EGrave] verificato un errore: " <> ToString[#["Error"]]]; 
                              taskObject = None; &)
            |>
          ];,
          ImageSize -> {300, 50},
          Enabled -> Dynamic[fileSet && !isProcessing], (* Abilita solo se un file valido \[EGrave] selezionato E non in elaborazione *)
          Background -> Dynamic[If[isProcessing, Gray, LightBlue]], (* Change color when disabled *)
          BaseStyle -> {FontSize -> 16}
          ],

        (* Indicatore di caricamento *)
        Dynamic[
          If[isProcessing,
            Column[{
              TextCell["Elaborazione in corso...", Italic, 14],
              ProgressIndicator[Appearance -> "Indeterminate"]
              }, Alignment -> Center],
            Spacer[0] (* Sostituisce Nothing con un elemento visibile ma vuoto *)
            ]
          ],

        Spacer[15], (* Adjusted spacing *)

        (* Bottone per attivare/disattivare la modalit\[AGrave] Modifica *)
        Button[
          Dynamic[If[editMode, "Esci da Modifica", "Modifica Maschera"]], (* Button label changes *)
          If[ImageQ[imgPreview], editMode = ! editMode], (* Toggle only if image is loaded *)
          ImageSize -> {300, 50},
          Enabled -> Dynamic[fileSet && ImageQ[imgPreview] && !isProcessing], (* Abilita solo se file valido, immagine caricata e non in elaborazione *)
          Background -> Dynamic[If[editMode, Orange, Green]], (* Button color changes *)
          BaseStyle -> {FontSize -> 16}
          ],
        Spacer[25]


        },
      Spacing -> 2, (* Adjusted spacing *)
      Alignment -> Center,
      FontFamily -> "Calibri"
      ],
    Background -> GrayLevel[0.95]
    ],
    WindowTitle -> "Organ Detection Tool",
    WindowSize -> {850, 950}, (* Slightly increased height *)
    WindowCentered -> True
    ]; (* Fine CreateDialog *)
  ]; (* Fine LaunchOrganDetectionUI *)

(* Fine della sezione privata *)
End[];

(* Fine del package *)
EndPackage[];

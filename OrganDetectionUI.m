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

Get["OrganDetection.m"];
(* Carica il package di rilevamento effettivo *)
(* Assicurati che OrganDetection.m sia in un percorso accessibile da Mathematica *)
(*Quiet[<< OrganDetection.m, Print["Errore: Impossibile caricare OrganDetection.m. Assicurati che sia nel $Path di Mathematica."]; Abort[]];*)

(* Definizione della funzione pubblica che crea e lancia la UI *)
LaunchOrganDetectionUI[] := DynamicModule[{
    file = "",
    fileSet = False,
    errorMsg = "",
    imgPreview = None,
    updateFileState,
    organDetect
    },

    (* Funzione di aggiornamento dello stato del file *)
    updateFileState[newFile_String] := (
        file = newFile;
        errorMsg = "";
        imgPreview = None; (* Reset dell'anteprima dell'immagine *)
        fileSet = False; (* Reset dello stato del file *)

        If[StringTrim[file] == "", Return[]]; (* Esci se il percorso del file \[EGrave] vuoto *)

        If[FileExistsQ[file],
            Module[{ext = ToLowerCase@FileExtension[file], importedContent},
                If[StringMatchQ[ext, "png" | "jpg" | "jpeg"],
                    Check[
                        importedContent = Import[file];
                        If[ImageQ[importedContent],
                            imgPreview = importedContent;
                            fileSet = True;,
                            errorMsg = "\:274c File non \[EGrave] un'immagine PNG/JPG valida.";
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
        
        imgPreview = detectionResult;
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

                (* Anteprima immagine selezionata *)
                Dynamic[
                    If[ImageQ[imgPreview],
                        Column[{
                            Style["Anteprima: (Clicca per ingrandire)", Italic, 16],
                            Button[
                                Image[imgPreview, ImageSize -> 450],
                                CreateDialog[
                                    Image[imgPreview, ImageSize -> Full],
                                    WindowTitle -> "Anteprima Ingrandita - " <> FileNameTake[file],
                                    WindowSize -> Automatic,
                                    WindowResizable -> True,
                                    WindowCentered -> True
                                ],
                                Appearance -> None,
                                BaseStyle -> {}
                            ]
                        }, Alignment -> Center],
                        "" (* Non mostrare nulla se non c'\[EGrave] anteprima *)
                    ]
                ],

                Spacer[25],

                (* Bottone per eseguire il rilevamento *)
                Button[
                    "Esegui Organ Detection",
                    organDetect[file];, (* Chiamata alla funzione di rilevamento *)
                    ImageSize -> {300, 50},
                    Enabled -> Dynamic[fileSet], (* Abilita solo se un file valido \[EGrave] selezionato *)
                    Background -> LightBlue,
                    BaseStyle -> {FontSize -> 16}
                ],

                Spacer[25]

                
            },
            Spacing -> 2.5,
            Alignment -> Center,
            FontFamily -> "Calibri"
            ],
        Background -> GrayLevel[0.95]
        ],
        WindowTitle -> "Organ Detection Tool",
        WindowSize -> {850, Automatic},
        WindowCentered -> True
    ]; (* Fine CreateDialog *)
]; (* Fine LaunchOrganDetectionUI *)

(* Fine della sezione privata *)
End[];

(* Fine del package *)
EndPackage[];

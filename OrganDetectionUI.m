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
(* imposta il contesto corrente per i simboli al package corrente. Tutte le funzioni e le variabile definite all'interno del package non sarnno accessibili all'esterno. *)
Get["OrganDetection.m"];

(* Definizione della funzione pubblica che crea e lancia la UI *)
LaunchOrganDetectionUI[] := DynamicModule[
  {
    file = "", (* Stringa che memorizza il percorso dell'immagine selezinata dall'utente *)
    fileSet = False, (* variabile booleana che indica se un file valido \[EGrave] stato selezionato oppure no.*)
    errorMsg = "", (* Stringa per memorizzare eventuali messaggi di errore *)
    imgPreview = None, (* Variabile che conterr\[AGrave] l'oggetto immagine di Mathematica *)
    originalImg = None, (* Memorizza l'immagine originale importata, utilizzata per il salvataggio in modalit\[AGrave] modifica per disegnare la maschera sopra l'immagine originale. *)
    detectedPoints = {}, (* Inizializzato a lista vuota per nascondere il bottone inizialmente *)
    editMode = False, (* Lista di punti (coppie {x, y}) che rappresentano i vertici del poligono rilevato (o modificato) sull'immagine. Inizializzata a lista vuota; la lunghezza di questa lista controlla la visibilit\[AGrave] del bottone "Modifica Maschera". *)
    isProcessing = False, (* Variabile booleana che controlla se l'UI \[EGrave] in modalit\[AGrave] anteprima (`False`) o modalit\[AGrave] modifica punti (`True`). *)
    updateFileState, (* Nome riservato per la funzione locale che gestisce la selezione e l'importazione del file. *)
    organDetect, (* Nome riservato per la funzione locale che esegue la logica di rilevamento. *)
    taskObject = None (* Memorizza un riferimento al TaskObject creato da SessionSubmit, utile per gestire il processo in background.*)
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
	(* StringTrim[file] rimuove spazi bianchi all'inizio e alla fine del percorso. If controlla se il percorso risultante \[EGrave] vuoto (ad esempio, se l'utente annulla la selezione). Se vuoto, la funzione termina immediatamente. *)
    If[FileExistsQ[file],
      Module[{ext = ToLowerCase@FileExtension[file], importedContent},
      (* If[FileExistsQ[file], ...] controlla se il file specificato nel percorso esiste sul filesystem.
           Module[...] crea un ambiente locale per le variabili `ext` e `importedContent`, evitando che interferiscano con altre variabili.
           ext = ToLowerCase@FileExtension[file] estrae l'estensione del file, la converte in minuscolo. `.` viene rimosso automaticamente da FileExtension. *)
        If[StringMatchQ[ext, "png" | "jpg" | "jpeg"],
        (* StringMatchQ[ext, "png" | "jpg" | "jpeg"] controlla se l'estensione (in minuscolo) corrisponde a "png", "jpg" o "jpeg". `|` \[EGrave] l'operatore OR. *)
          Check[
          (* Check[...] esegue il suo primo argomento e, se durante l'esecuzione si verificano messaggi di errore o avviso, restituisce il secondo argomento specificato ("Errore durante l'importazione..."). \[CapitalEGrave] un modo per gestire gli errori durante l'importazione. *)
            importedContent = Import[file];
            (* Import[file] tenta di importare il contenuto del file. Per le immagini, restituisce un oggetto Image. *)
            If[ImageQ[importedContent],
            (* If[ImageQ[importedContent], ...] controlla se il contenuto importato \[EGrave] effettivamente un oggetto Image. *)
              imgPreview = importedContent;
              originalImg = importedContent;
              fileSet = True;,
              (* Se \[EGrave] un'immagine, assegna l'immagine a `imgPreview` e `originalImg` e imposta `fileSet` a True. *)
              errorMsg = "File non \[EGrave] un'immagine PNG/JPG valida.";
              imgPreview = None;
              originalImg = None;
              ],
            (* Altrimenti, imposta un messaggio di errore e resetta le variabili immagine e stato. *)
            errorMsg = "Errore durante l'importazione dell'immagine.";
            imgPreview = None;
            originalImg = None;
            ];
          (* Se Check ha rilevato un errore durante l'importazione, viene eseguito questo ramo, impostando un messaggio di errore generico. *)
          ,
          errorMsg = "Tipo file non supportato (solo .png, .jpg, .jpeg).";
          imgPreview = None;
          originalImg = None;
          ];
        (* Se l'estensione del file non \[EGrave] supportata, imposta un messaggio di errore specifico. *)
        ],
      errorMsg = "File non trovato.";
      imgPreview = None;
      originalImg = None;
      ];
    (* Se il file non esiste, imposta un messaggio di errore. *)
    If[errorMsg =!= "", fileSet = False]; (* Aggiorna fileSet se c'\[EGrave] stato un errore *)
    (* Dopo tutti i controlli, se `errorMsg` non \[EGrave] vuoto, imposta `fileSet` su False per comunicare che non c'\[EGrave] un file valido pronto. *)
    );


 (* Funzione di rilevamento degli organi *)
  organDetect[imagePath_String] := Module[{detectionResult},
  (* organDetect[imagePath_String] := ... definisce la funzione locale per il rilevamento. Accetta un argomento `imagePath` che deve essere una stringa (`_String`).
       Module[...] crea un ambiente locale per la variabile `detectionResult`. *)
    detectionResult = Check[
      OrganDetection[imagePath],
      "Errore durante l'esecuzione di OrganDetection."
     ];
   (* detectionResult = Check[OrganDetection[imagePath], ...] chiama la funzione esterna `OrganDetection` (definita nel file caricato con `Get`) passando il percorso dell'immagine.
       `Check` cattura eventuali errori dall'esecuzione di `OrganDetection` e assegna un messaggio di errore a `detectionResult` in caso di problemi.
       Si assume che `OrganDetection` restituisca un'Association (o una struttura simile) contenente almeno le chiavi "ResultImage" e "DetectedPoints". *)
    (* Aggiorna imgPreview con la nuova immagine, ovvero, il risultato del rilevamento *)
    imgPreview = detectionResult["ResultImage"];
    (* Aggiorna `imgPreview` con l'immagine risultante dal processo di rilevamento. Questa immagine potrebbe avere la maschera disegnata sopra, a seconda di come `OrganDetection` implementa la visualizzazione dei risultati. *)
    detectedPoints = ToExpression[detectionResult["DetectedPoints"]];
    (* Aggiorna `detectedPoints` con la lista dei punti rilevati. Si assume che `OrganDetection` restituisca questi punti come una stringa (probabilmente la rappresentazione stringa di una lista di coppie {x, y}). `ToExpression` converte questa stringa nella corrispondente espressione Mathematica (la lista di liste {x, y}). *)
    (* Si mantiene editMode a False dopo il rilevamento per mostrare il risultato *)
    editMode = False;
	(* Imposta `editMode` su False per assicurarsi che l'utente veda l'immagine con i risultati dopo il rilevamento, anzich\[EAcute] passare subito alla modalit\[AGrave] di modifica. *)
    (* Questo blocco apre una finestra di dialogo per notificare la mancata rilevazione di tiroidi. *)
    (* Commento che descrive lo scopo del blocco condizionale successivo. *)
	If[Length[detectedPoints] == 0,
	    (* If[Length[detectedPoints] == 0, ...] controlla se la lista di punti rilevati \[EGrave] vuota. Se \[EGrave] vuota, significa che non sono stati rilevati organi. *)
        (* Funzione che apre una nuova finestra di dialogo con l'utente. *)
	    CreateDialog[
	    (* CreateDialog[...] crea una piccola finestra di dialogo separata per l'utente. *)
	      Panel[
	        Grid[{
	          {Style["Nessun organo tiroideo rilevato!!", Red, 14]},
	          (* Grid[...] organizza gli elementi in una griglia. Qui c'\[EGrave] una singola cella nella prima riga con un messaggio di testo stilizzato in rosso e grassetto. *)
	          {Spacer[{0, 15}]},
	          (* Spacer[...] crea uno spazio verticale fisso di 15 pixel. *)
	          {DefaultButton[]}
	          (* DefaultButton[] crea un pulsante standard con l'etichetta predefinita del sistema operativo ("OK" o simile) che chiude la finestra di dialogo quando cliccato. *)
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
	(* Impostazioni per la finestra di dialogo: titolo, dimensione, margini, elementi visibili (nasconde la barra di stato), sfondo. *)
	];
	];


  (* UI - Creazione della finestra di dialogo *)
  CreateDialog[
  (* CreateDialog[...] crea la finestra principale dell'interfaccia utente. *)
    Panel[
    (* Panel[...] mette un bordo attorno al contenuto e fornisce un leggero rientro. *)
      Item[
      (* Item[...] allinea il suo contenuto. *)
        Column[{
        (* Column[...] organizza gli elementi verticalmente. *)
          (* Titolo dell'app *)
          Style[" Organ Detection Tool", 30, Bold, FontFamily -> "Helvetica"],
          (* Style[...] applica stili al testo: dimensione 30, grassetto, font Helvetica. *)
          Spacer[20],
          (* Spacer[...] aggiunge spazio verticale di 20 pixel. *)

          (* Seleziona file immagine *)
          Row[{
          (* Row[...] organizza gli elementi orizzontalmente. *)
            Style["Seleziona file immagine: ", 16],
            FileNameSetter[
              Dynamic[file, (updateFileState[#]) &],
              (* FileNameSetter[...] crea un campo di testo e un pulsante "Sfoglia" per selezionare un file.
               Dynamic[file, (updateFileState[#]) &] \[EGrave] una costruzione dinamica. Il valore mostrato nel campo \[EGrave] `file`. Quando l'utente seleziona un file, il valore `#` (il percorso selezionato) viene passato alla funzione `updateFileState`, che aggiorna la variabile `file` e lo stato dell'UI. *)
              "Open",
              (* "Open" specifica che \[EGrave] una finestra di dialogo per aprire file. *)
              {"Immagini (PNG, JPG)" -> {"*.png", "*.jpg", "*.jpeg"}}
              (* Definisce un filtro per la finestra di dialogo del file, mostrando solo i tipi specificati. *)
              ]
            }, Spacer[10]],
            (* Spacer[10] aggiunge spazio orizzontale tra gli elementi nella Row. *)
          (* Stato del file selezionato *)
          Dynamic[
          (* Dynamic[...] qui fa s\[IGrave] che questo blocco di testo si aggiorni ogni volta che le variabili `fileSet` o `errorMsg` cambiano. *)
            If[fileSet,
              Style["File selezionato: " <> FileNameTake[file], Darker@Green, 14],
              (* Se `fileSet` \[EGrave] True, mostra il nome del file (estratto con FileNameTake) in verde scuro. *)
              If[errorMsg != "", Style[errorMsg, Red, 14], Style["Nessun file selezionato.", Gray, 14]]
              (* Altrimenti, se `errorMsg` non \[EGrave] vuoto, mostra il messaggio di errore in rosso; altrimenti, mostra "Nessun file selezionato." in grigio. *)
              ]
            ],

          Spacer[15],

          (* Anteprima/Modifica immagine selezionata *)
          Dynamic[
          (* Questo blocco Dynamic gestisce la visualizzazione dell'immagine, commutando tra anteprima e modalit\[AGrave] di modifica. Si aggiorna quando `imgPreview` o `editMode` cambiano. *)
            If[ImageQ[imgPreview],
            (* If[ImageQ[imgPreview], ...] mostra l'immagine solo se `imgPreview` contiene un oggetto immagine valido. *)
              If[editMode == False,
              (* Se `editMode` \[EGrave] False (modalit\[AGrave] anteprima): *)
                (* Modalit\[AGrave] Anteprima *)
                Column[{
                  Style["Anteprima: (Clicca per ingrandire)", Italic, 16],
                  Button[
                    Dynamic[Image[imgPreview, ImageSize -> 353]], (* Wrapped Image with Dynamic *)
                    (* Visualizza l'immagine `imgPreview` ridimensionata. `Dynamic` qui assicura che se `imgPreview` cambia (es. dopo la detection), l'anteprima si aggiorni. *)
                    CreateDialog[
                      Image[imgPreview, ImageSize -> Full],
                      WindowTitle -> "Anteprima Ingrandita - " <> FileNameTake[file],
                      WindowSize -> Automatic, WindowResizable -> True, WindowCentered -> True
                      ],
                    (* Quando si clicca sull'immagine in anteprima, crea una nuova finestra di dialogo (`CreateDialog`) che mostra l'immagine a dimensione intera o quasi (`ImageSize -> Full`). *)
                    Appearance -> None, BaseStyle -> {}
                    ]
                  }, Alignment -> Center]
                ,
                (* Altrimenti (`editMode == True` - modalit\[AGrave] modifica): *)
                (* Modalit\[AGrave] Modifica *)
                DynamicModule[
                  {
                (* Un DynamicModule *annidato* per gestire lo stato specifico della modalit\[AGrave] di modifica. Questo \[EGrave] importante perch\[EAcute] variabili come `points`, `selectedPointIndex`, `mode` sono locali a questa sessione di modifica e non interferiscono con lo stato principale dell'UI quando si esce dalla modalit\[AGrave] modifica. *)
                    points = N[detectedPoints],
                    (* `points`: La lista di punti su cui l'utente lavorer\[AGrave]. Inizializzata con i punti rilevati (`detectedPoints`). `N[...]` converte i punti in numeri reali, utile per le operazioni geometriche. *)
                    mode = "edit",
                    (* `mode`: Stringa che controlla la modalit\[AGrave] di interazione del mouse ("edit", "add", "remove"). *)
                    selectedPointIndex = None,
                    (* `selectedPointIndex`: L'indice del punto correntemente selezionato in modalit\[AGrave] "edit". None se nessun punto \[EGrave] selezionato. *)
                    imgSize = {353, 253},
                    (* `imgSize`: La dimensione in pixel dell'area grafica. NOTA: Questo valore *non* viene calcolato dinamicamente dall'immagine `imgPreview`, ma \[EGrave] fissato a {353, 253}. Questo potrebbe causare problemi di scaling se l'immagine importata ha un aspect ratio diverso o dimensioni molto diverse. Idealmente, dovrebbe essere ImageDimensions[imgPreview]. *)
                    img = imgPreview,
                    (* `img`: Una copia locale di `imgPreview` all'ingresso in modalit\[AGrave] modifica. *)
                    clickThreshold = 10.0 (* Tolleranza in pixel per selezionare un punto *)
                    (* `clickThreshold`: La distanza massima (in pixel) per considerare un clic del mouse sufficientemente vicino a un punto esistente per selezionarlo o rimuoverlo. *)
                    },
                  Column[{
                    (*---Controlli---*)
                    Row[{
                      Style["Modalit\[AGrave]: ", Bold],
                      PopupMenu[
                        Dynamic[mode],
                        (* PopupMenu crea un menu a discesa. `Dynamic[mode]` lega il valore selezionato alla variabile locale `mode`. *)
                        {
                         "edit" -> "Modifica points",
                         "add" -> "Aggiungi punto",
                         "remove" -> "Rimuovi punto"}, Appearance -> "Button"
                         (* L'Association {chiave -> valore} definisce le opzioni del menu. Il valore \[EGrave] la stringa mostrata, la chiave \[EGrave] il valore assegnato a `mode`. `Appearance -> "Button"` fa sembrare il menu un pulsante. *)
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
            (* Cliccando, imposta `isProcessing` su True per indicare che l'elaborazione \[EGrave] iniziata (attiva l'indicatore di progresso e disabilita i bottoni). *)
            (* Uso la CriticalSection dentro TimeConstrained per evitare situazioni di UI freeze. *)
            taskObject = SessionSubmit[
              TimeConstrained[
              (* TimeConstrained[...] esegue il suo primo argomento entro un tempo massimo specificato (secondo argomento). Se il tempo scade, il task viene interrotto e viene eseguito il terzo argomento. *)
                CriticalSection[{},
                  organDetect[file]; (* Avvio detection *)
                ],
                300, (* tempo massimo di detection = 5 minuti *)
                (isProcessing = False;
                 (* Codice da eseguire se il timeout scade: resetta `isProcessing` e mostra un messaggio. `MessageDialog` apre una semplice finestra di dialogo bloccante. *)
                 MessageDialog["L'operazione ha impiegato troppo tempo ed \[EGrave] stata interrotta."])
              ],
              HandlerFunctions -> <|
                (* HandlerFunctions \[EGrave] un'opzione di SessionSubmit che specifica cosa fare quando il task raggiunge determinati stati. Qui, per lo stato "TaskFinished" (task completato, con o senza successo, ma non interrotto da timeout o errore grave che impedisce il completamento), esegue la funzione anonima `(isProcessing = False; taskObject = None; &)`, che resetta `isProcessing` e `taskObject`. `&` alla fine crea una funzione pura (lambda function). *)
                "TaskFinished" -> (isProcessing = False; taskObject = None; &)
              |>
            ];,
            ImageSize -> {300, 50},
           (* Enabled[...] controlla se il pulsante \[EGrave] attivo. `Dynamic[...]` lo fa dipendere da `fileSet` (deve essere True) e `isProcessing` (deve essere False). *)
            Enabled -> Dynamic[fileSet && !isProcessing], (* Abilita solo se un file valido \[EGrave] selezionato E non in elaborazione *)
            (* Background[...] imposta il colore di sfondo del pulsante dinamicamente: grigio se in elaborazione, azzurro chiaro altrimenti. *)
            Background -> Dynamic[If[isProcessing, Gray, LightBlue]],
            BaseStyle -> {FontSize -> 16}
            ],

          (* Indicatore di caricamento *)
          (* Questo blocco Dynamic visualizza l'indicatore di progresso solo quando `isProcessing` \[EGrave] True. *)
          Dynamic[
            If[isProcessing,
              Column[{
              (* Testo che indica lo stato. *)
                TextCell["Elaborazione in corso...", Italic, 14],             
                ProgressIndicator[Appearance -> "Indeterminate"]
                (* ProgressIndicator[...] mostra un'animazione che indica che qualcosa sta succedendo, senza mostrare un progresso specifico (indeterminato). *)
                }, Alignment -> Center],
              Spacer[0]
              (* Se `isProcessing` \[EGrave] False, mostra uno spazio vuoto di dimensione 0. *)
              ]
            ],

          Spacer[15],
          (* Spazio per bottone Modifica Maschera *)
          Dynamic[
          (* Questo blocco Dynamic controlla la visibilit\[AGrave] del pulsante "Modifica Maschera". *)
            If[Length[detectedPoints] > 0,
            (* Il pulsante viene mostrato solo se `detectedPoints` contiene punti (cio\[EGrave], la detection ha trovato qualcosa). *)
              (* Bottone per attivare/disattivare la modalit\[AGrave] Modifica *)
              Button[
                Dynamic[If[editMode, "Esci da Modifica", "Modifica Maschera"]], (* Check sulla modalit\[AGrave] del bottone *)
                (* L'etichetta del pulsante cambia dinamicamente in base al valore di `editMode`. *)
                If[ImageQ[imgPreview], editMode = ! editMode], (* attiva solo se l'immagine \[EGrave] stata caricata *)
                (* L'azione del pulsante: se `imgPreview` \[EGrave] un'immagine, commuta il valore di `editMode` (da True a False o viceversa). *)
                ImageSize -> {300, 50},
                Enabled -> Dynamic[fileSet && ImageQ[imgPreview] && !isProcessing], (* Abilita solo se file valido, immagine caricata e non in elaborazione *)
                (* Il pulsante \[EGrave] attivo solo se \[EGrave] stato selezionato un file valido, c'\[EGrave] un'immagine da mostrare e non \[EGrave] in corso il processo di rilevamento. *)
                Background -> Dynamic[If[editMode, Orange, Green]],
                (* Il colore di sfondo cambia in base a `editMode`: arancione in modalit\[AGrave] modifica, verde altrimenti. *)
                BaseStyle -> {FontSize -> 16}
              ],
              Column[{}] (* Utilizzo un Column vuoto per non mostrare nulla *)
             (* Se `Length[detectedPoints]` non \[EGrave] > 0, mostra una `Column` vuota, che essenzialmente non occupa spazio e nasconde il pulsante. *)
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
    (* Titolo della finestra principale. *)
    WindowTitle -> "Organ Detection Tool",
    WindowMargins -> {{500, Automatic}, {Automatic, 0}}
     (* Imposta la posizione della finestra: 500 pixel dal bordo sinistro dello schermo. Gli altri margini sono automatici o zero. *)
    ]; (* Fine CreateDialog *)
]; (* Fine LaunchOrganDetectionUI *)
(* Fine della definizione della funzione pubblica. *)

(* Fine della sezione privata *)
End[];
(* End[] chiude il contesto `OrganDetection`Private`, ripristinando il contesto precedente (tipicamente `Global`). *)

(* Fine del package *)
EndPackage[];

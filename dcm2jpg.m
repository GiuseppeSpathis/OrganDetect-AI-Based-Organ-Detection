(* Content-type: application/vnd.wolfram.mathematica *)

(*** Wolfram Notebook File ***)
(* http://www.wolfram.com/nb *)

(* CreatedBy='Wolfram 14.2' *)

(*CacheID: 234*)
(* Internal cache information:
NotebookFileLineBreakTest
NotebookFileLineBreakTest
NotebookDataPosition[       154,          7]
NotebookDataLength[     51215,       1152]
NotebookOptionsPosition[     50721,       1136]
NotebookOutlinePosition[     51157,       1153]
CellTagsIndexPosition[     51114,       1150]
WindowFrame->Normal*)

(* Beginning of Notebook Content *)
Notebook[{
Cell[BoxData[
 RowBox[{
  RowBox[{"(*", 
   RowBox[{
   "Funzione", " ", "per", " ", "convertire", " ", "selettivamente", " ", 
    "un", " ", "file", " ", "DICOM", " ", "in", " ", "immagini", " ", 
    "JPEG"}], "*)"}], 
  RowBox[{
   RowBox[{
    RowBox[{
     RowBox[{"ConvertDICOMToJPEGs", "::", "usage"}], 
     "=", "\"\<ConvertDICOMToJPEGs[dicomFilePath] converte slice selezionati \
(90-100, 140-150, 160-170, 190-200, 220-230) dal file DICOM specificato in \
file JPEG.\nI file JPEG vengono salvati in una sottocartella \
'./dataset/<nome_base_dicom>/' relativa alla directory del notebook.\n\
Esempio: Se l'input \[EGrave] 'originali02.dcm', l'output va in \
'./dataset/originali02/'.\nSe il nome base del file DICOM contiene \
'originali', i JPEG sono nominati 'uno<indice>.jpg'.\nSe contiene \
'groundtruth', sono nominati 'unogt<indice>.jpg'.\nSe dicomFilePath non \
\[EGrave] fornito, viene aperto un dialogo per selezionare il file.\>\""}], 
    ";"}], "\[IndentingNewLine]", "\[IndentingNewLine]", 
   RowBox[{"(*", 
    RowBox[{
     RowBox[{"definizione", " ", "della", " ", "funzione", " ", 
      RowBox[{"ConvertDICOMToJPEGs", ".", 
       RowBox[{"-", 
        RowBox[{"dicomFilePath_String", ":", "\"\<\>\"", ":", 
         RowBox[{
         "Definisce", " ", "un", " ", "parametro", " ", "chiamato", " ", 
          "dicomFilePath", " ", "che", " ", "deve", " ", "essere", " ", "una",
           " ", "stringa", " ", 
          RowBox[{
           RowBox[{"(", "String", ")"}], ".", "Se"}], " ", "non", " ", 
          "viene", " ", "fornito", " ", "alcun", " ", "valore"}]}]}]}]}], ",", 
     RowBox[{
      RowBox[{
      "il", " ", "suo", " ", "valore", " ", "predefinito", " ", "\[EGrave]", " ",
        "una", " ", "stringa", " ", "vuota", " ", 
       RowBox[{"\"\<\>\"", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"inputFile", "'"}], " ", "memorizzer\[AGrave]", " ", "il", " ",
        "percorso", " ", "del", " ", "file", " ", "fornito", " ", "o", " ", 
       RowBox[{"selezionato", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"actualInputFile", "'"}], " ", "memorizzer\[AGrave]", " ", 
       "il", " ", "percorso", " ", "assoluto", " ", "e", " ", "verificato", " ",
        "del", " ", 
       RowBox[{"file", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"baseName", "'"}], " ", "il", " ", "nome", " ", "del", " ", 
       "file", " ", "senza", " ", 
       RowBox[{"estensione", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"outputDir", "'"}], " ", "la", " ", "directory", " ", "di", " ", 
       RowBox[{"output", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"imageList", "'"}], " ", "la", " ", "lista", " ", "di", " ", 
       "immagini", " ", "importate", " ", "dal", " ", 
       RowBox[{"DICOM", ".", "'"}], 
       RowBox[{"img", "'"}], " ", "una", " ", "singola", " ", 
       RowBox[{"immagine", "/", 
        RowBox[{"slice", ".", "\[IndentingNewLine]", 
         RowBox[{"-", " ", "'"}]}]}], 
       RowBox[{"outputFileName", "'"}], " ", "il", " ", "nome", " ", 
       "completo", " ", "del", " ", "file", " ", "JPEG", " ", "da", " ", 
       RowBox[{"salvare", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"i", "'"}], " ", "un", " ", "contatore", " ", "per", " ", "i", 
       " ", 
       RowBox[{"cicli", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"indicesToExport", "'"}], " ", "indici", " ", "da", " ", 
       "esportare", " ", "tipo", " ", "90"}], "-", "99"}], ",", " ", 
     RowBox[{"220", "-", "240", "\[IndentingNewLine]", "-", " ", 
      RowBox[{"'", 
       RowBox[{"fileNamePrefix", "'"}], " ", "il", " ", "prefisso", " ", 
       RowBox[{"(", 
        RowBox[{"\"\<uno\>\"", " ", "o", " ", "\"\<unogt\>\""}], ")"}], " ", 
       "per", " ", "i", " ", "nomi", " ", "dei", " ", "file", " ", 
       RowBox[{"JPEG", ".", "\[IndentingNewLine]", 
        RowBox[{"-", " ", "'"}]}], 
       RowBox[{"datasetBaseDir", "'"}], " ", "il", " ", "percorso", " ", 
       "della", " ", "directory", " ", "\"\<dataset\>\"", " ", "di", " ", 
       RowBox[{"base", "."}]}]}]}], "*)"}], "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"ConvertDICOMToJPEGs", "[", 
     RowBox[{"dicomFilePath_String", ":", "\"\<\>\""}], "]"}], ":=", 
    RowBox[{"Module", "[", 
     RowBox[{
      RowBox[{"{", 
       RowBox[{
       "inputFile", ",", "actualInputFile", ",", "baseName", ",", "outputDir",
         ",", "imageList", ",", "img", ",", "outputFileName", ",", "i", ",", 
        "indicesToExport", ",", "fileNamePrefix", ",", "totalImages", ",", 
        "notebookDir", ",", "datasetBaseDir"}], "}"}], ",", 
      "\[IndentingNewLine]", "\[IndentingNewLine]", 
      RowBox[{"(*", 
       RowBox[{"Assegna", " ", 
        RowBox[{"a", "'"}], 
        RowBox[{"inputFile", "'"}], " ", "il", " ", "percorso", " ", "del", " ",
         "file", " ", 
        RowBox[{"DICOM", "."}]}], "*)"}], "\[IndentingNewLine]", 
      RowBox[{"(*", 
       RowBox[{"Controlla", " ", 
        RowBox[{"se", "'"}], 
        RowBox[{"dicomFilePath", "'"}], " ", "\[EGrave]", " ", "una", " ", 
        "stringa", " ", "vuota", " ", 
        RowBox[{
         RowBox[{"(", 
          RowBox[{"parametro", " ", "non", " ", "fornito"}], ")"}], "."}]}], 
       "*)"}], 
      RowBox[{
       RowBox[{"inputFile", "=", 
        RowBox[{"If", "[", 
         RowBox[{
          RowBox[{"dicomFilePath", "===", "\"\<\>\""}], ",", 
          RowBox[{"SystemDialogInput", "[", 
           RowBox[{"\"\<FileOpen\>\"", ",", 
            RowBox[{"{", 
             RowBox[{"\"\<*.dcm\>\"", ",", 
              RowBox[{"{", 
               RowBox[{"\"\<DICOM files\>\"", ",", 
                RowBox[{"{", "\"\<*.dcm\>\"", "}"}]}], "}"}]}], "}"}]}], 
           "]"}], ",", 
          RowBox[{"(*", 
           RowBox[{
            RowBox[{"Se", " ", "vuota"}], ",", 
            RowBox[{
            "apre", " ", "una", " ", "finestra", " ", "di", " ", "dialogo", " ",
              "di", " ", "sistema", " ", "per", " ", "permettere", " ", 
             RowBox[{"all", "'"}], "utente", " ", "di", " ", "selezionare", " ",
              "un", " ", 
             RowBox[{"file", ".", "dcm", "."}]}]}], "*)"}], "dicomFilePath"}],
          "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Altrimenti", ",", 
         RowBox[{"usa", " ", "il", " ", "valore", " ", 
          RowBox[{"di", "'"}], 
          RowBox[{"dicomFilePath", "'"}], " ", "fornito", " ", "come", " ", 
          RowBox[{"argomento", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Verifica", " ", "se", " ", 
         RowBox[{"l", "'"}], "utente", " ", "ha", " ", "annullato", " ", "la",
          " ", "finestra", " ", "di", " ", "dialogo", " ", 
         RowBox[{"(", 
          RowBox[{"'", 
           RowBox[{"$Canceled", "'"}]}], ")"}], " ", "o", " ", "se", " ", 
         "la", " ", "selezione", " ", "\[EGrave]", " ", "fallita", " ", 
         RowBox[{
          RowBox[{"(", 
           RowBox[{"'", 
            RowBox[{"$Failed", "'"}]}], ")"}], "."}]}], "*)"}], 
       "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{
          RowBox[{"inputFile", "===", "$Canceled"}], "||", 
          RowBox[{"inputFile", "===", "$Failed"}]}], ",", 
         RowBox[{
          RowBox[{
          "Print", "[", "\"\<Operazione annullata o file non selezionato.\>\"",
            "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Termina", " ", "la", " ", "funzione", " ", 
         RowBox[{"restituendo", "'"}], 
         RowBox[{
          RowBox[{"$Failed", "'"}], "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "2."}]}], " ", "Risolvi", " ", "il", " ", "percorso", 
          " ", "del", " ", "file", " ", "di", " ", 
          RowBox[{"input", "--"}]}], "-"}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Assegna", " ", 
         RowBox[{"a", "'"}], 
         RowBox[{"actualInputFile", "'"}], " ", "il", " ", "percorso", " ", 
         "assoluto", " ", "del", " ", "file", " ", "di", " ", 
         RowBox[{"input", "."}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"actualInputFile", "=", 
        RowBox[{"If", "[", 
         RowBox[{
          RowBox[{"FileExistsQ", "[", "inputFile", "]"}], ",", 
          "\[IndentingNewLine]", 
          RowBox[{"ExpandFileName", "[", "inputFile", "]"}], ",", 
          "\[IndentingNewLine]", 
          RowBox[{"(*", 
           RowBox[{
            RowBox[{
             RowBox[{"Se", "'"}], 
             RowBox[{"inputFile", "'"}], " ", "esiste", " ", 
             RowBox[{"(", 
              RowBox[{
              "potrebbe", " ", "essere", " ", "gi\[AGrave]", " ", "un", " ", 
               "percorso", " ", "assoluto", " ", "o", " ", "relativo", " ", 
               "valido", " ", "dalla", " ", "directory", " ", "corrente"}], 
              ")"}]}], ",", 
            RowBox[{
            "ne", " ", "espande", " ", "il", " ", "nome", " ", "per", " ", 
             "ottenere", " ", "un", " ", "percorso", " ", 
             RowBox[{"assoluto", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
          "\[IndentingNewLine]", 
          RowBox[{"ExpandFileName", "[", 
           RowBox[{"FileNameJoin", "[", 
            RowBox[{"{", 
             RowBox[{
              RowBox[{"NotebookDirectory", "[", "]"}], ",", "inputFile"}], 
             "}"}], "]"}], "]"}]}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Altrimenti", ",", 
         RowBox[{"assume", " ", 
          RowBox[{"che", "'"}], 
          RowBox[{"inputFile", "'"}], " ", "sia", " ", "relativo", " ", 
          "alla", " ", "directory", " ", "del", " ", "Notebook"}], ",", 
         RowBox[{"quindi", " ", "lo", " ", "unisce", " ", "a", " ", 
          RowBox[{"NotebookDirectory", "[", "]"}], " ", "e", " ", "poi", " ", 
          "ne", " ", "espande", " ", "il", " ", 
          RowBox[{"nome", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Inizio", " ", "del", " ", "blocco", " ", "di", " ", "controllo", " ",
          "per", " ", 
         RowBox[{"l", "'"}], "esistenza", " ", "del", " ", "file", " ", 
         "dopo", " ", "la", " ", "risoluzione", " ", "del", " ", 
         RowBox[{"percorso", "."}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{"!", 
          RowBox[{"FileExistsQ", "[", "actualInputFile", "]"}]}], ",", 
         "\[IndentingNewLine]", 
         RowBox[{"(*", 
          RowBox[{"Verifica", " ", 
           RowBox[{"se", "'"}], 
           RowBox[{"actualInputFile", "'"}], " ", "NON", " ", 
           RowBox[{"esiste", "."}]}], "*)"}], "\[IndentingNewLine]", 
         RowBox[{
          RowBox[{"Print", "[", 
           
           RowBox[{"\"\<Errore: Il file specificato non \[EGrave] stato \
trovato: \>\"", ",", "inputFile"}], "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Print", "[", 
           RowBox[{"\"\<Percorso tentato: \>\"", ",", "actualInputFile"}], 
           "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Termina", " ", "la", " ", "funzione", " ", 
         RowBox[{"restituendo", "'"}], 
         RowBox[{
          RowBox[{"$Failed", "'"}], "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<File DICOM da processare: \>\"", ",", 
         "actualInputFile"}], "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "3."}]}], " ", "Determina", " ", "i", " ", "percorsi",
           " ", "di", " ", "output", " ", 
          RowBox[{
           RowBox[{"(", 
            RowBox[{"Nuova", " ", 
             RowBox[{"Struttura", ":", " ", 
              RowBox[{
               RowBox[{".", 
                RowBox[{"/", "dataset"}]}], "/", "basename"}]}]}], ")"}], 
           "--"}]}], "-"}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"baseName", "=", 
        RowBox[{"FileBaseName", "[", "actualInputFile", "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Estrae", " ", "il", " ", "nome", " ", "base", " ", "del", " ", 
         "file", " ", "DICOM", " ", 
         RowBox[{"(", 
          RowBox[{"senza", " ", "estensione", " ", "e", " ", "percorso"}], 
          ")"}], " ", "e", " ", "lo", " ", "assegna", " ", 
         RowBox[{"a", "'"}], 
         RowBox[{
          RowBox[{"baseName", "'"}], "."}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"notebookDir", "=", 
        RowBox[{"NotebookDirectory", "[", "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Ottiene", " ", "il", " ", "percorso", " ", "della", " ", "directory",
          " ", "in", " ", "cui", " ", "si", " ", "trova", " ", "il", " ", 
         "notebook", " ", "corrente", " ", "e", " ", "lo", " ", "assegna", " ", 
         RowBox[{"a", "'"}], 
         RowBox[{
          RowBox[{"notebookDir", "'"}], "."}]}], "*)"}], 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"datasetBaseDir", "=", 
        RowBox[{"FileNameJoin", "[", 
         RowBox[{"{", 
          RowBox[{"notebookDir", ",", "\"\<dataset\>\""}], "}"}], "]"}]}], ";",
        "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Crea", " ", "il", " ", "percorso", " ", "completo", " ", "per", " ", 
         "la", " ", 
         RowBox[{"directory", "'"}], 
         RowBox[{"dataset", "'"}], " ", "che", " ", "si", " ", 
         "trover\[AGrave]", " ", 
         RowBox[{"all", "'"}], "interno", " ", "della", " ", "directory", " ",
          "del", " ", 
         RowBox[{"notebook", "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"outputDir", "=", 
        RowBox[{"FileNameJoin", "[", 
         RowBox[{"{", 
          RowBox[{"datasetBaseDir", ",", "baseName"}], "}"}], "]"}]}], ";", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
         "Crea", " ", "il", " ", "percorso", " ", "completo", " ", "per", " ",
           "la", " ", "directory", " ", "di", " ", "output", " ", "specifica",
           " ", 
          RowBox[{"(", 
           RowBox[{"es", ".", "\"\<./dataset/originali02/\>\""}], ")"}]}], ",", 
         RowBox[{
         "che", " ", "sar\[AGrave]", " ", "una", " ", "sottocartella", " ", 
          RowBox[{"di", "'"}], 
          RowBox[{"datasetBaseDir", "'"}], " ", "e", " ", "avr\[AGrave]", " ",
           "il", " ", "nome", " ", "del", " ", "file", " ", 
          RowBox[{"DICOM", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<La cartella di output specifica sar\[AGrave]: \>\"", ",",
          "outputDir"}], "]"}], ";", "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "4."}]}], " ", "Crea", " ", "le", " ", "cartelle", " ",
           "di", " ", "output", " ", 
          RowBox[{
           RowBox[{"(", 
            RowBox[{
             RowBox[{
              RowBox[{"prima", "'"}], 
              RowBox[{"dataset", "'"}]}], ",", 
             RowBox[{"poi", " ", "quella", " ", "specifica"}]}], ")"}], 
           "--"}]}], "-"}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Controlla", " ", "se", " ", "la", " ", 
         RowBox[{"directory", "'"}], 
         RowBox[{"datasetBaseDir", "'"}], " ", 
         RowBox[{"(", 
          RowBox[{"es", ".", "\"\<./dataset/\>\""}], ")"}], " ", "NON", " ", 
         RowBox[{"esiste", "."}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{"!", 
          RowBox[{"DirectoryExistsQ", "[", "datasetBaseDir", "]"}]}], ",", 
         RowBox[{
          RowBox[{"Print", "[", 
           
           RowBox[{"\"\<Creo la directory base del dataset: \>\"", ",", 
            "datasetBaseDir"}], "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Check", "[", 
           RowBox[{
            RowBox[{"CreateDirectory", "[", "datasetBaseDir", "]"}], ",", 
            "\[IndentingNewLine]", 
            RowBox[{"(*", 
             RowBox[{"Tenta", " ", "di", " ", 
              RowBox[{"creare", "'"}], 
              RowBox[{
               RowBox[{"datasetBaseDir", "'"}], ".", "'"}], 
              RowBox[{"Check", "'"}], " ", "cattura", " ", "eventuali", " ", 
              "messaggi", " ", "di", " ", "errore", " ", "generati", " ", 
              "da", " ", 
              RowBox[{"CreateDirectory", "."}]}], "*)"}], 
            "\[IndentingNewLine]", 
            RowBox[{
             RowBox[{"Print", "[", 
              RowBox[{"Style", "[", 
               RowBox[{
                RowBox[{"StringForm", "[", 
                 
                 RowBox[{"\"\<Errore durante la creazione della directory \
base '``'\>\"", ",", "datasetBaseDir"}], "]"}], ",", "Red"}], "]"}], "]"}], ";", 
             RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";"}]}], 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"Se", "'"}], 
          RowBox[{"CreateDirectory", "'"}], " ", "fallisce"}], ",", 
         RowBox[{
         "stampa", " ", "un", " ", "messaggio", " ", "di", " ", "errore", " ",
           "in", " ", "rosso", " ", "e", " ", "termina", " ", "la", " ", 
          "funzione", " ", 
          RowBox[{"restituendo", "'"}], 
          RowBox[{
           RowBox[{"$Failed", "'"}], "."}]}]}], "*)"}], "\[IndentingNewLine]",
        "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{"!", 
          RowBox[{"DirectoryExistsQ", "[", "outputDir", "]"}]}], ",", 
         RowBox[{
          RowBox[{"Print", "[", 
           
           RowBox[{"\"\<Creo la cartella di output specifica: \>\"", ",", 
            "outputDir"}], "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"(*", 
           RowBox[{
           "Controlla", " ", "se", " ", "la", " ", "directory", " ", "di", " ",
             "output", " ", "specifica", " ", 
            RowBox[{"(", 
             RowBox[{"es", ".", "\"\<./dataset/originali02/\>\""}], ")"}], " ",
             "NON", " ", 
            RowBox[{"esiste", "."}]}], "*)"}], "\[IndentingNewLine]", 
          "\[IndentingNewLine]", 
          RowBox[{"(*", 
           RowBox[{"Tenta", " ", "di", " ", 
            RowBox[{"creare", "'"}], 
            RowBox[{
             RowBox[{"outputDir", "'"}], "."}]}], "*)"}], 
          "\[IndentingNewLine]", 
          RowBox[{"Check", "[", 
           RowBox[{
            RowBox[{"CreateDirectory", "[", "outputDir", "]"}], ",", 
            RowBox[{
             RowBox[{"Print", "[", 
              RowBox[{"Style", "[", 
               RowBox[{
                RowBox[{"StringForm", "[", 
                 
                 RowBox[{"\"\<Errore durante la creazione della directory \
specifica '``'\>\"", ",", "outputDir"}], "]"}], ",", "Red"}], "]"}], "]"}], ";", 
             RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";"}], ",", 
         "\[IndentingNewLine]", 
         RowBox[{"(*", 
          RowBox[{
           RowBox[{
            RowBox[{"Se", "'"}], 
            RowBox[{"CreateDirectory", "'"}], " ", "fallisce"}], ",", 
           RowBox[{
           "stampa", " ", "un", " ", "messaggio", " ", "di", " ", "errore", " ",
             "in", " ", "rosso", " ", "e", " ", "termina", " ", "la", " ", 
            "funzione", " ", 
            RowBox[{"restituendo", "'"}], 
            RowBox[{
             RowBox[{"$Failed", "'"}], "."}]}]}], "*)"}], 
         "\[IndentingNewLine]", "\[IndentingNewLine]", 
         RowBox[{"Print", "[", 
          
          RowBox[{"\"\<La cartella di output specifica esiste gi\[AGrave]: \>\
\"", ",", "outputDir"}], "]"}]}], "]"}], ";", "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Inizio", " ", "della", " ", "sezione", " ", "5", " ", "per", " ", 
         "la", " ", "determinazione", " ", "del", " ", "prefisso", " ", "dei",
          " ", "nomi", " ", "dei", " ", 
         RowBox[{"file", "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Assegna", " ", 
         RowBox[{"a", "'"}], 
         RowBox[{"fileNamePrefix", "'"}], " ", "il", " ", "prefisso", " ", 
         "corretto", " ", "in", " ", "base", " ", "al", " ", "nome", " ", 
         "del", " ", "file", " ", 
         RowBox[{"DICOM", "."}]}], "*)"}], 
       RowBox[{"fileNamePrefix", "=", 
        RowBox[{"Which", "[", 
         RowBox[{
          RowBox[{"StringContainsQ", "[", 
           RowBox[{"baseName", ",", "\"\<originali\>\"", ",", 
            RowBox[{"IgnoreCase", "->", "True"}]}], "]"}], ",", 
          RowBox[{"(*", 
           RowBox[{"Controlla", " ", 
            RowBox[{"se", "'"}], 
            RowBox[{"baseName", "'"}], " ", "contiene", " ", "la", " ", 
            "stringa", " ", "\"\<originali\>\"", " ", 
            RowBox[{
             RowBox[{"(", 
              RowBox[{"ignorando", " ", 
               RowBox[{"maiuscole", "/", "minuscole"}]}], ")"}], "."}]}], 
           "*)"}], "\"\<uno\>\"", ",", "\[IndentingNewLine]", 
          "\[IndentingNewLine]", 
          RowBox[{"(*", 
           RowBox[{
            RowBox[{"Se", " ", "vero"}], ",", 
            RowBox[{"il", " ", "prefisso", " ", "\[EGrave]", " ", 
             RowBox[{"\"\<uno\>\"", ".", "Altrimenti"}]}], ",", 
            RowBox[{"controlla", " ", 
             RowBox[{"se", "'"}], 
             RowBox[{"baseName", "'"}], " ", "contiene", " ", 
             RowBox[{"\"\<groundtruth\>\"", "."}]}]}], "*)"}], 
          "\[IndentingNewLine]", 
          RowBox[{"StringContainsQ", "[", 
           RowBox[{"baseName", ",", "\"\<groundtruth\>\"", ",", 
            RowBox[{"IgnoreCase", "->", "True"}]}], "]"}], 
          ",", "\"\<unogt\>\"", ",", "\[IndentingNewLine]", 
          RowBox[{"(*", 
           RowBox[{
            RowBox[{"Se", " ", "vero"}], ",", 
            RowBox[{"il", " ", "prefisso", " ", "\[EGrave]", " ", 
             RowBox[{"\"\<unogt\>\"", "."}]}]}], "*)"}], 
          "\[IndentingNewLine]", "True", ",", 
          RowBox[{"(", 
           RowBox[{
            RowBox[{"Print", "[", 
             RowBox[{"Style", "[", 
              RowBox[{
               RowBox[{"StringForm", "[", 
                
                RowBox[{"\"\<Attenzione: Il nome base '``' non contiene n\
\[EAcute] 'originali' n\[EAcute] 'groundtruth'. Uso il prefisso 'img'.\>\"", ",",
                  "baseName"}], "]"}], ",", "Orange"}], "]"}], "]"}], 
            ";", "\"\<img\>\""}], ")"}]}], "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
         "Se", " ", "nessuna", " ", "delle", " ", "condizioni", " ", 
          "precedenti", " ", "\[EGrave]", " ", "vera", " ", 
          RowBox[{"(", 
           RowBox[{
            RowBox[{"clausola", "'"}], 
            RowBox[{"True", "'"}]}], ")"}]}], ",", 
         RowBox[{
         "stampa", " ", "un", " ", "avviso", " ", "in", " ", "arancione", " ",
           "e", " ", "usa", " ", "\"\<img\>\"", " ", "come", " ", "prefisso", 
          " ", "di", " ", 
          RowBox[{"default", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Prefisso per i nomi dei file di output determinato: \
'\>\"", ",", "fileNamePrefix", ",", "\"\<'\>\""}], "]"}], ";", 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Inizio", " ", "della", " ", "sezione", " ", "6", " ", "per", " ", 
         RowBox[{"l", "'"}], "importazione", " ", "delle", " ", 
         RowBox[{"immagini", "."}]}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{
       "Print", "[", "\"\<Importazione delle immagini dal file DICOM...\>\"", 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"imageList", "=", 
        RowBox[{"Check", "[", 
         RowBox[{
          RowBox[{"Import", "[", 
           RowBox[{"actualInputFile", ",", "\"\<ImageList\>\""}], "]"}], ",", 
          "$Failed"}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{
           RowBox[{
           "Tenta", " ", "di", " ", "importare", " ", "tutte", " ", "le", " ",
             "immagini", " ", 
            RowBox[{"(", "slice", ")"}], " ", "dal", " ", 
            RowBox[{"file", "'"}], 
            RowBox[{"actualInputFile", "'"}], " ", "come", " ", "una", " ", 
            "lista", " ", "di", " ", "oggetti", " ", 
            RowBox[{"Image", ".", "'"}], 
            RowBox[{
             RowBox[{"Import", "[", 
              RowBox[{"...", ",", "\"\<ImageList\>\""}], "]"}], "'"}], " ", 
            "\[EGrave]", " ", "specifico", " ", "per", " ", "ottenere", " ", 
            "una", " ", "lista", " ", "di", " ", "immagini", " ", "da", " ", 
            "file", " ", "multi"}], "-", 
           RowBox[{"immagine", " ", "come", " ", 
            RowBox[{"DICOM", ".", "'"}], 
            RowBox[{"Check", "'"}], " ", "intercetta", " ", "eventuali", " ", 
            "errori", " ", "durante", " ", 
            RowBox[{"l", "'"}], "importazione"}]}], ";", 
          RowBox[{"se", " ", "fallisce"}]}], ",", 
         RowBox[{"'", 
          RowBox[{"imageList", "'"}], " ", 
          RowBox[{"diventer\[AGrave]", "'"}], 
          RowBox[{
           RowBox[{"$Failed", "'"}], "."}]}]}], "*)"}], "\[IndentingNewLine]",
        "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{
          RowBox[{"imageList", "===", "$Failed"}], "||", 
          RowBox[{"!", 
           RowBox[{"ListQ", "[", "imageList", "]"}]}], "||", 
          RowBox[{
           RowBox[{"Length", "[", "imageList", "]"}], "==", "0"}]}], ",", 
         RowBox[{"(*", 
          RowBox[{
           RowBox[{"Controlla", " ", "se", " ", 
            RowBox[{"l", "'"}], "importazione", " ", "\[EGrave]", " ", 
            "fallita"}], ",", 
           RowBox[{"o", " ", 
            RowBox[{"se", "'"}], 
            RowBox[{"imageList", "'"}], " ", "non", " ", "\[EGrave]", " ", 
            "una", " ", "lista"}], ",", 
           RowBox[{
           "o", " ", "se", " ", "la", " ", "lista", " ", "\[EGrave]", " ", 
            RowBox[{"vuota", "."}]}]}], "*)"}], 
         RowBox[{
          RowBox[{"Print", "[", 
           RowBox[{"Style", "[", 
            RowBox[{
             RowBox[{"StringForm", "[", 
              
              RowBox[{"\"\<Errore durante l'importazione delle immagini dal \
file DICOM: '``'\>\"", ",", "actualInputFile"}], "]"}], ",", "Red"}], "]"}], 
           "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Print", "[", 
           RowBox[{"Style", "[", 
            
            RowBox[{"\"\<Il file potrebbe non essere un DICOM valido o non \
contenere immagini.\>\"", ",", "Red"}], "]"}], "]"}], ";", 
          "\[IndentingNewLine]", 
          RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Termina", " ", "la", " ", "funzione", " ", 
         RowBox[{"restituendo", "'"}], 
         RowBox[{
          RowBox[{"$Failed", "'"}], "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"totalImages", "=", 
        RowBox[{"Length", "[", "imageList", "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Calcola", " ", "il", " ", "numero", " ", "totale", " ", "di", " ", 
         "immagini", " ", 
         RowBox[{"(", "slice", ")"}], " ", "importate", " ", "e", " ", "lo", " ",
          "assegna", " ", 
         RowBox[{"a", "'"}], 
         RowBox[{
          RowBox[{"totalImages", "'"}], "."}]}], "*)"}], 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Trovate \>\"", ",", "totalImages", 
         ",", "\"\< immagini/slices totali nel file.\>\""}], "]"}], ";", 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "7."}]}], " ", "Definisci", " ", "gli", " ", "indici",
           " ", "da", " ", "esportare", " ", "ed", " ", "esegui", " ", 
          RowBox[{"l", "'"}], "esportazione", " ", 
          RowBox[{"selettiva", "--"}]}], "-"}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{"indicesToExport", "=", 
        RowBox[{"Join", "[", 
         RowBox[{
          RowBox[{"Range", "[", 
           RowBox[{"90", ",", "100"}], "]"}], ",", 
          RowBox[{"Range", "[", 
           RowBox[{"140", ",", "150"}], "]"}], ",", 
          RowBox[{"Range", "[", 
           RowBox[{"160", ",", "170"}], "]"}], ",", 
          RowBox[{"Range", "[", 
           RowBox[{"190", ",", "200"}], "]"}], ",", 
          RowBox[{"Range", "[", 
           RowBox[{"220", ",", "230"}], "]"}]}], "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Definisce", " ", "la", " ", 
         RowBox[{"lista", "'"}], 
         RowBox[{"indicesToExport", "'"}], " ", "unendo", " ", "diversi", " ",
          "intervalli", " ", "di", " ", "numeri", " ", 
         RowBox[{
          RowBox[{"(", 
           RowBox[{
            RowBox[{
             RowBox[{"es", ".", "da"}], " ", "90", " ", "a", " ", "100", " ", 
             "inclusi"}], ",", 
            RowBox[{"ecc", "."}]}], ")"}], ".", "Questi"}], " ", "sono", " ", 
         "gli", " ", "indici", " ", "delle", " ", "slice", " ", "che", " ", 
         "si", " ", "desidera", " ", 
         RowBox[{"esportare", "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Esportazione richiesta per gli indici (se presenti nel \
file): \>\"", ",", 
         RowBox[{"Short", "[", "indicesToExport", "]"}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Stampa", " ", "un", " ", "messaggio", " ", "con", " ", "la", " ", 
         "lista", " ", "degli", " ", "indici", " ", "richiesti", " ", 
         RowBox[{
          RowBox[{"(", 
           RowBox[{
            RowBox[{"utilizzando", "'"}], 
            RowBox[{"Short", "'"}], " ", "se", " ", "la", " ", "lista", " ", 
            "\[EGrave]", " ", "molto", " ", "lunga", " ", "per", " ", "una", " ",
             "visualizzazione", " ", "concisa"}], ")"}], "."}]}], "*)"}], 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{
       "Print", 
        "[", "\"\<Esportazione delle immagini selezionate in formato \
JPEG...\>\"", "]"}], ";", "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"Do", "[", 
        RowBox[{
         RowBox[{"If", "[", 
          RowBox[{
           RowBox[{"1", "<=", "i", "<=", "totalImages"}], ",", 
           RowBox[{
            RowBox[{"img", "=", 
             RowBox[{"imageList", "[", 
              RowBox[{"[", "i", "]"}], "]"}]}], ";", "\[IndentingNewLine]", 
            RowBox[{"(*", 
             RowBox[{
              RowBox[{
               RowBox[{
                RowBox[{"Inizio", " ", "di", " ", "un", " ", 
                 RowBox[{"ciclo", "'"}], 
                 RowBox[{"Do", "'"}], " ", "che", " ", "itera", " ", "su", " ",
                  "ogni", " ", 
                 RowBox[{"indice", "'"}], 
                 RowBox[{"i", "'"}], " ", "nella", " ", 
                 RowBox[{"lista", "'"}], 
                 RowBox[{
                  RowBox[{"indicesToExport", "'"}], ".", 
                  "\[IndentingNewLine]", 
                  RowBox[{"-", 
                   RowBox[{"If", "[", 
                    RowBox[{
                    RowBox[{"1", "<=", "i", "<=", "totalImages"}], ",", 
                    "..."}], "]"}]}]}]}], ":", " ", 
                RowBox[{"Controlla", " ", "se", " ", 
                 RowBox[{"l", "'"}], 
                 RowBox[{"indice", "'"}], 
                 RowBox[{"i", "'"}], " ", "\[EGrave]", " ", "valido", " ", 
                 RowBox[{
                  RowBox[{"(", 
                   RowBox[{
                   "compreso", " ", "tra", " ", "1", " ", "e", " ", "il", " ",
                     "numero", " ", "totale", " ", "di", " ", "immagini", " ",
                     "disponibili"}], ")"}], ".", "\[IndentingNewLine]", 
                  RowBox[{"-", "img"}]}]}]}], "=", 
               RowBox[{
                RowBox[{"imageList", "[", 
                 RowBox[{"[", "i", "]"}], "]"}], ":", " ", 
                RowBox[{"Se", " ", 
                 RowBox[{"l", "'"}], "indice", " ", "\[EGrave]", " ", 
                 "valido"}]}]}], ",", " ", 
              RowBox[{"estrae", " ", 
               RowBox[{"l", "'"}], "immagine", " ", "corrispondente", " ", 
               RowBox[{"dalla", "'"}], 
               RowBox[{"imageList", "'"}], " ", 
               RowBox[{
                RowBox[{"(", 
                 RowBox[{
                  RowBox[{"l", "'"}], "indicizzazione", " ", "delle", " ", 
                  "liste", " ", "in", " ", "Mathematica", " ", "parte", " ", 
                  "da", " ", "1"}], ")"}], "."}]}]}], "\[IndentingNewLine]", 
             "*)"}], "\[IndentingNewLine]", "\[IndentingNewLine]", 
            RowBox[{"outputFileName", "=", 
             RowBox[{"FileNameJoin", "[", 
              RowBox[{"{", 
               RowBox[{"outputDir", ",", 
                RowBox[{"fileNamePrefix", "<>", 
                 RowBox[{"ToString", "[", "i", "]"}], 
                 "<>", "\"\<.jpg\>\""}]}], "}"}], "]"}]}], ";", 
            "\[IndentingNewLine]", 
            RowBox[{"(*", 
             RowBox[{
              RowBox[{
              "Costruisce", " ", "il", " ", "nome", " ", "completo", " ", 
               "del", " ", "file", " ", "JPEG", " ", "di", " ", "output"}], ",",
               " ", 
              RowBox[{
              "unendo", " ", "la", " ", "directory", " ", "di", " ", 
               "output"}], ",", " ", 
              RowBox[{"il", " ", "prefisso", " ", "del", " ", "nome"}], ",", 
              " ", 
              RowBox[{
               RowBox[{"l", "'"}], "indice", " ", "corrente", " ", 
               RowBox[{"(", 
                RowBox[{"convertito", " ", "in", " ", "stringa"}], ")"}], " ",
                "e", " ", 
               RowBox[{"l", "'"}], "estensione", " ", 
               RowBox[{"\"\<.jpg\>\"", "."}]}]}], "*)"}], 
            "\[IndentingNewLine]", "\[IndentingNewLine]", 
            RowBox[{"Check", "[", 
             RowBox[{
              RowBox[{
               RowBox[{"Export", "[", 
                RowBox[{"outputFileName", ",", "img", ",", "\"\<JPEG\>\""}], 
                "]"}], ";", "\[IndentingNewLine]", 
               RowBox[{"(*", 
                RowBox[{"Tenta", " ", "di", " ", "esportare", " ", 
                 RowBox[{"l", "'"}], 
                 RowBox[{"immagine", "'"}], 
                 RowBox[{"img", "'"}], " ", "nel", " ", 
                 RowBox[{"file", "'"}], 
                 RowBox[{"outputFileName", "'"}], " ", "in", " ", "formato", " ", 
                 RowBox[{"JPEG", ".", "'"}], 
                 RowBox[{"Check", "'"}], " ", "intercetta", " ", "eventuali", 
                 " ", 
                 RowBox[{"errori", "."}]}], "*)"}], "\[IndentingNewLine]", 
               "\[IndentingNewLine]", 
               RowBox[{"Print", "[", 
                RowBox[{"\"\<Esportato: \>\"", ",", "outputFileName"}], 
                "]"}]}], ",", "\[IndentingNewLine]", 
              RowBox[{"Print", "[", 
               RowBox[{"Style", "[", 
                RowBox[{
                 RowBox[{"StringForm", "[", 
                  
                  RowBox[{"\"\<Errore durante l'esportazione dell'immagine \
con indice '``' in '``'\>\"", ",", "i", ",", "outputFileName"}], "]"}], ",", 
                 "Red"}], "]"}], "]"}]}], "]"}], ";"}], ",", 
           "\[IndentingNewLine]", 
           RowBox[{"(*", 
            RowBox[{
             RowBox[{"Se", " ", 
              RowBox[{"l", "'"}], "esportazione", " ", "fallisce"}], ",", 
             RowBox[{
             "stampa", " ", "un", " ", "messaggio", " ", "di", " ", "errore", 
              " ", "in", " ", 
              RowBox[{"rosso", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
           "\[IndentingNewLine]", 
           RowBox[{
            RowBox[{"Print", "[", 
             RowBox[{"Style", "[", 
              RowBox[{
               RowBox[{"StringForm", "[", 
                
                RowBox[{"\"\<Attenzione: L'indice richiesto '``' non \
\[EGrave] presente nel file DICOM (valido da 1 a '``'). Salto.\>\"", ",", "i",
                  ",", "totalImages"}], "]"}], ",", "Orange"}], "]"}], "]"}], 
            ";"}]}], "]"}], ",", "\[IndentingNewLine]", 
         RowBox[{"(*", 
          RowBox[{
           RowBox[{"Se", " ", 
            RowBox[{"l", "'"}], 
            RowBox[{"indice", "'"}], 
            RowBox[{"i", "'"}], " ", "non", " ", "\[EGrave]", " ", "valido", " ", 
            RowBox[{"(", 
             RowBox[{
              RowBox[{"blocco", "'"}], 
              RowBox[{"else", "'"}], " ", 
              RowBox[{"dell", "'"}], "If"}], ")"}]}], ",", 
           RowBox[{
           "stampa", " ", "un", " ", "messaggio", " ", "di", " ", "avviso", " ",
             "in", " ", "arancione", " ", "indicando", " ", "che", " ", 
            RowBox[{"l", "'"}], "indice", " ", "\[EGrave]", " ", "fuori", " ",
             "range", " ", "e", " ", "viene", " ", 
            RowBox[{"saltato", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
         RowBox[{"{", 
          RowBox[{"i", ",", "indicesToExport"}], "}"}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Specifica", " ", "che", " ", "il", " ", 
         RowBox[{"ciclo", " ", "'"}], 
         RowBox[{"Do", "'"}], " ", "deve", " ", "iterare", " ", "sulla", " ", 
         RowBox[{"lista", "'"}], 
         RowBox[{
          RowBox[{"indicesToExport", "'"}], "."}]}], "*)"}], 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "8."}]}], " ", "Messaggi", " ", 
          RowBox[{"Finali", "--"}]}], "-"}], "*)"}], "\[IndentingNewLine]", 
       RowBox[{
       "Print", 
        "[", "\"\<-----------------------------------------------------\>\"", 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Conversione selettiva completata per: \>\"", ",", 
         "baseName"}], "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Le immagini JPEG richieste sono state salvate in: \>\"", 
         ",", "outputDir"}], "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{
       "Print", 
        "[", "\"\<-----------------------------------------------------\>\"", 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"Return", "[", "outputDir", "]"}], ";"}]}], "]"}]}], 
   "\[IndentingNewLine]", 
   RowBox[{"(*", 
    RowBox[{
    "Restituisce", " ", "il", " ", "percorso", " ", "della", " ", "directory",
      " ", "di", " ", "output", " ", 
     RowBox[{"(", 
      RowBox[{"'", 
       RowBox[{"outputDir", "'"}]}], ")"}], " ", "come", " ", "risultato", " ",
      "della", " ", 
     RowBox[{"funzione", "."}]}], "*)"}], "\[IndentingNewLine]", 
   "\[IndentingNewLine]", "\[IndentingNewLine]", "\n", "\[IndentingNewLine]", 
   "\[IndentingNewLine]", "\[IndentingNewLine]", "\[IndentingNewLine]", 
   "\[IndentingNewLine]", "\[IndentingNewLine]"}]}]], "Input",
 CellChangeTimes->{
  3.955018267359686*^9, 3.9550187430966816`*^9, {3.955019430014202*^9, 
   3.9550194370813084`*^9}, 3.9550197296207657`*^9, {3.9556020099757977`*^9, 
   3.9556020508486214`*^9}, {3.9556020920536613`*^9, 3.955602457983721*^9}, {
   3.955602494660633*^9, 3.955603062731262*^9}, {3.955603157800995*^9, 
   3.955603209982464*^9}, {3.9556032683892727`*^9, 3.955603429071377*^9}, {
   3.955603491942541*^9, 
   3.9556036815089016`*^9}},ExpressionUUID->"c7b44f8d-3a7b-1c4b-a183-\
039ba3507278"],

Cell[BoxData[
 RowBox[{
  RowBox[{"(*", 
   RowBox[{
    RowBox[{
    "Inizia", " ", "la", " ", "definizione", " ", "di", " ", "una", " ", 
     "lista", " ", 
     RowBox[{"chiamata", "'"}], 
     RowBox[{
      RowBox[{"listaFileDICOM", "'"}], ".", "Questa"}], " ", "lista", " ", 
     "contiene", " ", "stringhe"}], ",", 
    RowBox[{"ognuna", " ", "rappresentante", " ", "il", " ", "nome", " ", 
     RowBox[{"(", 
      RowBox[{"o", " ", "percorso"}], ")"}], " ", "di", " ", "un", " ", 
     "file", " ", "DICOM", " ", "da", " ", 
     RowBox[{"processare", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
  RowBox[{
   RowBox[{"listaFileDICOM", "=", 
    RowBox[{"{", 
     RowBox[{"\"\<originali02.dcm\>\"", ",", "\"\<groundtruth02.dcm\>\"", 
      ",", "\"\<originali03.dcm\>\"", ",", "\"\<groundtruth03.dcm\>\""}], " ",
      "}"}]}], "\[IndentingNewLine]", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"Print", "[", 
     RowBox[{"Style", "[", 
      RowBox[{"\"\<--- INIZIO ELABORAZIONE BATCH ---\>\"", ",", "Bold"}], 
      "]"}], "]"}], ";"}], "\n", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"Print", "[", 
     RowBox[{"\"\<Numero totale di file da processare: \>\"", ",", 
      RowBox[{"Length", "[", "listaFileDICOM", "]"}]}], "]"}], ";"}], "\n", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{
    "Print", "[", \
"\"\<-----------------------------------------------------\>\"", "]"}], ";"}],
    "\[IndentingNewLine]", "\[IndentingNewLine]", "\[IndentingNewLine]", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"Do", "[", 
     RowBox[{
      RowBox[{
       RowBox[{"nomeFileCorrente", "=", 
        RowBox[{"listaFileDICOM", "[", 
         RowBox[{"[", "k", "]"}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{
           RowBox[{"Inizio", " ", "di", " ", "un", " ", 
            RowBox[{"ciclo", "'"}], 
            RowBox[{
             RowBox[{"Do", "'"}], ".", " ", "Questo"}], " ", "ciclo", " ", 
            "itera", " ", "per", " ", "un", " ", "numero", " ", "di", " ", 
            "volte", " ", "pari", " ", "alla", " ", "lunghezza", " ", "della",
             " ", 
            RowBox[{"lista", "'"}], 
            RowBox[{
             RowBox[{"listaFileDICOM", "'"}], ".", "\[IndentingNewLine]", 
             RowBox[{"-", 
              RowBox[{"{", 
               RowBox[{"k", ",", 
                RowBox[{"Length", "[", "listaFileDICOM", "]"}]}], "}"}]}]}], " ", 
            RowBox[{"(", 
             RowBox[{
             "specificato", " ", "alla", " ", "fine", " ", "del", " ", "Do"}],
              ")"}]}], ":", " ", 
           RowBox[{"Indica", " ", "che", " ", "la", " ", 
            RowBox[{"variabile", "'"}], 
            RowBox[{"k", "'"}], " ", "prender\[AGrave]", " ", "valori", " ", 
            "da", " ", "1", " ", "fino", " ", "al", " ", "numero", " ", 
            "totale", " ", "di", " ", "elementi", " ", "nella", " ", 
            RowBox[{"lista", ".", "\[IndentingNewLine]", 
             RowBox[{"-", "nomeFileCorrente"}]}]}]}], "=", 
          RowBox[{
           RowBox[{"listaFileDICOM", "[", 
            RowBox[{"[", "k", "]"}], "]"}], ":", 
           RowBox[{"In", " ", "ogni", " ", "iterazione"}]}]}], ",", 
         RowBox[{
          RowBox[{"assegna", " ", "alla", " ", 
           RowBox[{"variabile", "'"}], 
           RowBox[{"nomeFileCorrente", "'"}], " ", 
           RowBox[{"l", "'"}], "k"}], "-", 
          RowBox[{"esimo", " ", "elemento", " ", 
           RowBox[{"(", 
            RowBox[{
            "cio\[EGrave]", " ", "il", " ", "nome", " ", "del", " ", "file"}],
             ")"}], " ", 
           RowBox[{"dalla", "'"}], 
           RowBox[{
            RowBox[{"listaFileDICOM", "'"}], ".", "\[IndentingNewLine]", 
            RowBox[{"L", "'"}]}], "indicizzazione", " ", "delle", " ", 
           "liste", " ", "in", " ", "Mathematica", " ", "parte", " ", "da", " ",
            "1."}]}]}], "*)"}], "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"Style", "[", 
         RowBox[{
          RowBox[{"StringForm", "[", 
           RowBox[{"\"\<Processando file [``/``]: ``\>\"", ",", "k", ",", 
            RowBox[{"Length", "[", "listaFileDICOM", "]"}], ",", 
            "nomeFileCorrente"}], "]"}], ",", "Bold"}], "]"}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Stampa", " ", "un", " ", "messaggio", " ", "formattato", " ", "in", " ",
          "grassetto", " ", "che", " ", "indica", " ", "quale", " ", "file", " ",
          "si", " ", "sta", " ", "processando", " ", 
         RowBox[{
          RowBox[{"(", 
           RowBox[{
           "es", ".", "\"\<Processando file [1/4]: originali02.dcm\>\""}], 
           ")"}], ".", "\[IndentingNewLine]", 
          RowBox[{"-", 
           RowBox[{"StringForm", "[", 
            RowBox[{"\"\<...\>\"", ",", "k", ",", 
             RowBox[{"Length", "[", "listaFileDICOM", "]"}], ",", 
             "nomeFileCorrente"}], "]"}]}]}], " ", "crea", " ", "la", " ", 
         "stringa", " ", "sostituendo", " ", "i", " ", 
         RowBox[{"segnaposto", "'"}], 
         RowBox[{"``", "'"}], " ", "con", " ", "i", " ", "valori", " ", 
         "delle", " ", "variabili", " ", 
         RowBox[{"fornite", "."}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", "\[IndentingNewLine]", 
       RowBox[{"Check", "[", 
        RowBox[{
         RowBox[{"ConvertDICOMToJPEGs", "[", "nomeFileCorrente", "]"}], ",", 
         "\[IndentingNewLine]", 
         RowBox[{"(*", 
          RowBox[{"Chiama", " ", "la", " ", 
           RowBox[{"funzione", "'"}], 
           RowBox[{"ConvertDICOMToJPEGs", "'"}], " ", "passando", " ", 
           RowBox[{"il", "'"}], 
           RowBox[{"nomeFileCorrente", "'"}], " ", "come", " ", 
           RowBox[{"argomento", "."}]}], "*)"}], "\[IndentingNewLine]", 
         "\[IndentingNewLine]", 
         RowBox[{"Print", "[", 
          RowBox[{"Style", "[", 
           RowBox[{
            RowBox[{"StringForm", "[", 
             
             RowBox[{"\"\<Elaborazione fallita per il file: ``. Passo al \
successivo.\>\"", ",", "nomeFileCorrente"}], "]"}], ",", "Red"}], "]"}], 
          "]"}]}], "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{"Commento", ":", 
          RowBox[{"Questo", " ", 
           RowBox[{"\[EGrave]", "'"}], 
           RowBox[{"failexpr", "'"}], " ", "di", " ", 
           RowBox[{"Chceck", ".", 
            RowBox[{"Se", "'"}]}], 
           RowBox[{
            RowBox[{"ConvertDICOMToJPEGs", "[", "nomeFileCorrente", "]"}], 
            "'"}], " ", "fallisce", " ", 
           RowBox[{"(", 
            RowBox[{
             RowBox[{"ad", " ", "esempio"}], ",", 
             RowBox[{
              RowBox[{"restituisce", "'"}], 
              RowBox[{"$Failed", "'"}]}]}], ")"}]}]}], ",", 
         RowBox[{"allora", " ", "viene", " ", "eseguita", " ", "questa", " ", 
          RowBox[{"istruzione", "'"}], 
          RowBox[{
           RowBox[{"Print", "'"}], ".", "Stampa"}], " ", "un", " ", 
          "messaggio", " ", "di", " ", "errore", " ", "in", " ", "rosso"}], ",", 
         RowBox[{
         "indicando", " ", "quale", " ", "file", " ", "non", " ", "\[EGrave]",
           " ", "stato", " ", "processato", " ", 
          RowBox[{"correttamente", ".", "Il"}], " ", 
          RowBox[{"ciclo", "'"}], 
          RowBox[{"Do", "'"}], " ", "continuer\[AGrave]", " ", "comunque", " ",
           "con", " ", "il", " ", "file", " ", 
          RowBox[{"successivo", "."}]}]}], "*)"}], "\[IndentingNewLine]", 
       "\[IndentingNewLine]", 
       RowBox[{
       "Print", 
        "[", "\"\<-----------------------------------------------------\>\"", 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"Pause", "[", "0.5", "]"}], ";"}], " ", 
      RowBox[{"(*", 
       RowBox[{"Opzionale", ":", " ", 
        RowBox[{
        "piccola", " ", "pausa", " ", "per", " ", "leggibilit\[AGrave]", " ", 
         RowBox[{"dell", "'"}], "output"}]}], "*)"}], "\[IndentingNewLine]", ",", 
      RowBox[{"{", 
       RowBox[{"k", ",", 
        RowBox[{"Length", "[", "listaFileDICOM", "]"}]}], "}"}]}], " ", "]"}],
     ";"}], "\[IndentingNewLine]", 
   RowBox[{"(*", 
    RowBox[{"Fine", " ", "del", " ", 
     RowBox[{"blocco", "'"}], 
     RowBox[{
      RowBox[{"Do", "'"}], ".", "La"}], " ", 
     RowBox[{"variabile", "'"}], 
     RowBox[{"k", "'"}], " ", "deve", " ", "iterare", " ", "da", " ", "1", " ",
      "fino", " ", "al", " ", "numero", " ", "di", " ", "elementi", " ", 
     RowBox[{"in", "'"}], 
     RowBox[{
      RowBox[{"listaFileDICOM", "'"}], "."}]}], "*)"}], "\n", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"Print", "[", 
     RowBox[{"Style", "[", 
      RowBox[{"\"\<--- ELABORAZIONE BATCH COMPLETATA ---\>\"", ",", "Bold"}], 
      "]"}], "]"}], ";"}], "\n"}]}]], "Input",
 CellChangeTimes->{
  3.9550194425167084`*^9, {3.9550197466569405`*^9, 3.9550197930963554`*^9}, {
   3.955603737857151*^9, 
   3.9556040255189304`*^9}},ExpressionUUID->"7805467c-d824-e84d-a171-\
081de65475c1"]
},
WindowSize->{1440, 747.75},
WindowMargins->{{-6, Automatic}, {Automatic, -6}},
Magnification:>0.8 Inherited,
FrontEndVersion->"14.2 for Microsoft Windows (64-bit) (December 26, 2024)",
StyleDefinitions->"Default.nb",
ExpressionUUID->"28a03f05-ec1e-f748-92b1-7f9c4800b2e0"
]
(* End of Notebook Content *)

(* Internal cache information *)
(*CellTagsOutline
CellTagsIndex->{}
*)
(*CellTagsIndex
CellTagsIndex->{}
*)
(*NotebookFileOutline
Notebook[{
Cell[554, 20, 40984, 906, 2427, "Input",ExpressionUUID->"c7b44f8d-3a7b-1c4b-a183-039ba3507278"],
Cell[41541, 928, 9176, 206, 555, "Input",ExpressionUUID->"7805467c-d824-e84d-a171-081de65475c1"]
}
]
*)


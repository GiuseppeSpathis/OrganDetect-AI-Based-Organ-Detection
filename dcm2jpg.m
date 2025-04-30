(* Content-type: application/vnd.wolfram.mathematica *)

(*** Wolfram Notebook File ***)
(* http://www.wolfram.com/nb *)

(* CreatedBy='Wolfram 14.2' *)

(*CacheID: 234*)
(* Internal cache information:
NotebookFileLineBreakTest
NotebookFileLineBreakTest
NotebookDataPosition[       154,          7]
NotebookDataLength[     23435,        573]
NotebookOptionsPosition[     22939,        557]
NotebookOutlinePosition[     23377,        574]
CellTagsIndexPosition[     23334,        571]
WindowFrame->Normal*)

(* Beginning of Notebook Content *)
Notebook[{
Cell[BoxData[
 RowBox[{
  RowBox[{"(*", " ", 
   RowBox[{"::", "Package", "::"}], "*)"}], 
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
    ";"}], "\n", "\[IndentingNewLine]", "\[IndentingNewLine]", 
   RowBox[{
    RowBox[{"ConvertDICOMToJPEGs", "[", 
     RowBox[{"dicomFilePath_String", ":", "\"\<\>\""}], "]"}], ":=", 
    RowBox[{"Module", "[", 
     RowBox[{
      RowBox[{"{", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{"Variabili", " ", "per", " ", "percorsi"}], ",", "immagini", 
         ",", 
         RowBox[{"ecc", "."}]}], "*)"}], 
       RowBox[{
       "inputFile", ",", "actualInputFile", ",", "baseName", ",", "outputDir",
         ",", "imageList", ",", "img", ",", "outputFileName", ",", "i", ",", 
        RowBox[{"(*", 
         RowBox[{
         "Variabili", " ", "per", " ", "la", " ", "nuova", " ", "logica"}], 
         "*)"}], "indicesToExport", ",", "fileNamePrefix", ",", "totalImages",
         ",", 
        RowBox[{"(*", 
         RowBox[{
         "Variabili", " ", "per", " ", "la", " ", "directory", " ", "del", " ",
           "dataset"}], "*)"}], "notebookDir", ",", "datasetBaseDir"}], "}"}],
       ",", 
      RowBox[{"(*", 
       RowBox[{
        RowBox[{
         RowBox[{"--", 
          RowBox[{"-", "1."}]}], " ", "Determina", " ", "il", " ", "file", " ",
          "di", " ", "input", " ", 
         RowBox[{"effettivo", "--"}]}], "-"}], "*)"}], 
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
           "]"}], ",", "dicomFilePath"}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Controlla", " ", "se", " ", 
         RowBox[{"l", "'"}], "utente", " ", "ha", " ", "annullato"}], "*)"}], 
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
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "2."}]}], " ", "Risolvi", " ", "il", " ", "percorso", 
          " ", "del", " ", "file", " ", "di", " ", 
          RowBox[{"input", "--"}]}], "-"}], "*)"}], 
       RowBox[{"actualInputFile", "=", 
        RowBox[{"If", "[", 
         RowBox[{
          RowBox[{"FileExistsQ", "[", "inputFile", "]"}], ",", 
          RowBox[{"ExpandFileName", "[", "inputFile", "]"}], ",", 
          RowBox[{"ExpandFileName", "[", 
           RowBox[{"FileNameJoin", "[", 
            RowBox[{"{", 
             RowBox[{
              RowBox[{"NotebookDirectory", "[", "]"}], ",", "inputFile"}], 
             "}"}], "]"}], "]"}]}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Controlla", " ", "se", " ", "il", " ", "file", " ", "esiste", " ", 
         "dopo", " ", "aver", " ", "risolto", " ", "il", " ", "percorso"}], 
        "*)"}], 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{"!", 
          RowBox[{"FileExistsQ", "[", "actualInputFile", "]"}]}], ",", 
         RowBox[{
          RowBox[{"Print", "[", 
           
           RowBox[{"\"\<Errore: Il file specificato non \[EGrave] stato \
trovato: \>\"", ",", "inputFile"}], "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Print", "[", 
           RowBox[{"\"\<Percorso tentato: \>\"", ",", "actualInputFile"}], 
           "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";", 
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
           "--"}]}], "-"}], "*)"}], 
       RowBox[{"baseName", "=", 
        RowBox[{"FileBaseName", "[", "actualInputFile", "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"notebookDir", "=", 
        RowBox[{"NotebookDirectory", "[", "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{"Definisce", " ", "il", " ", "percorso", " ", "della", " ", 
         RowBox[{"directory", "'"}], 
         RowBox[{"dataset", "'"}], " ", "relativa", " ", "al", " ", 
         "notebook"}], "*)"}], 
       RowBox[{"datasetBaseDir", "=", 
        RowBox[{"FileNameJoin", "[", 
         RowBox[{"{", 
          RowBox[{"notebookDir", ",", "\"\<dataset\>\""}], "}"}], "]"}]}], ";",
        "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
        "Definisce", " ", "il", " ", "percorso", " ", "della", " ", 
         "cartella", " ", "di", " ", "output", " ", "specifica", " ", 
         RowBox[{"DENTRO", "'"}], 
         RowBox[{"dataset", "'"}]}], "*)"}], 
       RowBox[{"outputDir", "=", 
        RowBox[{"FileNameJoin", "[", 
         RowBox[{"{", 
          RowBox[{"datasetBaseDir", ",", "baseName"}], "}"}], "]"}]}], ";", 
       RowBox[{"(*", "MODIFICATO", "*)"}], 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<La cartella di output specifica sar\[AGrave]: \>\"", ",",
          "outputDir"}], "]"}], ";", "\[IndentingNewLine]", 
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
           "--"}]}], "-"}], "*)"}], 
       RowBox[{"(*", 
        RowBox[{"Crea", " ", "la", " ", 
         RowBox[{"directory", "'"}], 
         RowBox[{"dataset", "'"}], " ", "se", " ", "non", " ", "esiste"}], 
        "*)"}], 
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
        "Crea", " ", "la", " ", "cartella", " ", "di", " ", "output", " ", 
         "specifica", " ", 
         RowBox[{"(", 
          RowBox[{
           RowBox[{"es", ".", "'"}], 
           RowBox[{"originali02", "'"}]}], ")"}], " ", 
         RowBox[{"dentro", "'"}], 
         RowBox[{"dataset", "'"}]}], "*)"}], 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{"!", 
          RowBox[{"DirectoryExistsQ", "[", "outputDir", "]"}]}], ",", 
         RowBox[{
          RowBox[{"Print", "[", 
           
           RowBox[{"\"\<Creo la cartella di output specifica: \>\"", ",", 
            "outputDir"}], "]"}], ";", "\[IndentingNewLine]", 
          RowBox[{"Check", "[", 
           RowBox[{
            RowBox[{"CreateDirectory", "[", "outputDir", "]"}], ",", 
            RowBox[{"(*", 
             RowBox[{
             "Non", " ", "serve", " ", "pi\[UGrave]", " ", 
              "CreateIntermediateDirectories", " ", "se", " ", 
              "datasetBaseDir", " ", "\[EGrave]", " ", "gi\[AGrave]", " ", 
              "creata"}], "*)"}], 
            RowBox[{
             RowBox[{"Print", "[", 
              RowBox[{"Style", "[", 
               RowBox[{
                RowBox[{"StringForm", "[", 
                 
                 RowBox[{"\"\<Errore durante la creazione della directory \
specifica '``'\>\"", ",", "outputDir"}], "]"}], ",", "Red"}], "]"}], "]"}], ";", 
             RowBox[{"Return", "[", "$Failed", "]"}]}]}], "]"}], ";"}], ",", 
         RowBox[{"Print", "[", 
          
          RowBox[{"\"\<La cartella di output specifica esiste gi\[AGrave]: \>\
\"", ",", "outputDir"}], "]"}]}], "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "5."}]}], " ", "Determina", " ", "il", " ", 
          "prefisso", " ", "per", " ", "i", " ", "nomi", " ", "dei", " ", 
          "file", " ", "di", " ", 
          RowBox[{"output", "--"}]}], "-"}], "*)"}], 
       RowBox[{"fileNamePrefix", "=", 
        RowBox[{"Which", "[", 
         RowBox[{
          RowBox[{"StringContainsQ", "[", 
           RowBox[{"baseName", ",", "\"\<originali\>\"", ",", 
            RowBox[{"IgnoreCase", "->", "True"}]}], "]"}], ",", "\"\<uno\>\"",
           ",", 
          RowBox[{"StringContainsQ", "[", 
           RowBox[{"baseName", ",", "\"\<groundtruth\>\"", ",", 
            RowBox[{"IgnoreCase", "->", "True"}]}], "]"}], 
          ",", "\"\<unogt\>\"", ",", "True", ",", 
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
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Prefisso per i nomi dei file di output determinato: \
'\>\"", ",", "fileNamePrefix", ",", "\"\<'\>\""}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "6."}]}], " ", "Importa", " ", "le", " ", "immagini", 
          " ", "dal", " ", "file", " ", 
          RowBox[{"DICOM", "--"}]}], "-"}], "*)"}], 
       RowBox[{
       "Print", "[", "\"\<Importazione delle immagini dal file DICOM...\>\"", 
        "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"imageList", "=", 
        RowBox[{"Check", "[", 
         RowBox[{
          RowBox[{"Import", "[", 
           RowBox[{"actualInputFile", ",", "\"\<ImageList\>\""}], "]"}], ",", 
          "$Failed"}], "]"}]}], ";", "\[IndentingNewLine]", 
       RowBox[{"If", "[", 
        RowBox[{
         RowBox[{
          RowBox[{"imageList", "===", "$Failed"}], "||", 
          RowBox[{"!", 
           RowBox[{"ListQ", "[", "imageList", "]"}]}], "||", 
          RowBox[{
           RowBox[{"Length", "[", "imageList", "]"}], "==", "0"}]}], ",", 
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
       RowBox[{"totalImages", "=", 
        RowBox[{"Length", "[", "imageList", "]"}]}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Trovate \>\"", ",", "totalImages", 
         ",", "\"\< immagini/slices totali nel file.\>\""}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "7."}]}], " ", "Definisci", " ", "gli", " ", "indici",
           " ", "da", " ", "esportare", " ", "ed", " ", "esegui", " ", 
          RowBox[{"l", "'"}], "esportazione", " ", 
          RowBox[{"selettiva", "--"}]}], "-"}], "*)"}], 
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
       RowBox[{"Print", "[", 
        RowBox[{"\"\<Esportazione richiesta per gli indici (se presenti nel \
file): \>\"", ",", 
         RowBox[{"Short", "[", "indicesToExport", "]"}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{
       "Print", 
        "[", "\"\<Esportazione delle immagini selezionate in formato \
JPEG...\>\"", "]"}], ";", "\[IndentingNewLine]", 
       RowBox[{"Do", "[", 
        RowBox[{
         RowBox[{"If", "[", 
          RowBox[{
           RowBox[{"1", "<=", "i", "<=", "totalImages"}], ",", 
           RowBox[{
            RowBox[{"img", "=", 
             RowBox[{"imageList", "[", 
              RowBox[{"[", "i", "]"}], "]"}]}], ";", "\[IndentingNewLine]", 
            RowBox[{"outputFileName", "=", 
             RowBox[{"FileNameJoin", "[", 
              RowBox[{"{", 
               RowBox[{"outputDir", ",", 
                RowBox[{"fileNamePrefix", "<>", 
                 RowBox[{"ToString", "[", "i", "]"}], 
                 "<>", "\"\<.jpg\>\""}]}], "}"}], "]"}]}], ";", 
            "\[IndentingNewLine]", 
            RowBox[{"Check", "[", 
             RowBox[{
              RowBox[{
               RowBox[{"Export", "[", 
                RowBox[{"outputFileName", ",", "img", ",", "\"\<JPEG\>\""}], 
                "]"}], ";", 
               RowBox[{"Print", "[", 
                RowBox[{"\"\<Esportato: \>\"", ",", "outputFileName"}], 
                "]"}]}], ",", 
              RowBox[{"Print", "[", 
               RowBox[{"Style", "[", 
                RowBox[{
                 RowBox[{"StringForm", "[", 
                  
                  RowBox[{"\"\<Errore durante l'esportazione dell'immagine \
con indice '``' in '``'\>\"", ",", "i", ",", "outputFileName"}], "]"}], ",", 
                 "Red"}], "]"}], "]"}]}], "]"}], ";"}], ",", 
           RowBox[{
            RowBox[{"Print", "[", 
             RowBox[{"Style", "[", 
              RowBox[{
               RowBox[{"StringForm", "[", 
                
                RowBox[{"\"\<Attenzione: L'indice richiesto '``' non \
\[EGrave] presente nel file DICOM (valido da 1 a '``'). Salto.\>\"", ",", "i",
                  ",", "totalImages"}], "]"}], ",", "Orange"}], "]"}], "]"}], 
            ";"}]}], "]"}], ",", 
         RowBox[{"{", 
          RowBox[{"i", ",", "indicesToExport"}], "}"}]}], "]"}], ";", 
       "\[IndentingNewLine]", 
       RowBox[{"(*", 
        RowBox[{
         RowBox[{
          RowBox[{"--", 
           RowBox[{"-", "8."}]}], " ", "Messaggi", " ", 
          RowBox[{"Finali", "--"}]}], "-"}], "*)"}], 
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
   "\[IndentingNewLine]", "\n"}]}]], "Input",
 CellChangeTimes->{
  3.955018267359686*^9, 3.9550187430966816`*^9, {3.955019430014202*^9, 
   3.9550194370813084`*^9}, 3.9550197296207657`*^9},
 CellLabel->"In[27]:=",ExpressionUUID->"c7b44f8d-3a7b-1c4b-a183-039ba3507278"],

Cell[BoxData[{
 RowBox[{
  RowBox[{
   RowBox[{"listaFileDICOM", "=", 
    RowBox[{"{", 
     RowBox[{"\"\<originali02.dcm\>\"", ",", "\"\<groundtruth02.dcm\>\"", 
      ",", "\"\<originali03.dcm\>\"", ",", "\"\<groundtruth03.dcm\>\""}], " ", 
     RowBox[{"(*", 
      RowBox[{
      "Aggiungi", " ", "qui", " ", "tutti", " ", "i", " ", "file", " ", "che",
        " ", "vuoi", " ", "processare"}], "*)"}], "\[IndentingNewLine]", 
     RowBox[{"(*", 
      RowBox[{"Esempio", " ", "con", " ", "percorso", " ", 
       RowBox[{"relativo", ":", "\"\<sottocartella/originali10.dcm\>\""}]}], 
      "*)"}], "\[IndentingNewLine]", 
     RowBox[{"(*", 
      RowBox[{"Esempio", " ", "con", " ", "percorso", " ", 
       RowBox[{
       "assoluto", 
        ":", "\"\<C:\\\\Utenti\\\\TuoNome\\\\DICOM\\\\serieX.dcm\>\""}]}], 
      "*)"}], "}"}]}], ";"}], "\[IndentingNewLine]"}], "\n", 
 RowBox[{
  RowBox[{"Print", "[", 
   RowBox[{"Style", "[", 
    RowBox[{"\"\<--- INIZIO ELABORAZIONE BATCH ---\>\"", ",", "Bold"}], "]"}],
    "]"}], ";"}], "\n", 
 RowBox[{
  RowBox[{"Print", "[", 
   RowBox[{"\"\<Numero totale di file da processare: \>\"", ",", 
    RowBox[{"Length", "[", "listaFileDICOM", "]"}]}], "]"}], ";"}], "\n", 
 RowBox[{
  RowBox[{
   RowBox[{
   "Print", "[", "\"\<-----------------------------------------------------\>\
\"", "]"}], ";"}], "\n", "\[IndentingNewLine]", 
  RowBox[{"(*", 
   RowBox[{
   "2.", " ", "Itera", " ", "sulla", " ", "lista", " ", "e", " ", "chiama", " ",
     "la", " ", "funzione", " ", "per", " ", "ogni", " ", "file"}], 
   "*)"}]}], "\[IndentingNewLine]", 
 RowBox[{
  RowBox[{
   RowBox[{"Do", "[", 
    RowBox[{
     RowBox[{
      RowBox[{"nomeFileCorrente", "=", 
       RowBox[{"listaFileDICOM", "[", 
        RowBox[{"[", "k", "]"}], "]"}]}], ";", "\[IndentingNewLine]", 
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
       "Chiama", " ", "la", " ", "funzione", " ", "per", " ", "il", " ", 
        "file", " ", "corrente"}], "*)"}], 
      RowBox[{"(*", 
       RowBox[{
       "Usiamo", " ", "Check", " ", "per", " ", "catturare", " ", "eventuali",
         " ", "$Failed", " ", "restituiti", " ", "dalla", " ", "funzione"}], 
       "*)"}], 
      RowBox[{"Check", "[", 
       RowBox[{
        RowBox[{"ConvertDICOMToJPEGs", "[", "nomeFileCorrente", "]"}], ",", 
        RowBox[{"Print", "[", 
         RowBox[{"Style", "[", 
          RowBox[{
           RowBox[{"StringForm", "[", 
            
            RowBox[{"\"\<Elaborazione fallita per il file: ``. Passo al \
successivo.\>\"", ",", "nomeFileCorrente"}], "]"}], ",", "Red"}], "]"}], 
         "]"}]}], "]"}], ";", "\[IndentingNewLine]", 
      RowBox[{
      "Print", "[", \
"\"\<-----------------------------------------------------\>\"", "]"}], ";", 
      "\[IndentingNewLine]", 
      RowBox[{"Pause", "[", "0.5", "]"}], ";"}], " ", 
     RowBox[{"(*", 
      RowBox[{"Opzionale", ":", 
       RowBox[{
       "piccola", " ", "pausa", " ", "per", " ", "leggibilit\[AGrave]", " ", 
        RowBox[{"dell", "'"}], "output"}]}], "*)"}], ",", 
     RowBox[{"{", 
      RowBox[{"k", ",", 
       RowBox[{"Length", "[", "listaFileDICOM", "]"}]}], "}"}]}], " ", 
    RowBox[{"(*", 
     RowBox[{
     "Itera", " ", "da", " ", "1", " ", "alla", " ", "lunghezza", " ", 
      "della", " ", "lista"}], "*)"}], "]"}], ";"}], 
  "\[IndentingNewLine]"}], "\n", 
 RowBox[{
  RowBox[{"Print", "[", 
   RowBox[{"Style", "[", 
    RowBox[{"\"\<--- ELABORAZIONE BATCH COMPLETATA ---\>\"", ",", "Bold"}], 
    "]"}], "]"}], ";"}]}], "Input",
 CellChangeTimes->{
  3.9550194425167084`*^9, {3.9550197466569405`*^9, 3.9550197930963554`*^9}},
 CellLabel->"",ExpressionUUID->"7805467c-d824-e84d-a171-081de65475c1"]
},
WindowSize->{700.5, 717},
WindowMargins->{{Automatic, 6.75}, {6.75, Automatic}},
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
Cell[554, 20, 18321, 432, 1453, "Input",ExpressionUUID->"c7b44f8d-3a7b-1c4b-a183-039ba3507278"],
Cell[18878, 454, 4057, 101, 357, "Input",ExpressionUUID->"7805467c-d824-e84d-a171-081de65475c1"]
}
]
*)


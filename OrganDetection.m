(* ::Package:: *)

 


(*:Title: OrganDetection *)
(*:Context: OrganDetection` *)
(*:Authors: Giuseppe Spathis, Federico Augelli, ... *)
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

(* Definition of public functions *)
MaskToXML::usage = "pippo"
XMLToMask::usage = "pippo"
(*
Normalize::usage = "Normalize[f, {x0, x1, ...}]
	test function for normalizing functions"

FineTune::usage = "FineTune[f, g, h]
	function for fine tuning the model"
*)
Begin["Private`"]

(* Implementation of all function *)
(*
Normalize[] :=
Module[],

code...
*)


(*
FineTune[] :=
Module[],

code...
*)


(* Defnition of auxiliary functions *)
(*
AuxFunction[] := 
Module[]
*)

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


End[]
EndPackage[]

/*-/-/-/-/-/   SCRIPT:   detach faces to fronts and draw it to shapes v1.   -/-/-/-/-/*/
/*-/-/-/-/-/   CREATED BY:   Al Raz "Rapida"   -/-/-/-/-/*/
/*-/-/-/-/-/   EMAIL:   rapidograph.il@gmail.com   -/-/-/-/-/*/
fileName = getThisScriptFilename ()
global scriptPath = getFilenamePath fileName
global draw3dINIFile = (scriptPath + "draw3d.ini")
createFront = scriptPath + (getINISetting draw3dINIFile "Files" "CreateFront")
drawEditpoly = scriptPath + (getINISetting draw3dINIFile "Files" "DrawEP")
FrontFace = scriptPath + (getINISetting draw3dINIFile "Files" "FrontFace")
revXray = scriptPath + (getINISetting draw3dINIFile "Files" "revXray")
globals = scriptPath + (getINISetting draw3dINIFile "Files" "globals")
filein globals --import file for create testing faces from bBox
-- filein FrontFace --import file for create testing faces from bBox
filein revXray --import file for find nGons back rays to find visibility
fileIn drawEditpoly -- import file for draw Function
filein createFront --import file for create Fronts
-- theObj = convertTo (copy $) Editable_Poly
-- 	createFront theObj -- create fronts
-- 	for d = 1 to frArr.count do ( drawEP frArr[d] camArr[d] ) --crete front Draw
-- 	delete camArr
-- 	delete frArr
-- 	delete theObj

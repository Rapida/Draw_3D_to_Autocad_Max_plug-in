global frArr = #() -- frane Array 
global camArr = #() -- Cameras Array
fn draw3dGetColor theKey default:gray =
(
	theColor = try(getINISetting draw3dINIFile "Preferences" theKey)catch("")
	if theColor != "" then
	(
		arr = filterString theColor " "
		if arr.count == 1 then (execute arr[1]) else(color (arr[1] as float) (arr[2] as float) (arr[3] as float))
	) else (default)
)
global drawColor = draw3dGetColor "Fronts Color" -- color for lines in drawing
global vertTextColor = draw3dGetColor "Vertex Text Color" -- color for text in drawings
global polyTextColor = draw3dGetColor "Polygon Text Color" -- color for text in drawings
global nG = (getINISetting draw3dINIFile "Preferences" "nGon") as integer
global nGr = (getINISetting draw3dINIFile "Preferences" "nGon radius") as integer
global bBoxOffset = (getINISetting draw3dINIFile "Preferences" "bBox offset") as integer
global v_T_size = (getINISetting draw3dINIFile "Preferences" "Vertex Text Size") as integer
global p_T_size = (getINISetting draw3dINIFile "Preferences" "Polygons Text Size") as integer
global vertLayerName = (getINISetting draw3dINIFile "Preferences" "Vertex Text Layer")
global polyLayerName = (getINISetting draw3dINIFile "Preferences" "Polygons Text Layer")
global drawLayerName = (getINISetting draw3dINIFile "Preferences" "Fronts Layer")
if LayerManager.getLayerFromName vertLayerName == undefined do LayerManager.newLayerFromName vertLayerName
if LayerManager.getLayerFromName polyLayerName == undefined do LayerManager.newLayerFromName polyLayerName
if LayerManager.getLayerFromName drawLayerName == undefined do LayerManager.newLayerFromName drawLayerName
global drawLayer = LayerManager.getLayerFromName drawLayerName
global vertLayer = LayerManager.getLayerFromName vertLayerName
global polyLayer = LayerManager.getLayerFromName polyLayerName
drawLayer.wireColor = drawColor
vertLayer.wireColor = vertTextColor
polyLayer.wireColor = polyTextColor
global theName = $.name


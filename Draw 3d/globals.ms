global bordersLayerName = (getINISetting IniFile "Preferences" "Border Layer")
global frontsLayerName = (getINISetting IniFile "Preferences" "Fronts Layer")
if LayerManager.getLayerFromName bordersLayerName == undefined then (
	LayerManager.newLayerFromName bordersLayerName
	global bordersLayer = LayerManager.getLayerFromName bordersLayerName
	bordersLayer.wireColor = (getPref "Border Color")
) else (
	global bordersLayer = LayerManager.getLayerFromName bordersLayerName
	setPref "Border Color" bordersLayer.wireColor
)
if LayerManager.getLayerFromName frontsLayerName == undefined then (
	LayerManager.newLayerFromName frontsLayerName
	global frontsLayer = LayerManager.getLayerFromName frontsLayerName
	frontsLayer.wireColor = (getPref "Fronts Color")
) else (
	global frontsLayer = LayerManager.getLayerFromName frontsLayerName
	setPref "Fronts Color" frontsLayer.wireColor 
)



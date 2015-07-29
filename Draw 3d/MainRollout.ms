/* Master Rollut of Draw 3d script */
try(
	destroyDialog Draw_3D_Main
	callbackItem = undefined
	gc light:true
	)catch()
fileName = getThisScriptFilename ()
thePath = getFilenamePath fileName
IniFile = thePath + "draw3d.ini"
	fn getPref data =(execute (getINISetting IniFile "Preferences" data))
	fn setPref dataOut val prOut:"Preferences" = (setINISetting IniFile prOut dataOut (val as String))
		filein (thePath + "drawEP_Obj_Cam.ms") --Draw the fronts
		filein (thePath + "globals.ms")
		filein (thePath + "Draw_Polygons.ms") -- Flatten the mesh function
	fn enableButtons sub st:true= 
	(
		for d in sub.controls do d.enabled = st
	)
fn frontFace theObj offset:5 fronts:#{}=
	(
		l = (theObj.max.y - theObj.min.y) + offset
		w = (theObj.max.x - theObj.min.x) + offset
		h = (theObj.max.z - theObj.min.z) + offset
		bBox = [theObj.center.x, theObj.center.y, (theObj.min.z-offset/2)]
		b = Box pos:bBox  length:l width:w height:h
		addModifier b (Normalmodifier flip:true)
		pp = convertTo b Editable_Poly
		fc = polyop.getNumFaces pp
		CenterPivot pp
		locArr = #()
		if fronts != #{} do
		(
			for f in fronts do 
			(
				N = "Face_" + (f as string)
				polyop.detachFaces pp f delete:false name:N asNode:true
				sh = getNodeByName N exact:true
				wc = #(red,blue,green,black,gray,yellow)
				sh.wirecolor = wc[f]
				append locArr sh
			)
		)
		delete pp
		fArr = locArr
	)
fn getMatrix = 
(
	for f in fArr collect
	(
		faceNormal = in coordsys f (polyop.getFaceNormal f 1)
		faceCenter = polyop.getFaceCenter f 1
		worldUpVector = [0,0,1]
		rightVector = normalize (cross worldUpVector faceNormal)
		upVector = normalize ( cross rightVector faceNormal )
		theMatrix =matrix3 rightVector upVector faceNormal faceCenter
		print theMatrix
		theMatrix
	)
)
rollout frontsSubRollout "Fronts Parameters" 
	(
		label grpFlbl "Check the boxes you want to draw" align:#center pos:[8,5] width:180 height:16
		checkbox frontChk "Front" pos:[16,24] width:50 height:18 tooltip:"Front"
		checkbox BackChk "Back" pos:[16,40] width:50 height:18 tooltip:"Back"
		checkbox RightChk "Right" pos:[16,56] width:50 height:18 tooltip:"Right"
		checkbox LeftChk "Left" pos:[16,72] width:50 height:18 tooltip:"Left"
		checkbox TopChk "Top" pos:[16,88] width:50 height:18 tooltip:"Top"
		checkbox BottomChk "Bottom" pos:[16,104] width:55 height:18 tooltip:"Bottom"
		checkbutton FrontsPreviewBtn "Preview" pos:[104,32] width:80 height:80 tooltip:"Preview the Fronts Planes"
		on frontsSubRollout open do ( if $ == undefined or selection.count > 1 do enableButtons frontsSubRollout st:false; fArr = #())
		on frontChk changed state do ( if state == false do ( FrontsPreviewBtn.checked = off; if fArr != undefined and fArr != #() do delete fArr ) )
		on FrontsPreviewBtn changed theState do
			(if theState == true then
				( theObj = $
					checkBoxArr = #{}
					for i in frontsSubRollout.controls where classOF i == CheckBoxControl and i.checked == on do
						( n = (getINISetting IniFile "Fronts" i.text) as integer
							appendIfunique checkBoxArr n )
					global fArr = frontFace theObj offset:((getINISetting IniFile "Preferences" "bBox offset") as integer) fronts:checkBoxArr )
				else
				( if fArr != undefined and fArr != #() do delete fArr
					fArr = undefined ) )
			on frontsSubRollout close do 
				(
					if fArr == undefined do continue;
					if fArr != undefined or fArr != #() do delete fArr 
				)
	)
rollout drawingsSettings "Drawing Settings" width:220 height:211
(
	fn setPref dataOut val prOut:"Preferences" = (setINISetting IniFile prOut dataOut (val as String))
	colorPicker boCp "Border Color:         " offset:[-10,0] width:185 height:16 color:(getPref "Border Color") fieldWidth:20 title:"Choose a color for drawing lines"
	colorPicker edCp "Edges Color:         " offset:[-10,0] width:185 height:16 color:(getPref "Fronts Color") fieldWidth:20 title:"Choose a color for drawing lines"
	colorPicker poCp "Polygon # Color:      " offset:[-10,0] width:185 height:16 color:(getPref "Polygon Text Color") fieldWidth:20 title:"Choose a color for Polygons Names"
	colorPicker veCp "Vertices # Color:      " offset:[-10,0] width:185 height:16 color:(getPref "Vertex Text Color") fieldWidth:20 title:"Choose a color for Vertices Numbers"
	editText boTx "Borders Layer" text:(getINISetting IniFile "Preferences" "Border Layer") width:185 height:16 offset:[5,0] align:#right
	editText erTx "Edges Layer" text:(getINISetting IniFile "Preferences" "Fronts Layer") width:185 height:16 offset:[5,0] align:#right
	editText vrTx "Vertices # Layer" text:(getINISetting IniFile "Preferences" "Vertex Text Layer") offset:[5,0] width:185 height:16 align:#right
	editText poTx "Polygons # Layer" text:(getINISetting IniFile "Preferences" "Polygons Text Layer") offset:[5,0] width:185 height:16 align:#right
	checkbox verChk "" align:#left width:20 height:20 across:2
	spinner vSize "Vertices # Size:   " range:[1,100,(getPref "Vertex Text Size")] offset:[-10,0] fieldWidth:30 type:#integer scale:1 align:#right 
	checkbox polyChk "" align:#left width:20 height:20 across:2
	spinner pSize "Poligons # Size:   " range:[1,100,(getPref "Polygons Text Size")] offset:[-10,0] fieldWidth:30 type:#integer scale:1 align:#right 
	spinner bSize "Drawing Offset:   " range:[1,100,(getPref "bBox Offset")] offset:[-10,0] fieldWidth:30 type:#integer scale:1 align:#right
	label CreateLbl "Change Properties" align:#left offset:[0,10]
	button SettingsBtn "Apply" width:50 height:20 align:#right offset:[0,-20]
	on drawingsSettings open do (
			vrTx.enabled = verChk.checked
			poTx.enabled = verChk.checked
			if verChk.checked == false then vSize.enabled = false else vSize.enabled = true
			if polyChk.checked == false then pSize.enabled = false else pSize.enabled = true
		)
	on boCp changed col do (setPref "Border Color" boCp.color)
	on edCp changed col do (setPref "Fronts Color" edCp.color)
	on poCp changed col do (setPref "Polygon Text Color" poCp.color)
	on veCp changed col do (setPref "Vertex Text Color" veCp.color)
	on boTx entered boText do (setPref "Border Layer" boText)
	on erTx entered erText do (setPref "Fronts Layer" erText)
	on vrTx entered vrText do (setPref "Vertex Text Layer" vrText)
	on poTx entered poText do (setPref "Polygons Text Layer" poText)
	on vSize entered do ( setPref "Vertex Text Size" vSize.value)
	on pSize entered do ( setPref "Polygons Text Size" pSize.value)
	on bSize entered do ( setPref "bBox Offset" bSize.value)
	on verChk changed state do (vSize.enabled = state; vrTx.enabled = state)
	on polyChk changed state do (pSize.enabled = state; poTx.enabled = state)
)
rollout DrawPolysSubrollout "Export Settings" width:162 height:50
(
	group "Draw:"
	(
-- 	on verChk changed state do(print "chk8" + "changed")
	)
)
rollout Draw_3D_Main "Draw 3D Main" width:220 height:550
(
	fn updateWarning = (
		if $ == undefined or selection.count > 1 then (
			Draw_3D_Main.Warlbl.text = "Warning: " + "You need to select one object"
		) else (
			Draw_3D_Main.Warlbl.text = ""
		)
	)
	fn callBack ev nd = 
	(
		updateWarning()
		if ev == #selectionChanged and selection.count == 1 and isKindOf $ GeometryClass do  print nd
		enableButtons Draw_3D_Main.theFrontsSubrollout.frontsSubRollout st:(if $ == undefined or selection.count > 1 then false else true)
	)
	subRollout theFrontsSubrollout "" pos:[5,5] width:210 height:400
	subRollout drawingsSettings "" pos:[5,5] width:194 height:14
	radiobuttons unitsToDraw "Output Units Format" pos:[110,420] labels:#("Metric", "US") tooltip:#("Metric for 0.0cm", "US for 0'0\"" )
	button CreateBtn "Fronts" pos:[5,470] width:100 height:32 align:#right tooltip:"Draw choosen fronts for selectes object"
	button flatenBtn "Flatten" pos:[110,470] width:100 height:32 align:#right tooltip:"Flat the object"
	label Warlbl "Warning:" align:#center pos:[10,525] width:200 height:16
	on Draw_3D_Main open do (
		updateWarning ()
		(callbackItem = NodeEventCallback mouseUp:true delay:100 all:callBack)
	)
	on CreateBtn pressed do ( 					--MAIN FUNCTION
		theObj = convertTo (copy $) Editable_Poly
-- 		theObj = $
		checkBoxArr = #{}
			for i in Draw_3D_Main.theFrontsSubrollout.frontsSubRollout.controls where classOF i == CheckBoxControl and i.checked == on do
			( 
				n = (getINISetting IniFile "Fronts" i.text) as integer
				appendIfunique checkBoxArr n 
			)
		global fArr = frontFace theObj offset:((getINISetting IniFile "Preferences" "bBox offset") as integer) fronts:checkBoxArr 
		matrixArr = getMatrix()
		vState = Draw_3D_Main.theFrontsSubrollout.drawingsSettings.verChk.state
		pState = Draw_3D_Main.theFrontsSubrollout.drawingsSettings.polyChk.state
		for fr = 1 to fArr.count do drawEP theObj matrixArr[fr] ver:vState poly:pState oName:$.name
		delete theobj
		delete fArr
		fArr = #()
	)
	on flatenBtn pressed do
	(
		unitsFn = case unitsToDraw.state of (
			1:#centimeters
			2:#ft_Frac_In
		)
		if unitsFn == #centimeters do (units.DisplayType = #metric; units.MetricType = unitsFn)
		if unitsFn == #ft_Frac_In do (units.DisplayType = #us; units.USType = unitsFn; units.USFrac = #Frac_1_2)
		print (unitsFn as string)
		flattenTheMesh $
	)
	on Draw_3D_Main close do 
		(
		callbackItem = undefined
		gc light:true
		)
)
CreateDialog Draw_3D_Main
AddSubRollout Draw_3D_Main.theFrontsSubrollout frontsSubRollout rolledUp:off
AddSubRollout Draw_3D_Main.theFrontsSubrollout drawingsSettings rolledUp:on
AddSubRollout Draw_3D_Main.theFrontsSubrollout DrawPolysSubrollout rolledUp:off
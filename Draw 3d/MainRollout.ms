/* Master Rollut of Draw 3d script */
try(destroyDialog Draw_3D_Main)catch()
rollout frontsSubRollout "Fronts Parameters" 
	(
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
				if f == 1 do (sh.wirecolor = wc[1])
				if f == 2 do (sh.wirecolor = wc[2])
				if f == 3 do (sh.wirecolor = wc[3])
				if f == 4 do (sh.wirecolor = wc[4])
				if f == 5 do (sh.wirecolor = wc[5])
				if f == 6 do (sh.wirecolor = wc[6])
				append locArr sh
			)
		)
		delete pp
		fArr = locArr
	)
		label grpFlbl "Check the fronts you want to create" pos:[8,5] width:180 height:16
		label FrontLbl "Front:" pos:[16,24] width:50 height:16
		checkbox frontChk "" pos:[72,24] width:18 height:18 tooltip:"3"
		label BackLbl "Back:" pos:[16,40] width:50 height:16
		checkbox BackChk "" pos:[72,40] width:18 height:18 tooltip:"5"
		label RightLbl "Right:" pos:[16,56] width:50 height:16
		checkbox RightChk "" pos:[72,56] width:18 height:18 tooltip:"4"
		label Leftlbl "Left:" pos:[16,72] width:50 height:16
		checkbox LeftChk "" pos:[72,72] width:18 height:18 tooltip:"6"
		label TopLbl "Top:" pos:[16,88] width:50 height:16
		checkbox TopChk "" pos:[72,88] width:18 height:18 tooltip:"2"
		label BottomLbl "Bottom:" pos:[16,104] width:50 height:16
		checkbox BottomChk "" pos:[72,104] width:18 height:18 tooltip:"1"
		checkbutton FrontsPreviewBtn "Preview\n Fronts\n Planes " pos:[104,32] width:80 height:80
		on frontsSubRollout open do fArr = #()
			on FrontsPreviewBtn changed theState do
			(
				if theState == true then
				(
				theObj = $
					checkBoxArr = #{}
					for i in frontsSubRollout.controls where \
					classOF i == CheckBoxControl \
					and i.checked == on do
						(
							appendIfunique checkBoxArr (i.tooltip as integer)
						)
				global fArr = frontFace theObj fronts:checkBoxArr
				)
				else
				(
				print "check box unchecked"
					if fArr != undefined and fArr != #() do delete fArr
					fArr = undefined
				)
			)
			on frontsSubRollout close do 
				(
					if fArr != undefined and fArr != #() do delete fArr
				)
	)
rollout dataSettings "Data Output settings"
(
	label CreateLbl "Create Fronts Drawings:" pos:[10,10] width:120 height:16
	button SettingsBtn "Settings" pos:[136,5] width:55 height:30
)
rollout Draw_3D_Main "Draw 3D Main" width:220 height:500
(
	SubRollout theFrontsSubrollout pos:[5,5] width:210 height:400
	SubRollout dataSettings pos:[5,5]
	button CreateBtn "Create" pos:[0,405] width:80 height:32
)
CreateDialog Draw_3D_Main
AddSubRollout Draw_3D_Main.theFrontsSubrollout frontsSubRollout rolledUp:off
AddSubRollout Draw_3D_Main.theFrontsSubrollout dataSettings rolledUp:on
rollout unnamedRollout "Untitled" width:162 height:50
(
	group "Group"
	(
	checkbox chk8 ""align:#right width:20 height:20 across:3 
	checkbox chk9 ""align:#right width:20 height:20 
	checkbox chk10 ""align:#right width:20 height:20 
	on chk8 changed state do(print "chk8" + "changed")
	)
)
-- createDialog unnamedRollout
fn drawEP Obj Cam = 
(
	faceArr = #{}
	(
		polyop.unhideAllFaces Obj
		theFaceCount = polyop.getNumFaces Obj --get the number of faces in the object
		selArray = #() --init. an array to collect faces
		for f = 1 to theFaceCount do --loop through all faces
		(
			in coordsys Cam.transform
			theFN = polyop.getFaceNormal Obj f
			if theFN.z < 0.1 then append selArray f -- if Z is negative, add to array
			append faceArr f -- if Z is negative, add to array
		)
		polyop.setHiddenFaces Obj selArray --set the face selection in the EMesh
		hidFaceArr = polyop.getHiddenFaces Obj
		vizFaceArr = faceArr - hidFaceArr
		vE = polyop.getEdgesUsingFace Obj vizFaceArr
		newShape = splineShape()
		newShape.name = "Front_Draw_" + Obj.name
		oTr = newShape.transform
		if isValidNode newShape do
		(
			local viewTM = Cam.transform
			local nuTransform = viewTM
			newShape.transform = nuTransform
		)
			nName = "Shape_001"
			polyop.createShape Obj vE smooth:false name:nName --create shape from selected edges
			sh = getNodeByName nName exact:true
			addAndWeld newShape sh 0.0
			newShape.transform = oTr
			fn flatShape oSh =
			(
			  new_z = oSh.pos.z
			  for s = 1 to (numSplines oSh) do
			  (
				for k = 1 to (numKnots oSh s) do
				(
				  knt = getKnotPoint oSh s k
				  in_vec = getInVec oSh s k
				  out_vec = getOutVec oSh s k
				  knt.z = in_vec.z = out_vec.z = new_z
				  setInVec oSh s k in_vec
				  setOutVec oSh s k out_vec
				  setKnotPoint oSh s k knt
				)--end k loop
			  )--end s loop
			  updateshape oSh --flat new shape
			)
	flatShape newShape
	if isValidNode newShape do
	(
		local viewTM = Cam.transform
		local nuTransform = viewTM
		newShape.transform = nuTransform
	)
		Obj.children.parent = newShape
		drawLayer.addnode newShape
		coordsys parent newShape.children.pos.z = 0
	fn addMod theObj =
	(
		textSizeMod = EmptyModifier()
		textSizeMod.name = "Text Size"
		addmodifier theObj textSizeMod
		TextSizeCA = attributes TextAttribute
		(
			parameters PRM_Size rollout:RLT_Size 
				(
					vertexSize type:#integer ui:SPN_Text default:v_T_size
					polygonSize type:#integer ui:SPN_Poly default:p_T_size
				)
			rollout RLT_Size "Text size"
				(
					spinner SPN_Text "Vertex Size:" type: #integer
					spinner SPN_Poly "Polygon Size:" type: #integer
				)
		)
		custattributes.add theObj.modifiers["Text size"] TextSizeCA BaseObject:false
	)
		addMod newShape
		for n in newShape.children do 
			(
				if n.layer.name == vertLayerName do paramWire.connect newShape.modifiers[#Text_Size].TextAttribute[#vertexSize] n.baseObject[#Size] "vertexSize"
				if n.layer.name == polyLayerName do paramWire.connect newShape.modifiers[#Text_Size].TextAttribute[#polygonSize] n.baseObject[#Size] "polygonSize"
			)
		newShape.colorBylayer = true
		newShape.children.colorByLayer = true
	)
)
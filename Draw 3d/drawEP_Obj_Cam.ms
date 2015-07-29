fn drawEP Obj Cam ver:false poly:false oName:undefined = 
(
	faceArr = #{}
	(
		polyop.unhideAllFaces Obj
		theFaceCount = polyop.getNumFaces Obj --get the number of faces in the object
		selArray = #() --init. an array to collect faces
		for f = 1 to theFaceCount do --loop through all faces
		(
			in coordsys Cam
			(
			theFN = polyop.getFaceNormal Obj f
			if theFN.z < 0.01 then append selArray f -- if Z is negative, add to array
			append faceArr f -- if Z is negative, add to array
			)
		)
		polyop.setHiddenFaces Obj selArray --set the face selection in the EMesh
		hidFaceArr = polyop.getHiddenFaces Obj
		polyop.setFaceMatID Obj selArray 2 -- set matId 2 to hidden faces
		vizFaceArr = faceArr - hidFaceArr
		polyop.setFaceMatID Obj vizFaceArr 1 -- set matId 1 to all faces
		vE = polyop.getEdgesUsingFace Obj vizFaceArr
		frontShape = splineShape name:(uniqueName ("Front_Draw_" + Obj.name + "_")) colorByLayer:true
		borderShape = splineShape name:(uniqueName ("Border_Draw_" + Obj.name + "_")) colorByLayer:true
		oTr = frontShape.transform
-- 			print ("oTr = " + (oTr as string))
		if isValidNode frontShape do frontShape.transform = Cam
		if isValidNode borderShape do borderShape.transform = Cam
			fName = "frontShape_001"
			bName = "borderShape_001"
			borderEdgesArr = #{}
			eCount = polyop.getNumEdges Obj
			for ed = 1 to eCount do ( --loop through all edges
			theFaces = (polyOp.getFacesUsingEdge Obj #(ed)) as array   --get the faces sharing the current edge
			 if theFaces.count == 2 then	 --if there are two faces sharing the edge,
			 (
				if polyOp.getFaceMatID Obj theFaces[1] != polyOp.getFaceMatID Obj theFaces[2] do --compare their Material IDs. If different, collect the edge
				append borderEdgesArr ed
			 ) else (if theFaces.count == 1 and polyOp.getFaceMatID Obj theFaces[1] == 1 do append borderEdgesArr ed)
		)
			fE = vE - borderEdgesArr
			polyop.createShape Obj borderEdgesArr smooth:false name:bName --create shape from border edges
			polyop.createShape Obj fE smooth:false name:fName --create shape from nonborder edges
			frSh = getNodeByName fName exact:true
			brSh = getNodeByName bName exact:true
			addAndWeld frontShape frSh 0.0
			addAndWeld borderShape brSh 0.0
			frontShape.transform = oTr
			borderShape.transform = oTr
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
	flatShape frontShape
	flatShape borderShape
		if isValidNode frontShape do (frontShape.transform = Cam; frontsLayer.addnode frontShape)
		if isValidNode borderShape do (borderShape.transform = Cam; bordersLayer.addnode borderShape)
		frontShape.parent = borderShape
			if ver == true do
			(
				global vertexLayerName = (getINISetting IniFile "Preferences" "Vertex Text Layer") 
					if LayerManager.getLayerFromName vertexLayerName == undefined then (
						LayerManager.newLayerFromName vertexLayerName
						global vertexLayer = LayerManager.getLayerFromName vertexLayerName
						vertexLayer.wireColor = (getPref "Vertex Text Color")
					) else (
						global vertexLayer = LayerManager.getLayerFromName vertexLayerName
						vertexLayer.wireColor = (getPref "Vertex Text Color")
					)
				vTSize = getPref "Vertex Text Size"
				vV = polyOp.getVertsUsingFace Obj vizFaceArr
				local vTM = cam
				for i in vV do
				(
					vertN = uniqueName (oName + "_" + (i as string))
						local vPos = polyop.getVert Obj i
						vTM.row4 = vPos
						t = text pos:vPos size:vTSize name:vertN text:(i as string) colorByLayer:true
						t.transform = vTM; t.parent = frontShape;
						vertexLayer.addnode t
						rotate t (eulerangles 0 180 0)
				)
			)
			if poly == true do 
			(
				global polygonsLayerName = (getINISetting IniFile "Preferences" "Polygons Text Layer") 
					if LayerManager.getLayerFromName polygonsLayerName == undefined then (
						LayerManager.newLayerFromName polygonsLayerName
						global polygonsLayer = LayerManager.getLayerFromName polygonsLayerName
						polygonsLayer.wireColor = (getPref "Polygon Text Color")
					) else (
						global polygonsLayer = LayerManager.getLayerFromName polygonsLayerName
						polygonsLayer.wireColor = (getPref "Polygon Text Color")
					)
					pTSize = getPref "Polygons Text Size"
					vP = vizFaceArr
					local vTM = cam
					for i in vP do
					(
						polyN = uniqueName (oName + "_" + (i as string))
							local pPos = polyOp.getFaceCenter Obj i
							vTM.row4 = pPos
							t = text pos:pPos size:pTSize name:polyN text:(oName + "_" + (i as string)) colorByLayer:true
							t.transform = vTM; t.parent = frontShape;
							polygonsLayer.addnode t
							rotate t (eulerangles 0 180 0)
					)
				print "Now i can print the polygons No to text"
			)
		coordsys parent frontShape.children.pos.z = 0
	)
)
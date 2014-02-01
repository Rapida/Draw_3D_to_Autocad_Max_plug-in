fn createFront theObj = 
(
	fArr = frontFace theObj offset:bBoxOffset
	newObj = convertToMesh (copy theObj)
	print (fArr as string)
	for m in fArr do
	(
		convertTo m Editable_mesh
		AllFaces = #{}
		FaceToDel = #{}
		VizFaces = #{}
		vArr = #{}
		vNoDel = #{}
		vToDel = #{}
		newEP = copy newObj name:("newEP_" + m.name)
		print newEP
		for i = 1 to (getNumFaces newEP) do (append AllFaces i)
		for fe = 1 to newObj.numverts do
		(
			append vArr fe -- add vertex to Array
			fCenter = getVert newObj fe -- get vertex position
			local mN = (getFaceNormal m 1) -- get normal from bbox face
			local vertRay = ray fCenter (mN * [-1,-1,-1]) -- deffine vertex ray
			n1 = (intersectRayEx m vertRay)
			if n1 != undefined do -- if vertex ray exist do other rays to check for visibility of face 
			(
				exitCoord = fCenter
				intCoord = n1[1].pos
				revXray exitCoord intCoord n:nG r:nGr
				for i in FinCheckRay do
				(
					newRay = ray i[1] mN
					n2 = intersectRAyEx newObj newRay
					if n2 != undefined do 
					(
						verts = (meshop.getVertsUsingFace newObj n2[2])as array
						if (findItem verts fe) != 0 do
						(
							append vToDel fe
							appendIfUnique VizFaces n2[2]
						)
					)
				)
			)
		)
		cam = Targetcamera orthoProjection:false pos:(m.center) target:(Targetobject pos:m.pos)
		append camArr cam 
		vNoDel = vArr - vToDel
		for fv in vToDel do 
			(
				vertN = uniquename (theObj.name +"_"+(fv as string))
				local viewTM = cam.transform
				local pos = (polyop.getVert theObj fv)
				local nuTransform = viewTM
				nuTransform.row4 = pos
				t = text pos:pos size:v_T_size name:vertN text:(fv as string) wirecolor:red
				t.transform = nuTransform
				t.parent = newEP
				vertLayer.addnode t
			)
			FaceToDel = AllFaces - VizFaces
		meshop.deleteFaces newEP FaceToDel
		convertTo newEP Editable_Poly
		for f = 1 to (polyop.getNumFaces newEP) do 
			(
				faceN = uniquename (theObj.name +"_Face_"+(f as string))
				local viewTM = cam.transform
				local pos = (polyop.getFaceCenter newEP f)
				local fNo = f
				local nuTransform = viewTM
					for i = 1 to (polyop.getNumFaces theObj) do
					(
						if (polyop.getFaceCenter theObj i) == pos do fNo = i
					)
				nuTransform.row4 = pos
				ft = text pos:pos size:p_T_size name:faceN text:(theName + "_"+(fNo as string)) wirecolor:red
				ft.transform = nuTransform
				ft.parent = newEP
				polyLayer.addnode ft
			)
		append frArr newEP
	)
	for m in fArr do delete m
	delete newObj
)

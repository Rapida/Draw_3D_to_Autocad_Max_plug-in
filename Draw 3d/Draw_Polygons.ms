fn roundFloat str d:2 =
	(
		indStr = findString str "."
		co = str.count;
		st = indStr + d;
		en = co - st;
		if en > 0 do
		(
			st = st+1
		en = co - st + 1;
		)
		fin = replace str st en ""
		fin
	)

fn flattenTheMesh meshIn =
(
	tmesh = meshIn
	start_Name = tmesh.name
	copyM = convertTo (copy tmesh) Editable_Poly
	num_faces = polyop.getNumFaces copyM
	lName = "Text"
	dLName = "Fronts"
	cName = "Coordinates"
	if LayerManager.getLayerFromName lName == undefined do ( TLay = LayerManager.newLayerFromName lName; TLay.wireColor = red ) -- Create layer for vertex text
	if LayerManager.getLayerFromName dLName == undefined do ( FLay = LayerManager.newLayerFromName dLName; FLay.wireColor = blue ) -- Create layer for drawings text
	if LayerManager.getLayerFromName cName == undefined do ( FLay = LayerManager.newLayerFromName cName; FLay.wireColor = yellow ) -- Create layer for drawings text
		drawLayer = LayerManager.getLayerFromName dLName
		textLayer = LayerManager.getLayerFromName lName
		coordLayer = LayerManager.getLayerFromName cName
	newShapeArr = #()
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

	for f = 1 to num_faces do
	(
		newShape = splineShape pos:(polyop.getFaceCenter copyM f) dir:(polyop.getFaceNormal copyM f) colorByLayer:true -- Create clear spline for future edge shape
		newShape.name = start_Name + "_Polygon_" +(f as string) -- Name it
		verts = polyop.getVertsUsingFace copyM f -- Get vertices from the face
			for fv in verts do -- Create text for the vertices
			(
				vertN = uniquename (start_Name +"_"+(fv as string))
				local viewTM = newShape.transform
				local pos = (polyop.getVert copyM fv)
				viewTM.row4 = pos
				t = text transform:viewTM size:5 name:vertN text:(fv as string) colorByLayer:true
				t.transform = viewTM
				t.parent = newShape
				mT = t
					fn writeThePos txt =
					(
						te = ((units.formatValue txt) as string)
						if units.DisplayType == #metric do 
						(
							str = replace te (te.count - 1) 2 ""
							ns = roundFloat str d:1
						)
						ns
					)
				tX = "X = " + writeThePos pos.x
				tY = "Y = " + writeThePos pos.y
				tZ = "Z = " + writeThePos pos.z
				xt =  text transform:viewTM size:5 name:(uniquename "xText-") text:tX colorByLayer:true
				yt =  text transform:viewTM size:5 name:(uniquename "yText-") text:tY colorByLayer:true
				zt =  text transform:viewTM size:5 name:(uniquename "zText-") text:tZ colorByLayer:true
					xt.parent = yt.parent = zt.parent = t
			)
			fn faceNum theObj sShape f theName:"A" =
			(
				faceN = uniquename (theName +"_Face_"+(f as string))
				local viewTM = sShape.transform
				local pos = (polyop.getFaceCenter theObj f)
				viewTM.row4 = pos
				ft = text pos:pos size:10 name:faceN text:(theName + "_"+(f as string)) wirecolor:red
				ft.transform = viewTM
				ft.parent = sShape
			)
		faceNum copyM newShape f theName:start_Name
		vE = polyop.getEdgesUsingFace copyM f -- Story the edges for the face
		nName = "Shape_001"
		polyop.createShape copyM vE smooth:false name:nName --create shape from selected edges
		sh = getNodeByName nName exact:true
		addAndWeld newShape sh 0.0 --Add and weld the edge shape to clear spline
		drawLayer.addnode newShape -- Asign the spline to splines layer
		coordsys parent newShape.children.pos.z = 0 -- Flat the shape childrens
		for n in newShape.children do textLayer.addnode n -- Asign the text to text layer
		newShape.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
		append newShapeArr newShape
	)
	cou = newShapeArr.count
	row = #()
	table = #()
	r = 1
	for i = 1 to cou do
	(
		append row newShapeArr[i]
		r += 1
		if r >= 6 then 
		(
			append table row
			r = 1
			row = #()
		)
		else 
		(
			if i == cou then append table row
		)
	)
	startPo = [0,0,0]
	for i = 1 to table.count do
	(
		c = table[i]
		for n = 1 to c.count do
		(
			nBb = nodeLocalBoundingBox c[n]
			mes = (nBb[2] - nBb[1])
			len = mes.x; wid = mes.y
			if i == 1 and n == 1 then ( startPo = [startPo.x + len, startPo.y + wid, 0.0] )
			else 
			(
				if i == 1 then ( pBb = nodeLocalBoundingBox table[1][n-1]; startPo = [pBb[2].x + len, wid, 0.0] )
				else ( pBb = nodeLocalBoundingBox table[i-1][n]; startPo = [table[i-1][n].pos.x ,pBb[2].y + wid, 0.0] )
			)
			table[i][n].pos = startPo
		)
	)
	xMinArr = for i in newShapeArr collect (nodeLocalBoundingBox i)[1].x
	yMinArr = for i in newShapeArr collect (nodeLocalBoundingBox i)[1].y
	xMaxArr = for i in newShapeArr collect (nodeLocalBoundingBox i)[2].x
	yMaxArr = for i in newShapeArr collect (nodeLocalBoundingBox i)[2].y
	offSet = 50
	rMin = [amin xMinArr, amin yMinArr, 0.0]; rMax = [amax xMaxArr, amax yMaxArr, 0.0]; dim = (rMax - rMin) + offSet; cen = rMax - rMin; 
	rec = Rectangle length:(dim.y) width:dim.x cornerRadius:0 pos:cen isSelected:off colorByLayer:true
	rec.pivot = (nodeLocalBoundingBox rec)[1]
	rec.pos = rMin - [offSet/2,offSet/2,0]
	drawLayer.addnode rec
	for i in newShapeArr do i.parent = rec
	root = rec
	cArr = #()
	for i in rec.children do ( for n in i.children where classOf n == text do append cArr n)
	for c in cArr where c.children.count > 0 do
	(
		mT = c
		xT = c.children[3]; yT = c.children[2]; zT = c.children[1];
		xT.pos = [mT.max.x + 5 + (xT.center.x - xT.min.x), mT.min.y, mt.pos.z]
		yT.pos = [mT.max.x + 5 + (yT.center.x - yT.min.x), xT.min.y - 5, mt.pos.z]
		zT.pos = [mT.max.x + 5 + (zT.center.x - zT.min.x), yT.min.y - 5, mt.pos.z]
		tArr = #( xT, yT, zT)
		xMinArr = for i in tArr collect (nodeLocalBoundingBox i)[1].x
		yMinArr = for i in tArr collect (nodeLocalBoundingBox i)[1].y
		xMaxArr = for i in tArr collect (nodeLocalBoundingBox i)[2].x
		yMaxArr = for i in tArr collect (nodeLocalBoundingBox i)[2].y
		rMin = [amin xMinArr, amin yMinArr, 0.0]; rMax = [amax xMaxArr, amax yMaxArr, 0.0];
		dim = (rMax - rMin) + 5
		cen = rMax - rmin 
		rec = Rectangle length:(abs dim.y) width:(abs dim.x) cornerRadius:0 pos:cen isSelected:off colorByLayer:true
		rec.pivot = (nodeLocalBoundingBox rec)[1]
		rec.pos = rMin - [2.5,2.5,0]
		for i in c.children do coordLayer.addnode i
		coordLayer.addnode rec
		for i in tArr do i.parent = rec
		rec.parent = mT
	)
for i in newShapeArr do 
(
	spl = i
	nK = numKnots spl 1
	tempArr = #()
	flatShape spl
	fn findCenter a b =
	(
		x1 = a.x ; y1 = a.y ; z1 = a.z;
		x2 = b.x ; y2 = b.y ; z2 = b.z;
		x = (x1+x2)/2; y = (y1+y2)/2; z = (z1+z2)/2;
		[x,y,z]
	)
	for i = 1 to nK do 
	(
	a = getKnotPoint spl 1 i
		if i < nK then
		(
			b = getKnotPoint spl 1 (i+1)
			di = distance a b
			str = di as string
			if units.DisplayType == #Metric then
			(
				print str
				ns = roundFloat str d:1
				print ns
			)
			else
			(
				ns = (units.formatValue di) as string
			)
			ns = " - " + ns + " - "
			cen = findCenter a b
				vect = b - a
				rot1 = normalize (cross vect [0,1,0])
				rot2 = normalize (cross vect rot1)
				t = text pos:cen dir:rot2 size:7 font:"EuroRoman" text:ns isSelected:off colorByLayer:true
				coordsys local 
				(
					rotate t (eulerangles -90 0 0); move t [0,5,0];
				)
			t.parent = spl
		coordLayer.addnode t
		)
		else
		(
			b = getKnotPoint spl 1 1
			di = distance a b
			str = di as string
			if units.DisplayType == #Metric then
			(
				ns = roundFloat str d:1
			)
			else
			(
				ns = (units.formatValue di) as string
			)
			ns = " - " + ns + " - "
			cen = findCenter a b
				vect = b - a
				rot1 = normalize (cross vect [0,1,0])
				rot2 = normalize (cross vect rot1)
				t = text pos:cen dir:rot2 size:7 font:"EuroRoman" text:ns isSelected:off colorByLayer:true
				coordsys local 
				(
					rotate t (eulerangles -90 0 0); move t [0,5,0];
				)
			t.parent = spl
		coordLayer.addnode t
		)
)
)
	delete copyM
)
-- flattenTheMesh $'B'
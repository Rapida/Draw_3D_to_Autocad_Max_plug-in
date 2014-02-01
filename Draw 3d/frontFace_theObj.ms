fn frontFace theObj offset:5=
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
	for f = 1 to fc do 
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
		delete pp
		fArr = locArr
)

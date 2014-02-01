fn revXray exitCoord intCoord n:6 r:10 =
(
	fn backXray x y n r =
	(
	global NewRayPos = #()
		for i = 1 to n do
		(
			fi = radToDeg (2*pi*(i-1)/(n-1))
				nX = x + r*cos(fi)
				nY = y + r*sin(fi)
				Pos = [nX,nY]
				append NewRayPos Pos
		)
	)
	global FinCheckRay = #()
	if exitCoord.x != intCoord.x and exitCoord.y == intCoord.y do
	(
		backXray intCoord.z intCoord.y n r
		for i in NewRayPos do
		(
			x = intCoord.x
			y = i.y
			z = i.x
			newPos = #([x,y,z], red)
			append FinCheckRay newPos
		)
	)
	if exitCoord.y != intCoord.y and exitCoord.z == intCoord.z do
	(
		backXray intCoord.z intCoord.x n r
		for i in NewRayPos do
		(
			x = i.y
			y = intCoord.y
			z = i.x
			newPos = #([x,y,z], blue)
			append FinCheckRay newPos
		)
	)
	if exitCoord.z != intCoord.z and exitCoord.x == intCoord.x do
	(
		backXray intCoord.x intCoord.y n r
		for i in NewRayPos do
		(
			x = i.x
			y = i.y
			z = intCoord.z
			newPos = #([x,y,z], green)
			append FinCheckRay newPos
		)
	)
)

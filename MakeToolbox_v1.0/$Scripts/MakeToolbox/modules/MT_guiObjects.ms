/*
#NAME:GUI Objects
#VERSION:1.0
#INSTRUCTIONS:
This script allows the fast and easy creation
of GUI controller objects.
http://www.makevisual.com/learning/MT_guiObjects.htm
#SOURCE:Tyson Ibele, tyson@tysonibele.com
#HISTORY:03.05.2012 >> Integrated to MakeToolbox and added color controls -ad
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Tyson Ibele tysonibele@gmail.com
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 0.03 : 02.29.2012 >> Release -ti
--- version 1.0 : 03.05.2012  >> Integrated to MakeToolbox
---								   and added color controls -ad
--*****************************************************
try(removeSubRollout MakeToolbox.theSubrollout viewportGUIModule)catch()

viewportGUIModuleVer = 1.0
primaryColor = blue
secondaryColor = color 255 169 0

tool gui_spline
(
	local r1	
	local c1
	local contName
	
	on mousePoint clickno do coordsys grid
	if clickno == 1 then 
	(
		max create mode
		
		r1 = splineshape()
		addnewspline r1
		addknot r1 1 #smooth #curve gridPoint
		addknot r1 1 #smooth #curve gridPoint
		updateshape r1
		r1.wirecolor = primaryColor
		r1.name = contName = uniqueName "splineController_"
		
	)else if clickno == 2 then
	(
		
	)else
	(
		
			addknot r1 1 #smooth #curve gridPoint
			updateShape r1		
	)
		
	on mouseMove clickno do coordsys grid
	(
		
		setknotpoint r1 1 (numknots r1 1) gridPoint
		updateshape r1
		
	)
	
	on mouseAbort clickdo do coordsys grid
	(
		if (numknots r1 1) > 3 then
		(
			deleteknot r1 1 (numknots r1 1)
			updateshape r1
			
			in coordsys world r1.pivot = r1.center
			
			addmodifier r1 (skin())
			
			r1.modifiers[1].bone_limit = 1
			circles = #()
				
			for q in 1 to  (numknots r1 1) do
			(
				c1 = circle pos:(getknotpoint r1 1 q) radius:((distance r1.max r1.min)/20)
				c1.wirecolor = secondaryColor
				c1.parent = r1
				c1.position.controller = position_list()
				c1.position.controller[2].controller = position_xyz()
				
				c1.setskinpose()
				
				c1.rotation.controller = rotation_list()
				c1.rotation.controller[2].controller = euler_xyz()
				
				
				c1.position.controller.setname 1 "Frozen Position" 		
				c1.position.controller.setname 2 "Zero Position XYZ"
				c1.position.controller.active = 2
				c1.rotation.controller.active = 2
				
				c1.name =  (contName + "_handle_" + q as string)
				
				append circles c1
				
			)
			
			max modify mode
			select r1
			
			for q in 1 to circles.count do
			(
				skinOps.addBone (r1.modifiers[1]) circles[q] 1
				
			)

			classof r1
			
			count = 1
			for q in 1 to circles.count do
			(
				for g in 1 to 3 do
				(
					skinOps.ReplaceVertexWeights (r1.modifiers[1]) count q 1
					count += 1
				)
			)
			
			max create mode
			
			
			
		)else
		(
			
			delete r1
		)
	)
	
	on stop do coordsys grid
	(
		try
		(
			if isvalidnode r1 then
			(
				if viewportGUIModule.gui_text != "" then
				(
					t1 = text()
					t1.wirecolor = secondaryColor
					t1.parent = r1
					t1.text = viewportGUIModule.gui_text
					t1.size = c1.radius * 5
					
					t1.name = (contName + "_label")
					
					size = abs( t1.max.x  - t1.min.x)
					contSize = amax #(abs(r1.max.y - r1.min.y), abs( r1.max.x - r1.min.x))*.85
					
					if size > contSize then
					(
						t1.scale *= (contSize/size)
						size = abs( t1.max.x -   t1.min.x)
					)
					
					t1.pos = r1.center
					t1.pos.y += abs(r1.max.y - r1.min.y)/1.95
					t1.pos.y += t1.size/40
					
					t1.pos.y += c1.radius*1.5

					
				)
			)
		)catch()
	)
)

tool gui_line
(
	local r1
	local c1
	local origPos 
	local orientation = 1
	local contName
	
	on mousePoint clickno do coordsys grid
	if clickno == 1 then 
	(
		
		r1 = rectangle pos:gridPoint width:50 length:0.001
		r1.wirecolor = primaryColor
		r1.name = contName = uniqueName "lineController_"
		
		c1 = circle pos:gridPoint
		c1.wirecolor = secondaryColor
		c1.parent = r1
		c1.name = contName + "_handle"
		origPos = gridPoint
		
		c1.pos = r1.center
		c1.radius = (r1.length + r1.width)/30
		
		c1.position.controller = position_list()
		c1.position.controller[2].controller = position_xyz()
		c1.position.controller[2][1].controller = float_limit()
		c1.position.controller[2][2].controller = float_limit()
		c1.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Lower_Limit] "-Width/2.0"
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Upper_Limit] "Width/2.0"
		c1.position.controller[2][2][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][2][#Limits][#Upper_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		c1.rotation.controller = rotation_list()
		c1.rotation.controller[2].controller = euler_xyz()
		
		c1.position.controller.setname 1 "Frozen Position" 		
		c1.position.controller.setname 2 "Zero Position XYZ"
		c1.rotation.controller.active = 2
		c1.position.controller.active = 2
		
		c1.setskinpose()
		
		
				
			
		c1.position.controller.active = 2
		
	)else( #stop)
	
	on mouseMove clickno do coordsys grid
	(
		inx1 = 1
		inx2 = 2
		
		wVal = (origPos[inx1] - gridPoint[inx1])
		lVal = (origPos[inx2] - gridPoint[inx2])
		
		if abs(wVal) > abs(lVal) then
		(
			r1.width = abs(wVal)
			r1.length = .001
			orientation = 1
		)else
		(
			r1.length = abs(lVal)
			r1.width = .001
			orientation = 2
		)
		
		if wVal < 0 then
		(
			r1.pos.x = (origPos.x + r1.width/2)
		)else
		(
			r1.pos.x = (origPos.x - r1.width/2)
		)
		
		if lVal < 0 then
		(
			r1.pos.y = (origPos.y + r1.length/2)
		)else
		(
			r1.pos.y = (origPos.y - r1.length/2)
		)
		
		c1.pos = r1.center
		c1.radius = (r1.length + r1.width)/30

	)

	on stop do coordsys grid
	(
		try
		(
			if viewportGUIModule.gui_text != "" then
			(
				t1 = text()
				t1.wirecolor = secondaryColor
				t1.parent = r1
				t1.text = viewportGUIModule.gui_text
				t1.size = c1.radius * 5
				t1.name = contName + "_label"
				
				size = abs( t1.max.x  - t1.min.x)
				contSize = amax #(abs(r1.max.y - r1.min.y), abs( r1.max.x - r1.min.x))*.85
				
				if size > contSize then
				(
					t1.scale *= (contSize/size)
					size = abs( t1.max.x -   t1.min.x)
				)
				
				t1.pos = r1.center
				t1.pos.y += abs(r1.max.y - r1.min.y)/1.95
				t1.pos.y += t1.size/40
				
				if orientation == 1 then
				(
					t1.pos.y += c1.radius*1.5
				)
				
			)
		)catch()
	)

)

tool gui_circle
(
	local r1
	local c1
	local origPos 
	local contName
	
	on mousePoint clickno do coordsys grid
	if clickno == 1 then 
	(
		
		r1 = circle pos:gridPoint radius:50
		r1.wirecolor = primaryColor
		r1.name = contName = uniqueName "circleController_"
		
		c1 = circle pos:gridPoint
		c1.wirecolor = secondaryColor
		c1.name = contName + "_handle"
		c1.parent = r1
		origPos = gridPoint
		
		c1.pos = r1.center
		c1.radius = (r1.radius)/25
		
		c1.position.controller = position_list()
		c1.position.controller[2].controller = position_xyz()
		c1.position.controller[2][1].controller = float_limit()
		c1.position.controller[2][2].controller = float_limit()
		c1.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Radius] c1.position.controller[2][1][#Limits][#Lower_Limit] "-Radius"
		paramWire.connect r1.baseObject[#Radius] c1.position.controller[2][1][#Limits][#Upper_Limit] "Radius"
		paramWire.connect r1.baseObject[#Radius] c1.position.controller[2][2][#Limits][#Lower_Limit] "-Radius"
		paramWire.connect r1.baseObject[#Radius] c1.position.controller[2][2][#Limits][#Upper_Limit] "Radius"
		c1.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		c1.rotation.controller = rotation_list()
		c1.rotation.controller[2].controller = euler_xyz()
		
		c1.position.controller.setname 1 "Frozen Position" 		
		c1.position.controller.setname 2 "Zero Position XYZ"
		c1.rotation.controller.active = 2
		c1.position.controller.active = 2
		
		c1.setskinpose()
		
		
	)else( #stop)
	
	on mouseMove clickno do coordsys grid
	(
		inx1 = 1
		inx2 = 2
		
		r1.radius = abs(distance origPos gridPoint)
		
		c1.pos = r1.center
		c1.radius = (r1.radius)/10

	)
	
	on stop do coordsys grid
	(
		try
		(
			if viewportGUIModule.gui_text != "" then
			(
				t1 = text()
				t1.wirecolor = secondaryColor
				t1.parent = r1
				t1.text = viewportGUIModule.gui_text
				t1.size = c1.radius * 5
				t1.name = contName + "_label"
				size = abs( t1.max.x  - t1.min.x)
				contSize = abs( r1.max.x - r1.min.x)*.85
				
				if size > contSize then
				(
					t1.scale *= (contSize/size)
					size = abs( t1.max.x -   t1.min.x)
				)
				
				t1.pos = r1.center
				t1.pos.y += r1.radius*1.05
				t1.pos.y += t1.size/40
				
			)
		)catch()
	)
)

tool gui_box
(
	local r1
	local c1
	local origPos 
	local contName
	
	on mousePoint clickno do 
	if clickno == 1 then 
	(
		
		in coordsys grid
		(
			r1 = rectangle pos:gridPoint width:50 length:50
			r1.wirecolor = primaryColor
			r1.name = contName = uniqueName "boxController_"
			
			c1 = circle pos:gridPoint
			c1.wirecolor = secondaryColor
			c1.parent = r1
			c1.name = contName + "_handle"
			origPos = gridPoint
			
						
			--viewportGUIModule.textObj.pos.y = r1.max.y
			
			
			c1.pos = r1.center
			c1.radius = (r1.length + r1.width)/30
			
					
			c1.position.controller = position_list()
			c1.position.controller[2].controller = position_xyz()
			c1.position.controller[2][1].controller = float_limit()
			c1.position.controller[2][2].controller = float_limit()
			c1.position.controller[2][3].controller = float_limit()
			
			paramWire.connect r1.baseObject[#Length] c1.position.controller[2][2][#Limits][#Lower_Limit] "-Length/2.0"
			paramWire.connect r1.baseObject[#Length] c1.position.controller[2][2][#Limits][#Upper_Limit] "Length/2.0"
			paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Lower_Limit] "-Width/2.0"
			paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Upper_Limit] "Width/2.0"
			c1.position.controller[2][3][#Limits][#Lower_Limit].value = 0
			c1.position.controller[2][3][#Limits][#Upper_Limit].value = 0
			
			
			c1.rotation.controller = rotation_list()
			c1.rotation.controller[2].controller = euler_xyz()
			
			c1.position.controller.setname 1 "Frozen Position" 		
			c1.position.controller.setname 2 "Zero Position XYZ"
			c1.rotation.controller.active = 2
			c1.position.controller.active = 2
			
			c1.setskinpose()
			
			
			
			
			
		
		
		)
	)else(#stop)
	
	on mouseMove clickno do 
	(
		in coordsys grid
		(
		
			inx1 = 1
			inx2 = 2
			
			wVal = (origPos[inx1] - gridPoint[inx1])
			lVal = (origPos[inx2] - gridPoint[inx2])
			
			
			if keyboard.shiftpressed then
			(
				r1.length = (abs lval + abs wval)/2.0
				r1.width = r1.length
			)else
			(
				r1.width = abs(wVal)
				r1.length = abs(lVal)
			)
			
			if wVal < 0 then
			(
				r1.pos.x = (origPos.x + r1.width/2)
			)else
			(
				r1.pos.x = (origPos.x - r1.width/2)
			)
			
			if lVal < 0 then
			(
				r1.pos.y = (origPos.y + r1.length/2)
			)else
			(
				r1.pos.y = (origPos.y - r1.length/2)
			)
			
			c1.pos = r1.center
			c1.radius = (r1.length + r1.width)/30
		)
	)
	on stop do coordsys grid
	(
		
		try
		(
			
			if viewportGUIModule.gui_text != "" then
			(
				in coordsys grid
				(
					t1 = text()
					t1.wirecolor = secondaryColor
					t1.parent = r1
					t1.text = viewportGUIModule.gui_text
					t1.size = c1.radius * 5
					t1.name = contName + "_label"
					size = abs( t1.max.x  - t1.min.x)
					contSize = abs( r1.max.x - r1.min.x)*.85
					
					if size > contSize then
					(
						t1.scale *= (contSize/size)
						size = abs( t1.max.x -   t1.min.x)
					)
					
					t1.pos = r1.center
					t1.pos.y += r1.length/1.95
					t1.pos.y += t1.size/40
				)
			)
		)catch()
	)
)

function makeFingerSlider pos len rad cSize name1 inx=
(
	local r1
	local c1
	local origPos 
	local orientation = 1
	local contName
	in coordsys grid
	(
		
		r1 = rectangle pos:pos width:len length:0.001
		r1.wirecolor = primaryColor
		
		r1.name = name1 + "_finger_" + inx as string
		c1 = circle pos:pos
		c1.wirecolor = secondaryColor
		c1.name = r1.name + "_handle"
		
		in coordsys world
		(
			t1 = copy r1
			converttosplineshape t1
			p1 = getknotpoint t1 1 3
			delete t1
			r1.pivot = p1
		)
	
		
		xOffset =  ((len)/6.0)
		c1.pos = pos + [len/2.0,0,0] - [xOffset,0,0]
		c1.parent = r1
		origPos = pos
		
		c1.pos = r1.center
		c1.radius = cSize
		
		c1.position.controller = position_list()
		c1.position.controller[2].controller = position_xyz()
		c1.position.controller[2][1].controller = float_limit()
		c1.position.controller[2][2].controller = float_limit()
		c1.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Lower_Limit] "-Width/2.0"
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Upper_Limit] "Width/2.0"
		c1.position.controller[2][2][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][2][#Limits][#Upper_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		c1.rotation.controller = rotation_list()
		c1.rotation.controller[2].controller = euler_xyz()
		
		c1.position.controller.setname 1 "Frozen Position" 		
		c1.position.controller.setname 2 "Zero Position XYZ"
		c1.rotation.controller.active = 2
		c1.position.controller.active = 2
		
		c1.setskinpose()
		c1.position.controller.active = 2
		
		return r1
	)
)

tool gui_hand
(
	local rec1
	local c1
	local rad
	local origPos 
	local contName
	
	on mousePoint clickno do coordsys grid
	if clickno == 1 then 
	(
		rec1 = rectangle length:65 width:50 pos:gridPoint
		rec1.wirecolor = primaryColor
		rec1.name = contName = uniqueName "handController_"
		
		origPos = gridpoint
		fingers = #()
		
		for q in 1 to 5 do
		(
			if q == 1 then len = 15
			if q == 2 then len = 25
			if q == 3 then len = 27
			if q == 4 then len = 25
			if q == 5 then len = 22
			rad = 1
			append fingers (makeFingerslider gridPoint len rad 2 contName q)
		)
		
		h1 = splineshape()
		addnewspline h1
		addknot h1 1 #corner #curve ([8.83294,-19.6482,0])
		addknot h1 1 #corner #curve ([-8.18386,-19.6482,0])
		addknot h1 1 #corner #curve ([-10.915,4.93167,0])
		addknot h1 1 #corner #curve ([11.1439,4.93167,0])
		close h1 1
		updateshape h1
		h1.wirecolor = rec1.wirecolor
		h1.pos = gridPoint
		h1.parent = rec1
		h1.pos.x -= 2
		h1.pos.y -= 6
		h1.name = contName + "_hand"
		
		for q in 1 to fingers.count do
		(
			fingers[q].parent = h1
			if q == 1 then fingers[q].pos = h1.pos + [12.8758,-8.41288,0]
			if q == 2 then fingers[q].pos = h1.pos + [11.3425,8.50842,0]
			if q == 3 then fingers[q].pos = h1.pos + [4.20142,8.50842,0]
			if q == 4 then fingers[q].pos = h1.pos + [-3.51469,8.50842,0]
			if q == 5 then fingers[q].pos = h1.pos + [-11.2313,8.50842,0]
			
			if q != 1 then
			(
				rotate fingers[q] 90 [0,0,1]
			)else
			(
				rotate fingers[q] 70 [0,0,1]
			)
			
		
		)
		
		t1 = text()
		t1.wirecolor = secondaryColor
		t1.parent = rec1
		t1.text = viewportGUIModule.gui_text
		t1.size = (rad * 8)*rec1.scale.x
		t1.name = contName + "_label"
		
		size = (abs( t1.max.x  - t1.min.x))
		contSize = abs( rec1.max.x - rec1.min.x)*.85
		
		if size > contSize then
		(
			t1.scale *= (contSize/size)
			size = abs( t1.max.x -   t1.min.x)
		)
		
		t1.pos = rec1.center
		t1.pos.y += (rec1.length/1.95)*rec1.scale.x
		t1.pos.y += (t1.size/40)*rec1.scale.x
		
		
		
	)else(#stop)
	
	on mouseMove clickno do coordsys grid
	(
		
		origDist = sqrt(65^2 + 50^2)
		newDist = distance origpos gridpoint
		
		sc = (newDist/origDist as float)*2
		rec1.scale = [sc,sc,sc]
		

	)
	
	on stop do coordsys grid
	(
	
		try
		(
			if viewportGUIModule.gui_text != "" then
			(
				
				resetscale rec1
				
				
				
			)
		)catch()
		
	)
	
)

tool gui_eye
(
	local r1
	local r2
	local r3
	local c1
	local xOffset
	local origPos 
	local contName
	
	on mousePoint clickno do coordsys grid
	if clickno == 1 then 
	(		
		
		r1 = rectangle pos:gridPoint width:50 length:50
		r1.wirecolor = primaryColor
		r1.name = contName = uniqueName "eyeController_"
		
		c1 = circle pos:gridPoint
		c1.wirecolor = secondaryColor
		c1.parent = r1
		c1.name = contName + "_pupilHandle"
		origPos = gridPoint
		
		r2 = rectangle pos:gridPoint width:55 length:.001
		r2.name = contName + "_topLid_handle"
		r3  = rectangle pos:gridPoint width:55 length:.001
		r3.name = contName + "_bottomLid_handle"
		r2.wirecolor = primaryColor
		r3.wirecolor = primaryColor
		
		r2.parent = r1
		r3.parent = r1
		xOffset = ((r1.max.y - r1.min.y)/8.0)
		r2.pos.y = r1.max.y - xOffset
		r3.pos.y = r1.min.y + xOffset
		
		--viewportGUIModule.textObj.pos.y = r1.max.y
		
		
		c1.pos = r1.center
		c1.radius = (r1.length + r1.width)/30
		
		c1.position.controller = position_list()
		c1.position.controller[2].controller = position_xyz()
		
		c1.position.controller = position_list()
		c1.position.controller[2].controller = position_xyz()
		c1.position.controller[2][1].controller = float_limit()
		c1.position.controller[2][2].controller = float_limit()
		c1.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Lower_Limit] "-Width/2.0"
		paramWire.connect r1.baseObject[#Width] c1.position.controller[2][1][#Limits][#Upper_Limit] "Width/2.0"
		paramWire.connect r1.baseObject[#Length] c1.position.controller[2][2][#Limits][#Lower_Limit] "-Length/2.0"
		paramWire.connect r1.baseObject[#Length] c1.position.controller[2][2][#Limits][#Upper_Limit] "Length/2.0"
		c1.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		c1.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		c1.rotation.controller = rotation_list()
		c1.rotation.controller[2].controller = euler_xyz()
		
		c1.position.controller.setname 1 "Frozen Position" 		
		c1.position.controller.setname 2 "Zero Position XYZ"
		c1.rotation.controller.active = 2
		c1.position.controller.active = 2
		
		c1.setskinpose()
		c1.position.controller.active = 2
		
		--------------
		
		
		
		
		
		
	)else(#stop)
	
	on mouseMove clickno do coordsys grid
	(
		
		xOffset = ((r1.max.y - r1.min.y)/8.0)
		r2.pos.y = r1.max.y - xOffset
		r3.pos.y = r1.min.y + xOffset
		r2.width = r1.width*1.1
		r3.width = r1.width*1.1
		inx1 = 1
		inx2 = 2
		
		wVal = (origPos[inx1] - gridPoint[inx1])
		lVal = (origPos[inx2] - gridPoint[inx2])
		
		
		if (keyboard.shiftpressed) then
		(
			r1.length = (abs wVal+ abs lVal)/2.0
			r1.width = r1.length
		)else
		(
			r1.width = abs(wVal)
			r1.length = abs(lVal)
		)
		
		if wVal < 0 then
		(
			r1.pos.x = (origPos.x + r1.width/2)
		)else
		(
			r1.pos.x = (origPos.x - r1.width/2)
		)
		
		if lVal < 0 then
		(
			r1.pos.y = (origPos.y + r1.length/2)
		)else
		(
			r1.pos.y = (origPos.y - r1.length/2)
		)
		
		c1.pos = r1.center
		c1.radius = (r1.length + r1.width)/30

	)
	on stop do coordsys grid
	(
		xOffset = ((r1.max.y - r1.min.y)/8.0)
		r2.pos.y = r1.max.y - xOffset
		r3.pos.y = r1.min.y + xOffset
		r2.width = r1.width*1.1
		r3.width = r1.width*1.1
		
		r2.position.controller = position_list()
		r2.position.controller[2].controller = position_xyz()
		
		r2.position.controller = position_list()
		r2.position.controller[2].controller = position_xyz()
		r2.position.controller[2][1].controller = float_limit()
		r2.position.controller[2][2].controller = float_limit()
		r2.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Length] r2.position.controller[2][2][#Limits][#Lower_Limit] ("-Length + Length/8.0")
		paramWire.connect r1.baseObject[#Length] r2.position.controller[2][2][#Limits][#Upper_Limit] ("Length/8.0")
		r2.position.controller[2][1][#Limits][#Lower_Limit].value = 0
		r2.position.controller[2][1][#Limits][#Upper_Limit].value = 0
		r2.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		r2.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		r2.rotation.controller = rotation_list()
		r2.rotation.controller[2].controller = euler_xyz()
		
		r2.position.controller.setname 1 "Frozen Position" 		
		r2.position.controller.setname 2 "Zero Position XYZ"
		r2.rotation.controller.active = 2
		r2.position.controller.active = 2
		
		r2.setskinpose()
		r2.position.controller.active = 2
		
		--------------
				
		r3.position.controller = position_list()
		r3.position.controller[2].controller = position_xyz()
		
		r3.position.controller = position_list()
		r3.position.controller[2].controller = position_xyz()
		r3.position.controller[2][1].controller = float_limit()
		r3.position.controller[2][2].controller = float_limit()
		r3.position.controller[2][3].controller = float_limit()
		
		paramWire.connect r1.baseObject[#Length] r3.position.controller[2][2][#Limits][#Lower_Limit] ("-Length/8.0")
		paramWire.connect r1.baseObject[#Length] r3.position.controller[2][2][#Limits][#Upper_Limit] ("Length - Length/8.0")
		r3.position.controller[2][1][#Limits][#Lower_Limit].value = 0
		r3.position.controller[2][1][#Limits][#Upper_Limit].value = 0
		r3.position.controller[2][3][#Limits][#Lower_Limit].value = 0
		r3.position.controller[2][3][#Limits][#Upper_Limit].value = 0
		
		
		r3.rotation.controller = rotation_list()
		r3.rotation.controller[2].controller = euler_xyz()
		
		r3.position.controller.setname 1 "Frozen Position" 		
		r3.position.controller.setname 2 "Zero Position XYZ"
		r3.rotation.controller.active = 2
		r3.position.controller.active = 2
		
		r3.setskinpose()
		r3.position.controller.active = 2
		
		try
		(
			if viewportGUIModule.gui_text != "" then
			(
				t1 = text()
				t1.wirecolor =secondaryColor
				t1.parent = r1
				t1.text = viewportGUIModule.gui_text
				t1.size = c1.radius * 5
				t1.name = contName + "_label"
				size = abs( t1.max.x  - t1.min.x)
				contSize = abs( r1.max.x - r1.min.x)*.85
				
				if size > contSize then
				(
					t1.scale *= (contSize/size)
					size = abs( t1.max.x -   t1.min.x)
				)
				
				t1.pos = r1.center
				t1.pos.y += r1.length/1.95
				t1.pos.y += t1.size/40
				
			)
		)catch()
	)
)

rollout viewportGUIModule ("Viewport GUI Creator")
(
	local gui_text = ""
	local controllerText
	local currentTool
	
	groupbox basicControlersGroup "Basic Controllers" width:160 height:60 offset:[-11,-3]
	button boxController "Box" width:76 height:20  align:#left offset:[-7,-50]
	button circleController "Circle" width:76 height:20 align:#left offset:[69,-25]
	button lineController "Line " width:76 height:20  align:#left offset:[-7,-5]
	button splineController "Spline"width:76 height:20 align:#left offset:[69,-25]
	
	groupbox presetControlersGroup "Preset Controllers" width:160 height:40 offset:[-11,0]
	button handController "Hand" width:76 height:20  align:#left offset:[-7,-30]
	button eyeController "Eye"  width:76 height:20 align:#left offset:[69,-25]
		
	label wirecolorsLabel "Colors:" align:#left offset:[-8,6]
	colorpicker primaryColorPicker "" width:25 offset:[23,-20] color:blue align:#left
	colorpicker secondaryColorPicker "" width:25 offset:[44,-25] color:(color 255 169 0) align:#left
	
	checkbox askForLabel "Add label" checked:true align:#left offset:[77,-22]
	
	function getlabel =
	(
		theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
		theobj.text ="Set controller label"
		DialogResult = theObj.Showmodal()

		if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
		(
			gui_text = theobj.InstanceName 
		
		)else
		(
			gui_text = ""
		)
	)
	
	on boxController pressed do
	(
		max create mode
		currentTool = gui_box
		
		if askForLabel.checked then
		(
			getlabel()
		)else
		(
			gui_text = ""
		)
			starttool currentTool
		
		
	)
	
	on circleController pressed do
	(
		max create mode
		currentTool = gui_circle
		if askForLabel.checked then
		(
			getlabel()

		)else
		(
			gui_text = ""
		)
			starttool currentTool
		
	)
	
	on lineController pressed do
	(
		max create mode
		currentTool = gui_line
		if askForLabel.checked then
		(
			getlabel()
		)else
		(
			gui_text = ""
		)
			starttool currentTool
		
	)
	
	on splineController pressed do
	(
		max create mode
		currentTool = gui_spline
		if askForLabel.checked then
		(
			getlabel()
		)else
		(
			gui_text = ""
		)
			starttool currentTool
		
	)
	
	on handController pressed do
	(
		max create mode
		currentTool = gui_hand
		if askForLabel.checked then
		(
			getlabel()
		)else
		(
			gui_text = ""
		)
			starttool currentTool
	)
	
	on eyeController pressed do
	(
		max create mode
		currentTool = gui_eye
		if askForLabel.checked then
		(
			getlabel()
		)else
		(
			gui_text = ""
		)
			starttool currentTool
	)
	
	on primaryColorPicker changed state do (primaryColor = primaryColorPicker.color)
	on secondaryColorPicker changed state do (secondaryColor = secondaryColorPicker.color)
)

AddSubRollout MakeToolbox.theSubrollout viewportGUIModule
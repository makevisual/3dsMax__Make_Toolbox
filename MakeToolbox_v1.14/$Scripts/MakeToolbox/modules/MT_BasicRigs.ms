--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 12.10.2012 >> Release -ad
--- version 1.1 : 2.9.2015 >> Added bug fix -ad
--*****************************************************
basicRigsModuleVer = 1.1
try(removeSubRollout MakeToolbox.theSubrollout basicRigsModule)catch()

rollout basicRigsModule ("Basic Rigs v" + (basicRigsModuleVer as string))
(
button stretchPointButton "Stretch Point" pos:[2,2] width:80
button pistonMakerButton "Piston Maker" pos:[82,2] width:80
button gimbalChainButton "Gimbal Chain" pos:[2,26] width:80
button controlRingButton "Ctrl Ring" pos:[82,26] width:80
	
groupBox grp1 "Stretchy IK" pos:[3,50] width:158 height:62
button autoik "Stretchy" offset: [-5,-51] align:#left width:73 height:20 tooltip:"Creates a stretchy IK chain, by applying to an IK Handle."
button noik "Remove" offset: [68,-25] align:#left width:73 height:20 tooltip:"Cleanly removes scripted controlers for stretchy IK Chain."
checkbox check1 "Allow negative stretch" align:#left offset:[-4,0]
	
on stretchPointButton pressed do
	(
	try
		( 
			controlPoint = point box:on wirecolor:green
			controlPointUpnode = point box:on wirecolor:green                 
			controlPoint.transform = $.transform 
			$.pos.controller = position_list ()       
			$.pos.controller.Available.controller = Position_Constraint () 
			$.pos.controller.Position_Constraint.constraints.appendTarget controlPoint 100     
			select $.parent
			controlPointUpnode.transform = $.transform
			$.parent = controlPointUpnode                                   
			$.rotation.controller = rotation_list ()                  
			$.rotation.controller.Available.controller = LookAt_Constraint ()  
			$.rotation.controller.LookAt_Constraint.constraints.appendTarget controlPoint 100 
			$.rotation.controller.LookAt_Constraint.controller.upnode_world = off
			$.rotation.controller.LookAt_Constraint.controller.pickUpNode = controlPointUpnode
			$.rotation.controller.LookAt_Constraint.lookat_vector_length = 0 
			$.boneFreezeLength=false                                 
			$.boneScaleType=#squash                               
			select controlPoint   
		)catch(messagebox("Select the endbone")) 	
	)
	
on pistonMakerButton pressed do
	(
		try
		(
			global switchVariable 
			switchVariable = False
			
			if selection.count != 2 then
			(
				messagebox("You must select Two (2) objects")
			)
			else 
			(
			hydPoint01 = Point pos:[0,0,0] Box:off cross:on wirecolor:red 
			hydPoint02 = Point pos:[0,0,0] Box:off cross:on wirecolor:red 
				for i in 1 to selection.count do
				(
					if switchVariable != true then
					(
						hydPoint01.transform = selection[i].transform
						selection[i].parent = hydPoint01
						selection[i].rotation.controller = rotation_list () 
						selection[i].rotation.controller.Available.controller = LookAt_Constraint ()  a
						selection[i].rotation.controller.LookAt_Constraint.constraints.appendTarget hydPoint02 100 
						selection[i].rotation.controller.LookAt_Constraint.controller.target_axis = 2
						selection[i].rotation.controller.LookAt_Constraint.controller.upnode_axis = 1
						selection[i].rotation.controller.LookAt_Constraint.controller.StoUP_axis = 1
						selection[i].rotation.controller.LookAt_Constraint.controller.viewline_length_abs = off
						selection[i].rotation.controller.LookAt_Constraint.controller.lookat_vector_length = 0
						switchVariable = true
					)
					else
					(
						hydPoint02.transform = selection[i].transform
						selection[i].parent = hydPoint02
						selection[i].rotation.controller = rotation_list () 
						selection[i].rotation.controller.Available.controller = LookAt_Constraint ()  a
						selection[i].rotation.controller.LookAt_Constraint.constraints.appendTarget hydPoint01 100
						selection[i].rotation.controller.LookAt_Constraint.controller.target_axis = 2
						selection[i].rotation.controller.LookAt_Constraint.controller.upnode_axis = 1
						selection[i].rotation.controller.LookAt_Constraint.controller.StoUP_axis = 1
						selection[i].rotation.controller.LookAt_Constraint.controller.viewline_length_abs = off
						selection[i].rotation.controller.LookAt_Constraint.controller.lookat_vector_length = 0
					)
				)
			)
		)catch(messagebox("You must select Two (2) objects")) 
	)
	
on gimbalChainButton pressed do
	(
	try
		(
			for i in 1 to selection.count do
			(
				newPoint = point wirecolor:red
				newPoint.size = 5
				newPoint.transform = selection[i].transform
				try
					(
					newPoint.parent = selection[i].parent 
					)catch()
				selection[i].parent = newPoint
			)
		)catch()
	)
	
on controlRingButton pressed do
	(
	try(
		for i in 1 to selection.count do
			(
			cring = circle radius:15 wirecolor:green
			cring.thickness = (cring.radius/20)
			cring.renderable = off
			cring.transform = selection[i].transform
			in coordsys cring (rotate cring (angleaxis 90 [0,1,0]))
			selection[i].parent = cring
			cring.showFrozenInGray = off
				
			newSpline = (Edit_Spline())
			addmodifier cring newSpline
			)
		)catch (messagebox "Select Object(s)")
	)
	
on autoik pressed do
	(
 	try
 		(
			parentbones=#()

			for b in 1 to selection.count do
			(
				max create mode
				if selection != undefined then
				(
					ikchainpoint = selection[b]
					endbone = ikchainpoint.controller.endjoint
					startjoint = ikchainpoint.controller.endjoint
					
					parentbones[1] = endbone
					parentbones.count = 1
					count = 1
					while startjoint != ikchainpoint.controller.startjoint do
					(
						parentbones[count+1] = parentbones[count].parent
						count += 1
						startjoint = startjoint.parent			
					)
					
							
					if endbone != undefined and ikchainpoint != undefined then
					(
						in coordsys world distance1 = (distance ikchainpoint.pos parentbones[1].pos)
						
						chainCA = attributes chain
						(
							parameters main rollout:params
							(
								stretchval type:#float ui:sval
								checkval type:#boolean ui:chval
								smoothcheck type:#boolean ui:cval
								smoothmult type:#float ui:mval
								posval type:#point3 animatable:true
							)
							
							rollout params "Extra Stretch Parameters"
							(
								spinner sval "Stretch Value: " type:#float range:[-400,400,0]
								checkbox chval "Allow negative stretch" type:#boolean align:#center
								label label1 "----"
								checkbox cval "Enable Smooth Stretch" 
								spinner mval "Smoothness: " type:#float range:[0,2.5,1]
							)
						)
						try(custattributes.delete ikchainpoint 1)catch()
						custAttributes.add ikchainpoint chainCA
						
						obj1= Point()
						obj1.name = "stretchHelper_" + obj1.name
						obj1.transform = ikchainpoint.transform
						obj1.parent = ikchainpoint
						obj1.scale = [.001,.001,.001]
						selection[b].posval.controller = point3_script()
						selection[b].posval.controller.addNode "helper_point" obj1
						selection[b].posval.controller.script = 
						"(in coordsys world(helper_point.parent.pos))"
						selection[b].smoothcheck = true
						selection[b].smoothmult = 1
						if check1.checked == true then selection[b].checkval = true else selection[b].checkval = false
		
						for k in 1 to (parentbones.count - 1) do
						(
							global f = 2
							parentbones[k].position.controller=Position_XYZ()
							parentbones[k].position.controller=position_list()
							parentbones[k].position.controller.available.controller = position_xyz()
							parentbones[k].position.controller[f].controller.x_position.controller=float_script()
		
							
						)
													
						for m in 1 to (parentbones.count - 1) do
						(
							in coordsys world distance1 = distance1 + (distance parentbones[m] parentbones[m+1]) 			
						
						)
						initScale = abs(parentbones[parentbones.count].scale[1])
				
				
						IKscript = "try(in coordsys world (	d = distance topLevelBone.pos ikChainPoint1)
									
									scale1 = abs(topLevelBone.scale[1])
									distance1 *= scale1/initscale
									st = (d - distance1)
									
									if checkval != true then
									(
										if (st < 0) then st = 0 							
									)
									
									if smoothcheck == true and checkval != true then
									(
																
										value = -(abs(distance1 - d)/distance1) - .5
										value *= 5 
										mult = 2.7 / (smoothmult)
										if mult < 1 then mult = 1
										amount2 = (1/(sqrt(3.14 )))*(mult)^-(((value)^2)/2)
										amount2 *= (distance1/3) * 2
									
									)else amount2 = 0
									
									amount2 = abs(amount2)
									
									amount = ((st  + amount2 + stretchval)/count1)
									
									(orig1 + amount/scale1))catch()"
				
						
						for q in 1 to (parentbones.count - 1) do
						(
						parentbones[q].position.controller[f].controller.x_position.controller.addnode "topLevelBone" ikchainpoint.controller.startJoint			
						parentbones[q].position.controller[f].controller.x_position.controller.addTarget "ikChainPoint1" ikchainpoint.posval.controller
						parentbones[q].position.controller[f].controller.x_position.controller.addconstant "distance1" distance1
						parentbones[q].position.controller[f].controller.x_position.controller.addconstant "orig1" (parentbones[q].position.controller[f].controller.x_position.controller.script as float)
						parentbones[q].position.controller[f].controller.x_position.controller.addconstant "count1" ((parentbones.count - 1) as integer)
						parentbones[q].position.controller[f].controller.x_position.controller.addconstant "initScale" initScale
						parentbones[q].position.controller[f].controller.x_position.controller.addTarget "stretchval" ikchainpoint.baseObject.chain[1]
						parentbones[q].position.controller[f].controller.x_position.controller.addTarget "checkval" ikchainpoint.baseObject.chain[2]
						parentbones[q].position.controller[f].controller.x_position.controller.addTarget "smoothcheck" ikchainpoint.baseObject.chain[3]
						parentbones[q].position.controller[f].controller.x_position.controller.addTarget "smoothmult" ikchainpoint.baseObject.chain[4]
					
						parentbones[q].position.controller[f].controller.x_position.controller.script = IKscript
						max create mode	
						)					
						)
								
				)
			)
 		)catch(messagebox "you must select an IK end effector")
	)
		
on noik pressed do
	(
		for p in 1 to selection.count do
		(
		
			obj = selection[p].controller.endjoint
			try(selection[p].posval.controller = bezier_point3())catch()
			for j in 1 to 100 do
			(
				
					try(orig1 = obj.position.controller[1][1].controller.getconstant "orig1")catch()
					obj.position.controller=bezier_position()
					obj.position.controller=position_xyz()	
					try(in coordsys obj.parent (obj.position.x = orig1))catch()
					orig1 = undefined
					obj = obj.parent	
				
				if obj == selection[p].controller.startjoint then exit
			)
		
		try(delete (selection[p].posval.controller.getNode "helper_point"))catch()
		selection[p].pos = selection[p].pos
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout basicRigsModule
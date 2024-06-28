--*****************************************************
-- Tool part of the Make Toolbox
-- Tyson Ibele, tyson@tysonibele.com 
--*****************************************************
-- HISTORY:
--- version 1.07 : 05.25.2011 >> Release 
--- version 1.08 : 03.12.2012  >> Integrated to MakeToolbox
--*****************************************************
WheelMakerModuleVer = 01.8
try(removeSubRollout MakeToolbox.theSubrollout WheelMakerModule)catch()

rollout WheelMakerModule ("Wheel Maker v" +(WheelMakerModuleVer as string))
(
	local wheelObj = undefined
	local groundObj = undefined

	groupBox WheelTypeGrpBox "Wheel Type" width:160 height:52 offset:[-10,-3]
	radiobuttons wheelType labels:#("Cylinder","Box") offset:[0,-42]
	checkbox compensateRadius "Dynamic radius" checked:true offset:[18,-1]
	radiobuttons RType labels:#("Forward/Back", "Left/Right") offset:[-9,0] --visible:false 

	groupBox GroundGrpBox "Ground" width:160 height:40 offset:[-10,-2]
	pickbutton pickGround "Pick Ground" width:130 height:20 offset:[-10,-30]
	button removeGround "X" width:20 height:20 offset:[67,-25]

	on removeGround pressed do
	(
		groundObj = undefined
		pickGround.text = "Pick Ground"
	)
	on pickGround picked obj do
	(
		if iskindof obj geometryclass then
		(
			groundObj = obj
			if obj.name.count < 25 then
			(
				pickGround.text = obj.name
			)else
			(
				pickGround.text = substring obj.name 1 22 + "..."
			)
		)
	)
	
	groupBox CreateGrpBox "Create" width:160 height:62 offset:[-10,0]
	button mWheel "Make wheel" width:153 height:20 offset:[0,-52]
	button mVehicle "Make vehicle" width:153 height:20 offset:[0,-3]

	function addTexture obj= 
	(
		check = checker()
		check.coords.u_tiling = 6
		check.coords.v_tiling = 1
		
		mat = standardmaterial()
		mat.diffusemap = check
		
		showtexturemap mat mat.diffusemap on
		
		obj.material = mat
	)
	
	function makeCyl =
	(
		wheelObj = cylinder()
		wheelObj.heightSegs = 1
		wheelObj.radius = 20
		wheelObj.height = 15
		wheelObj.wirecolor = yellow
		
		rotate wheelObj (eulerangles 90 0 0)
		rotate wheelObj (eulerangles 0 0 90)
		wheelObj.pivot = wheelObj.center
		wheelObj.pos.z += wheelObj.radius
		wheelObj.pos.x -= wheelObj.height/2.0
		worldalignpivot wheelObj
		wheelObj.name = uniquename "wheel_rig_mesh"
		return wheelObj	
	)
	
	function makeBox=
	(
		wheelObj = box()
		wheelObj.height = 40
		wheelObj.width = 40
		wheelObj.length = 40
		wheelObj.wirecolor = yellow
		
		rotate wheelObj (eulerangles 90 0 0)
		rotate wheelObj (eulerangles 0 0 90)
		wheelObj.pivot = wheelObj.center
		wheelObj.pos.z += wheelObj.height/2.0
		wheelObj.pos.x -= wheelObj.height/2.0
		worldalignpivot wheelObj
		wheelObj.name = uniquename "wheel_rig_mesh"
		return wheelObj
	)

	function makeWheel wheelObj =
	(
		max create mode 
		
		
		p0 = point()
		p0.box = true
		p0.size = (distance wheelObj.max wheelObj.min)/4.0
		p0.transform = wheelObj.transform
		worldalignpivot p0
		wheelObj.parent = p0
		p0.parent = oldParent
		p0.wirecolor = green	
		p0.name = wheelObj.name + "_helper"
		
		select p0
		
		controllerP = box()
		
		controllerP.length = p0.size/4.0
		controllerP.width = p0.size/4.0
		controllerP.height = p0.size/4.0
		addmodifier controllerP (deletemesh())
		controllerP.modifiers[1].enabledinviews = false
		controllerP.pivot = controllerP.center
		controllerP.transform = wheelObj.transform
		worldalignpivot controllerP 
		controllerP.parent = p0
		controllerP.wirecolor = red
		controllerP.name = wheelObj.name + "_controller_MUST_BE_RENDERABLE"
		
		wheelObj.rotation.controller = euler_xyz()
		wheelObj.rotation.controller = rotation_list()
		wheelObj.rotation.controller[2].controller = euler_xyz()
		wheelObj.rotation.controller[3].controller = euler_xyz()
		wheelObj.rotation.controller[4].controller = euler_xyz()
		wheelObj.rotation.controller[4].controller.x_rotation.controller = float_script()
		wheelObj.rotation.controller[4].controller.y_rotation.controller = float_script()
			
		wheelObj.position.controller = position_list()
		wheelObj.position.controller[2].controller = position_xyz()
		wheelObj.position.controller[2].z_position.controller = float_script()
		wheelObj.position.controller.active = 2
		
		
		controllerP.position.controller = position_script()		

			
			
		def=attributes wheel
		
		(
			local distX=0
			local distY=0
			local lastTime=0
	
		)
		
		controllerP.position.controller.addNode "self" wheelObj
		controllerP.position.controller.addNode "parent" p0
		controllerP.position.controller.addConstant "height" (wheelObj.center.z - wheelObj.min.z)
		controllerP.position.controller.addConstant "origHeight" (wheelObj.center.z - wheelObj.min.z)
		controllerP.position.controller.addConstant "radius" (wheelObj.center.z - wheelObj.min.z)
		controllerP.position.controller.AddConstant "compensate" compensateRadius.checked
		controllerP.position.controller.AddNode "ground" groundObj
		
		custAttributes.add controllerP.position.controller def
		
		try
		(
			controllerP.position.controller.addConstant "origRadY" wheelObj.radius
		)catch
		(
			try
			(				
				controllerP.position.controller.addConstant "origRadY" ((wheelObj.length + wheelObj.height)/4.0)				
				
			)catch
			(
				controllerP.position.controller.addConstant "origRadY" (((wheelObj.max.y - wheelObj.min.y ) + (wheelObj.max.z - wheelObj.min.z ))/4.0)					
			)				
		)
		
		scr =
		"
		if not isvalidnode self then return [0,0,0]
		try(
		
			at time f
			(
				scaleAv = (parent.scale.x + parent.scale.y + parent.scale.z)/3.0
				height = origHeight * parent.scale.z
				if f == 0 then
				(
					this.wheel.distX = 0
					this.wheel.distY = 0
					this.wheel.lastTime = 0
				)
				
		
				if compensate then
				(				
				
					theMinZ = 100000;	theMesh = snapshotasmesh self; for v = 1 to theMesh.numverts do 	(in coordsys world (thePos = getVert theMesh v); if thePos.z < theMinZ then theMinZ = thePos.z); delete theMesh; hVal = (self.pivot.z - theMinZ) - height
					radius = (self.pivot.z - theMinZ)
					
				)			
							
				p0=at time (this.wheel.lastTime) parent.pos
				p1=parent.pos
				  
			  newDist=distance p0 p1
			
			  multiX = -(dot parent.transform.row1 (normalize (p1-p0)))/scaleAv
			  multiY = (dot parent.transform.row2 (normalize (p1-p0)))/scaleAv
				
			  this.wheel.distX+=newDist*(360/(2*pi*radius))*multiX
			  this.wheel.distY+=newDist*(360/(2*pi*radius))*multiY
				  
			  this.wheel.lastTime=F
				
				with animate off
				(
					irVal = 0
				
				
				if isvalidnode ground then
				(
											
						if iskindof ground geometryClass then
						(
							r = ray [parent.position.x, parent.position.y, 100000]  [0,0,-1]
							iR = intersectray ground r
							if iR != undefined then
							(
								irVal = iR.position.z + height
							)else
							(
								irVal = ground.center.z + height
							)
							parent.position.z = irVal
						)
						
					
				)
			
				"
				
				if RType.state == 1 then
				(
					
					scr += "
					self.rotation.controller[4].x_rotation.controller.script = (-degToRad this.wheel.distY) as string
					"
				)
				if RType.state == 2 then
				(
					
					scr += "
					self.rotation.controller[4].y_rotation.controller.script = (-degToRad this.wheel.distX) as string
					"
				)
				
				scr += "
				if compensate then
				(
					
					theMinZ = 100000;	theMesh = snapshotasmesh self; for v = 1 to theMesh.numverts do 	(in coordsys world (thePos = getVert theMesh v); if thePos.z < theMinZ then theMinZ = thePos.z); delete theMesh; hVal = (self.pivot.z - theMinZ) - height
					self.position.controller[2].z_position.controller.script = (hVal/parent.scale.z) as string
					
				)
				
				
				
				
				)
			)
			[0,0,0]
		)catch(print (\"Wheel rig script error:\" + GetCurrentException());[0,0,0])
		"
				
				controllerP.position.controller.script = scr
		return #(p0, controllerP)
	)

	
	on mWheel pressed do
	(
		with animate off
		(
			if wheelType.state == 1 then
			(
				cyl = makeCyl()
				addTexture cyl
				makeWheel cyl
				
			)else if wheelType.state == 2 then
			(
				bx = makeBox()
				addTexture bx
				makeWheel bx
			)
		)
	)
	
	function makeCarHelper =
	(
		knotArr = #(#([-40.7992,-95.4784,10.6722],[-40.7992,-67.1788,10.6722],[40.7992,-67.1788,10.6722],[40.7992,-95.4784,10.6722],[-40.7992,-95.4784,10.6722],[-40.7992,-95.4784,42.0961],[40.7992,-95.4784,42.0961],[40.7992,-67.1788,46.8547],[-40.7992,-67.1788,46.8547],[-40.7992,-95.4784,42.0961]),#([-40.7992,-67.1788,10.6722],[-40.7992,-38.0938,10.6722],[40.7992,-38.0938,10.6722],[40.7992,-67.1788,10.6722],[40.7992,-67.1788,46.8547],[40.7992,-38.0938,78.8986],[-40.7992,-38.0938,78.8986],[-40.7992,-67.1788,46.8547]),#([-40.7992,-38.0938,10.6722],[-40.7992,95.4784,10.6722],[40.7992,95.4784,10.6722],[40.7992,-38.0938,10.6722],[40.7992,-38.0938,78.8986],[40.7992,63.8583,80.0882],[-40.7992,63.8583,80.0882],[-40.7992,-38.0938,78.8986]),#([40.7992,-95.4784,10.6722],[40.7992,-95.4784,42.0961]),#([40.7992,95.4784,10.6722],[40.7992,63.8583,80.0882]),#([-40.7992,95.4784,10.6722],[-40.7992,63.8583,80.0882]))
			
			spl = splineshape()
			for q in 1 to knotArr.count do
			(
				addnewspline spl
				
				for g in 1 to knotArr[q].count do
				(
					addknot spl q #corner #curve knotArr[q][g]
				)
			)
			
			updateshape spl
			spl.wirecolor = green
			spl
	)
	
	on mVehicle pressed do
	(
		with animate off
		(
			cName = uniquename "carRig"
			root = point()
			root.box = false
			root.pos.z = 20
			root.wirecolor = yellow
			root.name = cName + "_root"
			
			carBody = makeCarHelper()
			--carBody.width = 50
			--carBody.length = 90
			carBody.pivot.z += 5
			carBody.pos.z = 20
			carBody.parent = root
			carBody.wirecolor = green
			carBody.name = cName + "_body"
			
			wheels = #()
			wheels_tire = #()
			wheels_controllers = #()
			
			for q in 1 to 4 do
			(
					if wheelType.state == 1 then
					(
						wheel = makeCyl()			
						
					)else if wheelType.state == 2 then
					(
						wheel = makeBox()				
					)
			
				addTexture wheel
				wheel.name = cName + "_" + wheel.name
				wArr = makeWheel wheel
				w = wArr[1]
				wCP = wArr[2]
				w.parent = root
				
				cWidth = abs (carBody.max.x - carBody.min.x)
				cLength = abs (carBody.max.y - carBody.min.y)
					
				if q == 1 then w.pos.x = -cWidth/2.25
				if q == 2 then w.pos.x = cWidth/2.25
				if q == 3 then w.pos.x = -cWidth/2.25
				if q == 4 then w.pos.x = cWidth/2.25
					
				if q == 1 then w.pos.y = cLength/2.75
				if q == 2 then w.pos.y = cLength/2.75
				if q == 3 then w.pos.y = -cLength/2.75
				if q == 4 then w.pos.y = -cLength/2.75
					
				w.name = cName + "_wheel_" + (q as string)
				append wheels w
				append wheels_tire wheel
				append wheels_controllers wCP
					
			)
			
			rearAxle = point()
			frontAxle = point()
			rearLookat = point()
			frontLookat = point()
			rearAxleLookat = point()
			frontAxleLookat = point()
			rearAxle.box = false
			frontAxle.box = false
			rearLookat.box = false
			frontLookat.box = false
			frontAxleLookat.box = true
			rearAxleLookat.box = true
			
			
			rearAxle.wirecolor = yellow
			frontAxle.wirecolor = yellow
			rearLookat.wirecolor = green
			frontLookat.wirecolor = green
			rearAxleLookat.wirecolor = yellow
			frontAxleLookat.wirecolor = yellow
			
			--root.pivot = (wheels[1].pos + wheels[2].pos)/2.0
			rearAxle.parent = root
			frontAxle.parent = root
			rearLookat.parent = rearAxle
			frontLookat.parent = frontAxle
			frontAxleLookat.parent = root
			rearAxleLookat.parent = root
			
			rearAxle.size = root.size/2.0
			frontAxle.size = root.size/2.0
			rearLookat.size = root.size
			frontLookat.size = root.size
			rearAxleLookat.size = root.size
			frontAxleLookat.size = root.size
			
			rearAxle.name = cName + "_rear_axle"
			frontAxle.name = cName + "_front_axle"
			rearLookat.name = cName + "_rear_lookat"
			frontLookat.name = cName + "_front_lookat"
			rearAxleLookat.name = cName + "_rear_axle_lookat"
			frontAxleLookat.name = cName + "_front_axle_lookat"
			
			rearAxle.position.controller = position_constraint()
			frontAxle.position.controller = position_constraint()
			rearAxleLookat.position.controller = position_constraint()
			frontAxleLookat.position.controller = position_constraint()
			
			rearAxle.position.controller.appendTarget wheels_tire[1] 1
			rearAxle.position.controller.appendTarget wheels_tire[2] 1
			
			frontAxle.position.controller.appendTarget wheels_tire[3] 1
			frontAxle.position.controller.appendTarget wheels_tire[4] 1
			
			rearAxleLookat.position.controller.appendTarget wheels[1] 1
			rearAxleLookat.position.controller.appendTarget wheels[2] 1
			
			frontAxleLookat.position.controller.appendTarget wheels[3] 1
			frontAxleLookat.position.controller.appendTarget wheels[4] 1
						
			rearAxle.rotation.controller = lookat_constraint()
			frontAxle.rotation.controller = lookat_constraint()
			rearAxleLookat.rotation.controller = lookat_constraint()
			frontAxleLookat.rotation.controller = lookat_constraint()
			
			rearAxle.rotation.controller.appendTarget wheels_tire[1] 1
			frontAxle.rotation.controller.appendTarget wheels_tire[3] 1
			
			rearAxleLookat.rotation.controller.appendTarget wheels[1] 1
			frontAxleLookat.rotation.controller.appendTarget wheels[3] 1
						
			rearAxle.rotation.controller.lookat_vector_length = 0
			frontAxle.rotation.controller.lookat_vector_length = 0
			rearAxleLookat.rotation.controller.lookat_vector_length = 0
			frontAxleLookat.rotation.controller.lookat_vector_length = 0
			
			rearAxle.rotation.controller.pickUpNode = root
			frontAxle.rotation.controller.pickUpNode = root
			
			rearAxle.rotation.controller.upnode_world = false
			frontAxle.rotation.controller.upnode_world = false
			
			rearAxleLookat.rotation.controller.pickUpNode = root
			frontAxleLookat.rotation.controller.pickUpNode = root
			
			rearAxleLookat.rotation.controller.upnode_world = false
			frontAxleLookat.rotation.controller.upnode_world = false
			
			
			carBody.position.controller = position_constraint()
			carBody.position.controller.appendTarget wheels_tire[1] 1
			carBody.position.controller.appendTarget wheels_tire[2] 1
			carBody.position.controller.appendTarget wheels_tire[3] 1
			carBody.position.controller.appendTarget wheels_tire[4] 1
			
			carBody.position.controller = position_list()
			carBody.position.controller[2].controller = position_xyz()
			carBody.position.controller.active = 2
			
			rearLookat.rotation.controller = lookat_constraint()
			rearLookat.rotation.controller.lookat_vector_length = 0
			rearLookat.rotation.controller.appendTarget frontAxle 1
			rearLookat.rotation.controller.pickUpNode = wheels_tire[1]
			rearLookat.rotation.controller.target_axis = 1
			rearLookat.rotation.controller.upnode_world = false
			rearLookat.rotation.controller.upnode_ctrl = 0
			
			frontLookat.rotation.controller = lookat_constraint()
			frontLookat.rotation.controller.lookat_vector_length = 0
			frontLookat.rotation.controller.appendTarget rearAxle 1
			frontLookat.rotation.controller.pickUpNode = wheels_tire[4]
			frontLookat.rotation.controller.target_axisflip = true
			frontLookat.rotation.controller.StoUP_axis = 2
			frontLookat.rotation.controller.upnode_world = false
			frontLookat.rotation.controller.upnode_ctrl = 0
			
			carBody.rotation.controller = orientation_constraint()
			carBody.rotation.controller.relative = true
			carBody.rotation.controller.appendTarget rearLookat 1
			carBody.rotation.controller.appendTarget frontLookat 1
			
			carBody.rotation.controller = rotation_list()
			carBody.rotation.controller[2].controller = euler_xyz()
			carBody.rotation.controller.active = 2
			
			steeringControl = dummy()
			steeringControl.scale *= 2
			resetscale steeringControl
			
			steeringControl.parent = root
			steeringControl.position = frontLookat.position
			steeringControl.position.z += 60
			steeringControl.position.y -= 10
			steeringControl.name = cName + "_steering_control"
			
			steeringControl.rotation.controller = rotation_list()
			steeringControl.rotation.controller[2].controller = euler_xyz()
			steeringControl.rotation.controller[3].controller = euler_xyz()
			steeringControl.rotation.controller[4].controller = euler_xyz()
			steeringControl.rotation.controller.active = 4
			steeringControl.rotation.controller[4].controller.x_rotation.controller = float_script()
			steeringControl.rotation.controller[4].controller.y_rotation.controller = float_script()
			
			wheels[3].rotation.controller = rotation_list()
			wheels[3].rotation.controller[2].controller = euler_xyz()
			wheels[3].rotation.controller[3].controller = euler_xyz()
			wheels[3].rotation.controller.active = 3
			
			wheels[4].rotation.controller = rotation_list()
			wheels[4].rotation.controller[2].controller = euler_xyz()
			wheels[4].rotation.controller[3].controller = euler_xyz()
			wheels[4].rotation.controller.active = 3
						
			
			paramWire.connect2Way steeringControl.rotation.controller[3].controller[3] wheels_tire[3].rotation.controller[2].controller[3] "Z_Rotation" "Z_Rotation"
			paramWire.connect2Way steeringControl.rotation.controller[3].controller[3] wheels_tire[4].rotation.controller[2].controller[3] "Z_Rotation" "Z_Rotation"
			
			paramWire.connect2Way steeringControl.rotation.controller[3].controller[3] wheels[3].rotation.controller[2].controller[3] "Z_Rotation" "Z_Rotation"
			paramWire.connect2Way steeringControl.rotation.controller[3].controller[3] wheels[4].rotation.controller[2].controller[3] "Z_Rotation" "Z_Rotation"
			
			
			
			
			paramWire.connect2Way steeringControl.rotation.controller[4].controller[3] wheels_tire[3].rotation.controller[3].controller[3] "Z_Rotation" "Z_Rotation"
			paramWire.connect2Way steeringControl.rotation.controller[4].controller[3] wheels_tire[4].rotation.controller[3].controller[3] "Z_Rotation" "Z_Rotation"
			
			paramWire.connect2Way steeringControl.rotation.controller[4].controller[3] wheels[3].rotation.controller[3].controller[3] "Z_Rotation" "Z_Rotation"
			paramWire.connect2Way steeringControl.rotation.controller[4].controller[3] wheels[4].rotation.controller[3].controller[3] "Z_Rotation" "Z_Rotation"
			
			wheels_tire[3].rotation.controller[3].controller = euler_xyz()
			wheels_tire[4].rotation.controller[3].controller = euler_xyz()
			
			wheels_tire[3].rotation.controller.active = 3
			wheels_tire[4].rotation.controller.active = 3

			for q in 1 to 4 do
			(
				wheels_tire[q].rotation.controller[1].controller = orientation_constraint()
				wheels_tire[q].rotation.controller[1].controller.relative = true
				if q == 1 or q == 2 then
				(
					wheels_tire[q].rotation.controller[1].controller.appendTarget rearAxleLookat 1 
				)else
				(
					wheels_tire[q].rotation.controller[1].controller.appendTarget frontAxleLookat 1 
				)
			)
			
			addmodifier root (emptymodifier())
			
			wheelGroundCA = attributes "wheelGround"
			(
				local wheelArr = #()
				local thisObj = undefined
				local autoSteer = true
				local groundName = "Pick Ground"
				
				function objFilter obj =
				(
					myChildren = #(thisObj)
					i = 0
					while i < myChildren.count do
					(
						i += 1
						join myChildren myChildren[i].children
					)
					
					for q in 1 to myChildren.count do
					(
						if obj == myChildren[q] then return false
					)
					
					return true

					
				)
				rollout params "Car Parameters"
				(
					group "Wheels"
					(
						checkbox aSteer "Auto Steer" checked:true align:#center
					)
					
					group "Ground"
					(
						pickbutton pickGround "Pick Ground" width:110 align:#left
						button removeGround "X" width:23 height:20 offset:[58,-26]
					)
					
					on aSteer changed val do
					(
						autoSteer = val
					)
						
					on pickGround picked obj do
					(
						if isvalidnode obj then
						(
							if iskindof obj geometryclass then
							(
								if obj.name.count < 18 then
								(
									groundName = obj.name
								)else
								(
									groundName = substring obj.name 1 15 + "..."
								)
								
								pickGround.text = groundName
								for q in 1 to wheelArr.count do
								(
									try(wheelArr[q].position.controller.SetNode "ground" obj)catch(wheelArr[q].position.controller.addNode "ground" obj)
									wheelArr[q].position.controller.script = wheelArr[q].position.controller.script
									
								)
							)
						)
					)
					
					on removeGround pressed do
					(
						groundName = "Pick Ground"
						pickGround.text = groundName
						
						for q in 1 to wheelArr.count do
						(
							p = plane()
							try(wheelArr[q].position.controller.SetNode "ground" p)catch(wheelArr[q].position.controller.addNode "ground" p)
							wheelArr[q].position.controller.script = wheelArr[q].position.controller.script							
							wheelArr[q].position.controller.deleteVariable "ground" 
							wheelArr[q].position.controller.script = wheelArr[q].position.controller.script
							delete p
						)
					)
					on params open do
					(
						pickGround.text = groundName
					)
				)
			)
			
			custAttributes.add root.modifiers[1] wheelGroundCA
			root.modifiers[1].wheelGround.thisObj = root
			root.modifiers[1].name = "Wheel Control"
			
			if isvalidnode groundObj then
			(
				if groundObj.name.count < 18 then
				(
					root.modifiers[1].wheelGround.groundName = groundObj.name
				)else
				(
					root.modifiers[1].wheelGround.groundName = substring groundObj.name 1 15 + "..."
				)
				
				root.modifiers[1].wheelGround.params.pickGround.text = root.modifiers[1].wheelGround.groundName
			)
			
			
			for q in 1 to 4 do
			(
				append root.modifiers[1].wheelGround.wheelArr wheels_controllers[q]
				
			)
		
			steeringControl.rotation.controller[2].controller = rotation_script()
			steeringControl.rotation.controller[2].controller.addNode "self" steeringControl
			steeringControl.rotation.controller[2].controller.addNode "root" root
			steeringControl.rotation.controller[2].controller.script = 
			"
				if not isvalidnode self then return (quat 0 0 0 1)
				aSteer = false
				try
				(
					aSteer = root.modifiers[1].wheelGround.autoSteer
				)catch()
				
				with animate off
				(
					
					if aSteer then
					(
					
						v1 = root.transform.row2
						p1 = self.position
						at time (f + 1)
						(
							p2 = self.position
						)at time (f + 2)
						(
							p2 += self.position
						)at time (f + 3)
						(
							p2 += self.position
						)
						
						p2 = p2/3.0
						
						v2 = p1 - p2
						v2 += v1*.001
					
						v1[3] = 0
						v2[3] = 0
						
						v1Perp = [-v1[2],v1[1],0]	
						dot1 = dot (normalize v1Perp) (normalize v2)
						dot2 = dot (normalize v1) (normalize v2)	
						ang = atan2 dot1 dot2
						
						self.rotation.controller[3].value = eulertoquat (eulerangles 0 0 (ang))
					
					)else
					(
						self.rotation.controller[3].value = eulertoquat (eulerangles 0 0 0)
					)
				)
				quat 0 0 0 1
			"
			
			select root
		)
		
	)

)
AddSubRollout MakeToolbox.theSubrollout WheelMakerModule
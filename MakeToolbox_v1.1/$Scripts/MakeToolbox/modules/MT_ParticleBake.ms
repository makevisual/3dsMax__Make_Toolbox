/*
#NAME:Particle Bake
#VERSION:1.1
#INSTRUCTIONS:
Bakes a set of fragment meshes to the particles in a particle flow.
http://www.makevisual.com/learning/MT_ParticleBake.htm
#SOURCE:Mike Zugschwert, m.zugschwert@gmail.com
#HISTORY:04.13.2012 >> Updated to include point and mesh generation, will automatically duplicate any geometry in the geometry list to reach total particle count. Also added keys for visibility and scale to the baked geometry.
03.12.2012 >> Integrated to MakeToolbox	
10.12.2011 >> Release
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Mike Zugschwert, m.zugschwert@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 10.12.2011 >> Release
--- version 1.1 : 03.12.2012  >> Integrated to MakeToolbox	
--*****************************************************
ParticleBakeToGeometryModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout ParticleBakeToGeometryModule)catch()

global fragArrayNames = #()
global fragArray = #()

rollout ParticleBakeToGeometryModule ("Particle Bake")/* + (ParticleBakeToGeometryModuleVer as string))*/
(
	checkbox chk_Points "Points" align:#left offset:[0,0]
	checkbox chk_GenMesh "Generate Mesh" align:#left offset:[0,0] checked: true
	checkbox chk_GeoList "Geometry List" align:#left offset:[0,0]
	
	
	groupBox Fragments "Geometry List:" width:160 height:150 offset:[-10,0] enabled: false
	MultiListBox FragListBox width:148 height:6 items:fragArrayNames  offset:[-5,-136] enabled: false
	button chooseFragments "Select" width: 146 height:20 tooltip: "Add fragments." offset:[0,-3] enabled: false
	radiobuttons obj_type labels:#("Copy    ", "Instance") align:#center offset:[0,0] enabled: false
	
	button bakeButton "Bake" width:159 height:20 tooltip: "Bake the particles to geometry." offset:[0,4]
	
	on chk_GeoList changed theState do 
		(
			if chk_GeoList.checked == true then
				(
					chk_GenMesh.checked = false
					Fragments.enabled = true
					FragListBox.enabled = true
					chooseFragments.enabled = true
					obj_type.enabled = true
					bakeButton.enabled = true
				)
			else 
				(
					Fragments.enabled = false
					FragListBox.enabled = false
					chooseFragments.enabled = false
					obj_type.enabled = false
				)
			if (chk_GeoList.checked == false) and (chk_GenMesh.checked == false) and (chk_points.checked == false) then
				(
					bakeButton.enabled = false
				)
			if fragArrayNames.count < 1 then
				(
					bakeButton.enabled = false
				)
		)
	
	on chk_GenMesh changed theState do 
		(
			if chk_GenMesh.checked == true then
				(
					chk_GeoList.checked = false
					Fragments.enabled = false
					FragListBox.enabled = false
					chooseFragments.enabled = false
					obj_type.enabled = false
					bakeButton.enabled = true
				)
			if (chk_GeoList.checked == false) and (chk_GenMesh.checked == false) and (chk_points.checked == false) then
				(
					bakeButton.enabled = false
				)
		)
		
	on chk_points changed theState do 
		(
			if chk_points.checked == true then
				(
					bakeButton.enabled = true
				)
			if (chk_GeoList.checked == false) and (chk_GenMesh.checked == false) and (chk_points.checked == false) then
				(
					bakeButton.enabled = false
				)
		)
		
	on chooseFragments pressed do
		(
			fn fragmentsfilter fragments = iskindof fragments GeometryClass
			
			fragArray = selectByName title: "Select Fragments" filter:fragmentsfilter
			if fragArray != undefined do
				(
					fragArrayNames = #()
					for i in 1 to (fragArray.count) do
						(
							fragArrayNames[i] = fragArray[i].name
						)
					FragListBox.items = fragArrayNames
					)
					
			if fragArrayNames.count < 1 then
				(
					bakeButton.enabled = false
				)
			else
				(
					bakeButton.enabled = true
				)
				
		)
		
	on bakeButton pressed do
		(
			bakedArray = #()
			pointArray = #()
			particleArray = #()
			thePflow = $
			if (iskindof thePflow PF_Source) then
				(			
					if chk_GenMesh.checked == true then
						(
							bakedLayer = layermanager.getLayerFromName ("baked_Objects__"+thePflow.name as string)
							if bakedLayer == undefined then (bakedLayer = layermanager.newLayerFromName ("baked_Objects__"+thePflow.name as string))
							if chk_points.checked == true then 
								(	
									pointLayer = layermanager.getLayerFromName ("baked_Points__"+thePflow.name as string)
									if pointLayer == undefined then (pointLayer = layermanager.newLayerFromName ("baked_Points__"+thePflow.name as string))
								)
								
							for t = animationRange.start to animationRange.end do --loop through animation segment
								(
									sliderTime = t --set the slider time to the time value
									theCount = ThePflow.numParticles() --get the number of particles in the whole flow
									for p = 1 to theCount do --loop through all the particles
										(	
											ThePflow.particleIndex = p --set the p-th particle as active -- now with more ID!
											if (particleArray[ThePflow.particleID] == undefined) then
												(
													theTMesh = ThePflow.getparticleshapebyid ThePflow.particleID
													theNewMesh = Editable_mesh() --create an empty EMesh
													theNewMesh.mesh = theTMesh --assign TriMesh value to the EMesh
													convertTo theNewMesh Editable_Poly --collapse to EPoly
													theNewMesh.name = "baked_"+(ThePflow.particleID as string)
													bakedArray[ThePflow.particleID] = theNewMesh
													bakedLayer.addNode bakedArray[ThePflow.particleID]
													particleArray[ThePflow.particleID] = #((ThePflow.getParticleGroup p).name, true)
													bakedArray[ThePflow.particleID].name = "baked_"+(ThePflow.particleID as string)+"_"+(ThePFlow.getParticleGroup p).name as string
													bakedLayer.addNode bakedArray[ThePflow.particleID]
													if t == 0 then
														(
															with animate on
																(
																	at time 1 bakedArray[ThePflow.particleID].visibility = on
																	at time 1 bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)
													else
														(
															with animate on
																(
																	at time (t-1) bakedArray[ThePflow.particleID].visibility = off
																	at time (t-2) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
																	at time t bakedArray[ThePflow.particleID].visibility = on
																	at time (t-1) bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)		
													
													if chk_points.checked == true then 
														(
															newPoint = point()
															newPoint.name = "point_"+(ThePflow.particleID as string)
															newPoint.wirecolor = green
															pointArray[ThePflow.particleID] = newPoint
															pointLayer.addNode pointArray[ThePflow.particleID]
															bakedArray[ThePflow.particleID].transform = pointArray[ThePflow.particleID].transform
															bakedArray[ThePflow.particleID].parent =  pointArray[ThePflow.particleID]
														)
												)
												
											if (particleArray[ThePflow.particleID][1] != (ThePflow.getParticleGroup p).name ) then
												(
													particleArray[ThePflow.particleID][1] = (ThePflow.getParticleGroup p).name
													--print ("New event for "+ThePflow.particleID as string+" at frame "+t as string )
													
													if t == 0 then
														(
															with animate on
																(
																	at time 1 bakedArray[ThePflow.particleID].visibility = off
																	at time 1 bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
																)
														)
													else
														(
															with animate on
																(
																	at time t bakedArray[ThePflow.particleID].visibility = off
																	at time (t+1) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
																	at time (t-1) bakedArray[ThePflow.particleID].visibility = on
																	at time t bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)	
													
													theTMesh = ThePflow.getparticleshapebyid ThePflow.particleID
													theNewMesh = Editable_mesh() --create an empty EMesh
													theNewMesh.mesh = theTMesh --assign TriMesh value to the EMesh
													convertTo theNewMesh Editable_Poly --collapse to EPoly
													theNewMesh.name = "baked_"+(ThePflow.particleID as string)+"_"+(ThePFlow.getParticleGroup p).name as string
													bakedArray[ThePflow.particleID] = theNewMesh
													bakedLayer.addNode bakedArray[ThePflow.particleID]
													particleArray[ThePflow.particleID][1] = (ThePflow.getParticleGroup p).name
													bakedArray[ThePflow.particleID].name = "baked_"+(ThePflow.particleID as string)+"_"+(ThePFlow.getParticleGroup p).name as string
													bakedLayer.addNode bakedArray[ThePflow.particleID]
													
													if t == 0 then
														(
															with animate on
																(
																	at time 1 bakedArray[ThePflow.particleID].visibility = on
																	at time 1 bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)
													else
														(
															with animate on
																(
																	at time (t-1) bakedArray[ThePflow.particleID].visibility = off
																	at time (t-2) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
																	at time t bakedArray[ThePflow.particleID].visibility = on
																	at time (t-1) bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)															
													
													if chk_points.checked == true then 
														(
															bakedArray[ThePflow.particleID].transform = pointArray[ThePflow.particleID].transform
															bakedArray[ThePflow.particleID].parent =  pointArray[ThePflow.particleID]
														)
												)
												
											if chk_points.checked == true then 
												(	
													if p <= bakedArray.count do
													with animate on pointArray[ThePflow.particleID].transform = ThePflow.particleTM
												) 
											else
												(
													if p <= bakedArray.count do
													with animate on bakedArray[ThePflow.particleID].transform = ThePflow.particleTM
												)
												
										)--end p loop
									for p = 1 to particleArray.count do
										(
											ThePflow.particleID = p
											if (thePflow.particleIndex == 0) and (particleArray[p][2] == true) then 
											(
												particleArray[p][2] = false
												with animate on
													(
														at time t bakedArray[ThePflow.particleID].visibility = off
														at time (t-1) bakedArray[ThePflow.particleID].visibility = on
														
														at time (t+1) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
														at time t bakedArray[ThePflow.particleID].scale = [1,1,1]
													)													
											)
										)
								)--end t loop
								
							bakedLayer.nodes &layerNodesArray
							for x in 1 to layerNodesArray.count do --remove keyframe at frame 0
								(
									selectKeys layerNodesArray[x] 0
									deleteKeys layerNodesArray[x] #selection
								)
								
							if chk_points.checked == true then
								(
									pointLayer.nodes &layerNodesArray
									for x in 1 to layerNodesArray.count do --remove keyframe at frame 0
										(
											selectKeys layerNodesArray[x] 0
											deleteKeys layerNodesArray[x] #selection
										)
								)
						)
						
					if chk_GeoList.checked == true then
						(
							bakedLayer = layermanager.getLayerFromName ("baked_Objects__"+thePflow.name as string)
							if bakedLayer == undefined then (bakedLayer = layermanager.newLayerFromName ("baked_Objects__"+thePflow.name as string))
							if chk_points.checked == true then 
								(	
									pointLayer = layermanager.getLayerFromName ("baked_Points__"+thePflow.name as string)
									if pointLayer == undefined then (pointLayer = layermanager.newLayerFromName ("baked_Points__"+thePflow.name as string))
								)
							v = 1
								
							for t = animationRange.start to animationRange.end do --loop through animation segment
								(
									sliderTime = t --set the slider time to the time value
									theCount = ThePflow.numParticles() --get the number of particles in the whole flow
									for p = 1 to theCount do --loop through all the particles
										(	
											ThePflow.particleIndex = p --set the p-th particle as active -- now with more ID!
											if (particleArray[ThePflow.particleID] == undefined) then
												(
													if obj_type.state == 1 then
														(
															bakedArray[ThePflow.particleID] = copy fragArray[v]
														)
													else
														(
															bakedArray[ThePflow.particleID] = instance fragArray[v]
														)
														
													particleArray[ThePflow.particleID] = #((ThePflow.getParticleGroup p).name, true)
													bakedArray[ThePflow.particleID].name = "baked_"+(ThePflow.particleID as string)+"_"+fragArray[v].name
													bakedLayer.addNode bakedArray[ThePflow.particleID]	
													if t == 0 then
														(
															with animate on
																(
																	at time 1 bakedArray[ThePflow.particleID].visibility = on
																	at time 1 bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)
													else
														(
															with animate on
																(
																	at time (t-1) bakedArray[ThePflow.particleID].visibility = off
																	at time (t-2) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
																	at time t bakedArray[ThePflow.particleID].visibility = on
																	at time (t-1) bakedArray[ThePflow.particleID].scale = [1,1,1]
																)
														)																
														
													if chk_points.checked == true then 
														(
															newPoint = point()
															newPoint.name = "point_"+(ThePflow.particleID as string)+"_"+fragArray[v].name
															newPoint.wirecolor = green
															pointArray[ThePflow.particleID] = newPoint
															pointLayer.addNode pointArray[ThePflow.particleID]
															bakedArray[ThePflow.particleID].transform = pointArray[ThePflow.particleID].transform
															bakedArray[ThePflow.particleID].parent =  pointArray[ThePflow.particleID]
														)
													if v<fragArray.count then (v = v+1) else (v = 1)
												)
												
											if chk_points.checked == true then 
												(	
													if p <= bakedArray.count do
													with animate on pointArray[ThePflow.particleID].transform = ThePflow.particleTM
												) 
											else
												(
													if p <= bakedArray.count do
													with animate on bakedArray[ThePflow.particleID].transform = ThePflow.particleTM
												)
										)--end p loop
									for p = 1 to particleArray.count do
										(
											ThePflow.particleID = p
											if (thePflow.particleIndex == 0) and (particleArray[p][2] == true) then 
											(
												particleArray[p][2] = false
												with animate on
													(
														at time t bakedArray[ThePflow.particleID].visibility = off
														at time (t+1) bakedArray[ThePflow.particleID].scale = [.0001,.0001,.0001]
														at time (t-1) bakedArray[ThePflow.particleID].visibility = on
														at time t bakedArray[ThePflow.particleID].scale = [1,1,1]
													)												
												
											)
										)										
								)--end t loop
								
							print particleArray
							for x in 1 to bakedArray.count do --remove keyframe at frame 0
							(
								selectKeys bakedArray[x] 0
								deleteKeys bakedArray[x] #selection
								if chk_points.checked == true then 
									(
										selectKeys pointArray[x] 0
										deleteKeys pointArray[x] #selection
									)
							)
						)
						
					if (chk_GeoList.checked == false) and (chk_GenMesh.checked == false) and (chk_points.checked == true) then
						(
							pointLayer = layermanager.getLayerFromName ("baked_Points__"+thePflow.name as string)
							if pointLayer == undefined then (pointLayer = layermanager.newLayerFromName ("baked_Points__"+thePflow.name as string))
								
							for t = animationRange.start to animationRange.end do --loop through animation segment
								(
									sliderTime = t --set the slider time to the time value
									theCount = ThePflow.numParticles() --get the number of particles in the whole flow
									for p = 1 to theCount do --loop through all the particles
										(	
											ThePflow.particleIndex = p --set the p-th particle as active -- now with more ID!
											if (particleArray[ThePflow.particleID] == undefined) then
												(
													newPoint = point()
													newPoint.name = "point_"+(ThePflow.particleID as string)
													newPoint.wirecolor = green
													pointArray[ThePflow.particleID] = newPoint
													particleArray[ThePflow.particleID] = #((ThePflow.getParticleGroup p).name)
													pointLayer.addNode pointArray[ThePflow.particleID]
												)
												
											if p <= pointArray.count do
											with animate on pointArray[ThePflow.particleID].transform = ThePflow.particleTM
										)--end p loop
								)--end t loop
								
							for x in 1 to pointArray.count do --remove keyframe at frame 0
							(
								selectKeys pointArray[x] 0
								deleteKeys pointArray[x] #selection
							)
						)
				)else(messagebox("Please select a pFlow object."))
		)
)
AddSubRollout MakeToolbox.theSubrollout ParticleBakeToGeometryModule
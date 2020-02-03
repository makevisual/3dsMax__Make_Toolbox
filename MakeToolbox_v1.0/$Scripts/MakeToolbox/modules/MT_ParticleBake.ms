/*
#NAME:Particle Bake
#VERSION:1.1
#INSTRUCTIONS:
Bakes a set of fragment meshes to the particles in a particle flow.
http://www.makevisual.com/learning/MT_ParticleBake.htm
#SOURCE:Mike Zugschwert, m.zugschwert@gmail.com
#HISTORY:03.12.2012 >> Integrated to MakeToolbox	
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
global TheSystem = undefined
global ThePflow = undefined

rollout ParticleBakeToGeometryModule ("Particle Bake")/* + (ParticleBakeToGeometryModuleVer as string))*/
(
	button choosePflow "Select Particle Source" width:160 height:20 tooltip: "Select the pFlow system you would like to bake." offset:[0,-5]
	
	groupBox Fragments "Fragments Objects :" width:160 height:180 offset:[-10,-4]
	MultiListBox FragListBox width:148 height:10 items:fragArrayNames  offset:[-5,-168]
	button chooseFragments "Add" width: 146 height:20 tooltip: "Add fragments." offset:[0,-3]
	
	button bakeButton "Bake" width:159 height:20 tooltip: "Bake the particles to geometry." offset:[0,2]
	
	on choosePflow pressed do
		(
			
			fn pflowfilter pflow = iskindof pflow PF_Source
				
			ThePflow = selectByName title: "Select pFlow" single: true filter:pflowfilter
			if ThePflow != undefined do
				(
					choosePflow.text = ThePflow.name
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
		)
		
	on bakeButton pressed do
		(
			theSystem = ThePflow
			theArray = fragArray
			for t = animationRange.start to animationRange.end do --loop through animation segment
				(
					sliderTime = t --set the slider time to the time value
					theCount = theSystem.numParticles() --get the number of particles in the whole flow
					for p = 1 to theCount do --loop through all the particles
						(
							theSystem.particleID = p --set the p-th particle as active -- now with more ID!
							if p <= theArray.count do  --if the particle index is less than the number of boxes,
							with animate on theArray[p].transform = theSystem.particleTM --set the transformation of the p-th box to the matrix of the p-th particle
						)--end p loop
				)--end t loop
		--choosePflow.text = "Select Particle Source"
		)
)
AddSubRollout MakeToolbox.theSubrollout ParticleBakeToGeometryModule
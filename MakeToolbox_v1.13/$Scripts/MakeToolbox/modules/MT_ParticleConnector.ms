/*
#NAME:Particle Connector
#VERSION:1.0
#INSTRUCTIONS:
Connects particles together into an animated mesh.
Used in 'Minnkota Talon' spot
http://www.makevisual.com/learning/MT_ParticleConnector.htm
#SOURCE:Tyson Ibele http://www.tysonibele.com
#HISTORY:03.12.2012  >> Integrated to MakeToolbox	
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Tyson Ibele, tysonibele@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Integrated to MakeToolbox						  
--*****************************************************
ParticleConnectorModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout ParticleConnectorModule)catch()

	
rollout ParticleConnectorModule ("Particle Connector")
(
	local pflow = undefined
	local eNames = #()
	pickbutton getPFlow "Select Particle Flow" width:160 offset:[0,0]
	
	groupbox events "Events (Select to Exclude)" width:160 height:130 offset:[-10,0]
	multilistbox excludeEvents "" height:8 offset:[-5, -120] width:148
	
	groupbox timeRange "Time Range" width:160 height:40 offset:[-10, 0]
	spinner tStart "" type:#integer align:#left width:65 range:[-100000,100000,0] offset:[-7,-27]
	spinner tEnd "  to  " type:#integer align:#left width:78 range:[-100000,100000,100] offset:[62,-20]
	
	groupbox settings "Settings" width:160 height:120 offset:[-10,0]
	spinner dThresh "Dist Thresh:          " type:#float range:[.1, 1000, 7] align:#left width:135 offset:[-5, -110]
	spinner tThresh "Trans. Thresh:      " type:#float range:[.1, 1000, 8] align:#left width:134 offset:[-5,0]
	spinner wThick "Wire thick:             " type:#float range:[.001, 10, .015] align:#left width:132 offset:[-5,0]
	spinner maxConn "Max Connections: " width:135 align:#left type:#integer range:[1, 50, 5] offset:[-5,0]
	edittext nPrefix "Name:" offset:[-5,0] width:150 text:"wire_"

	groupbox gen "" width:160 height:63 offset:[-10, 0]
	button generate "Generate" width:153 height:20 offset:[0,-58]
	progressbar prog2 "" width:150 height:7 align:#center color:yellow
	progressbar prog1 "" width:150 height:15 align:#center color:blue offset:[0,-3]
	
	fn DisableProcessWindowsGhosting =
	(
			
	   -- if classof (dotnet.GetType "DisableWindowsGhosting")!=dotNetObject then
	  --  (
			local source = StringStream ("using System.Runtime.InteropServices; public class DisableWindowsGhosting{ [DllImport(\"user32.dll\")]  public static extern bool DisableProcessWindowsGhosting();  }")

			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
			compilerParams.ReferencedAssemblies.Add("System.dll");
			compilerParams.GenerateInMemory = on
			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source as String)
			flush source
			close source
			if (compilerResults.Errors.Count > 0 ) then
			(
				
				local errs = stringstream ""
				for i = 0 to (compilerResults.Errors.Count-1) do
				(
					local err = compilerResults.Errors.Item[i]
					format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs
				)
				format "%\n" errs
				undefined

			)
			else
			(

				compilerResults.CompiledAssembly.CreateInstance "DisableWindowsGhosting"
			)
	   -- )
	)

	on getPFlow picked obj do
	(
		if classof obj == pf_source then
		(
			
			pflow = obj
			getPFlow.text = pflow.name
			pName = pflow.name + "->"
			nprefix.text = pflow.name + "_wire_"
			items = #()
			eNames = #()
			
			for q in 1 to objects.count do
			(
				if findstring objects[q].name pName != undefined then
				(
					eName = substring objects[q].name (pName.count + 1) objects[q].name.count
					append eNames objects[q].name
					append items eName
				)
			)
			
			excludeEvents.items = items
		)
	)
	
	on generate pressed do
	(
		if not isvalidnode pflow then return false
			
		wireparent = point()
		wireparent.name = uniquename (pflow.name + "_wiresParent_")
		wireparent.wirecolor = yellow
		
		undo off
		(
			try
			(
				
				DisableWindowsGhosting = DisableProcessWindowsGhosting()
				
				DisableWindowsGhosting.DisableProcessWindowsGhosting()
			)
			catch()

			if not isvalidnode pflow then return false

			
			mat = multimaterial()
			mat.numsubs = 25
			for q in mat.numsubs to 1 by -1 do
			(
				cVal = ((q - 1)/(mat.numsubs - 1) as float)
				
				cVal *= cVal * cVal * cVal * cVal
				
				cVal *= 100
				
				mat.materiallist[25 - q + 1].diffusecolor = white
				mat.materiallist[25 - q + 1].opacity = cval
				mat.materiallist[25 - q + 1].selfIllumAmount = 100
			)
			
			selArr = excludeevents.selection as array
			
			wireObjs = #()
			
			fcount = 1
			
			
			layName = pflow.name + "_particleConnections"
			lay = layermanager.getlayerfromname layName
			
			if (lay == undefined) then
			(
				lay = layermanager.newlayer()
				lay.setname layName
			)
		
			for t = tStart.value to tEnd.value do
			(
				prog2.color = yellow
				
				prog1.value = (fcount/(tEnd.value - tStart.value) as float)*100
				fcount += 1
				
				posArray = #()
				
				sliderTime = t
				
				count = pflow.numparticles()
				for i in 1 to count do
				(
					if keyboard.escpressed then exit
					prog2.value = (i/count as float)*100
					
					gVal = pflow.getparticlegroup i
					
					found = false
					
					for j in 1 to enames.count do
					(
						for q in 1 to selArr.count do
						(
							if enames[selarr[q]] == gval.name then
							(
								found = true
							)
						)
					)
					if not found then
					(
						pflow.particleindex = i
						append posarray pflow.particleposition
					)
				)
				/*
				for q in 1 to eNames.count do
				(
					found = false
					for g in 1 to selArr.count do
					(
						if selArr[g] == q then
						(
							found = true
						)
					)
					
					if not found then
					(
					
						ev = getnodebyname eNames[q]
						count = ev.NumParticles()
						for i = 1 to count do
						(
							if keyboard.escpressed then exit
								
							prog2.value = (i/count as float)*100
							
							pInx = ev.particleBornIndex i
							
							pflow.particleIndex = pInx
							append posArray pflow.particlePosition	
								
							
						)
						
					)
					
				)
				*/
				
				prog2.color = (color 0 150 1)

				if keyboard.escpressed then exit
					
				avDist = dThresh.value
					
				sp = splineShape()
				
				for k in 1 to posArray.count do
				(
					prog2.value = ((k/posArray.count as float)*100) 
					closeArr = #()
					distArr = #()
					doContinue = true
					for g in (k + 1) to posArray.count do
					(
						if doContinue then
						(
							dist = distance posarray[k] posarray[g]
							if (dist) < avDist  then
							(
								if distArr.Count > 0 then
								(
									keepgoing = true
									for h in 1 to distArr.count do
									(
										if (keepgoing) then
										(
											if distArr[h] > dist then
											(
												insertItem dist distArr h
												insertItem posarray[g] closeArr h
												keepgoing = false
											)
											
											
										)
										
									)
									
									if (keepgoing) then
									(
										append closeArr posarray[g]
										append distArr dist
									)
								)else
								(
								
									append closeArr posarray[g]
									append distArr dist
								
								)
							
							)			
							
						)
					)	

					
					for g in 1 to amin #(maxConn.value, closeArr.count) do
					(
						
						addnewSpline sp
						addKnot sp (numsplines sp) #corner #curve posarray[k]
						addKnot sp (numsplines sp) #corner #curve closearr[g]
						
						mVal = ((distArr[g]/tThresh.value as float) )
						mVal -= .15
						if mVal < 0 then mVal = 0
						if mVal > 1 then mVal = 1
					
						mVal *= 24
						mVal += 1
						
						mVal = mVal as integer
					
						setmaterialid sp (numsplines sp) 1 mVal
						
					)
				)
				
				
				updateshape sp
				
				
				
				sp.wirecolor = yellow
				
				with animate on
				(
					if (t != 0) then
					(
						at time (t - 1)
						(
							sp.scale = [0,0,0]
						)
					)
					at time (t)
					(
						sp.scale = [1,1,1]
					)
					at time (t + 1)
					(
						sp.scale = [0,0,0]
					)
					if t != 0 then
					(
						at time 0
						(
							sp.scale = [0,0,0]
						)
					)
				)
				
				for q in 1 to sp.scale.controller.keys.count do
				(
					sp.scale.controller.keys[q].inTangentType = #step
					sp.scale.controller.keys[q].outTangentType = #step
				)
								
				hide sp
				sp.material = mat
				sp.render_length = wThick.value
				sp.render_width = wThick.value
				if (nprefix.text != "") then
				(
					sp.name = uniquename nprefix.text
				)else
				(
					sp.name = uniquename "pShape"
				)
				sp.render_renderable = true
				sp.render_displayRenderMesh = true
				sp.render_rectangular = true
				
			
				lay.addnode sp
				sp.parent = wireparent
				append wireObjs sp
				converttomesh sp
				prog2.value = 0
			)
			
			unhide wireObjs
			prog1.value = 0
			prog2.value = 0
			gc light:true
		)
	)

)

AddSubRollout MakeToolbox.theSubrollout ParticleConnectorModule
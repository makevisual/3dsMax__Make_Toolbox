/*
#NAME:Isolate A Light
#VERSION:1.1
#INSTRUCTIONS:
Select a light and click the button to turn the
other ones off. Allows you to adjust only one 
light easily in renders.
http://www.makevisual.com/learning/MT_Isolate_A_Light.htm
#SOURCE:Romain Faure rf.romainfaure@gmail.com
#HISTORY:03.23.2012  >> Integrated to MakeToolbox + UI Updates
05.12.2011 >> Release -
02.26.2012  >> UI Update 

*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Romain Faure rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.12.2011 >> Release -
--- version 1.01 : 02.26.2012  >> UI Update 
--- version 1.1 : 03.23.2012  >> Integrated to MakeToolbox + UI Updates
--*****************************************************
-- INFOS :
-- Works with 3dsmax standard lights (TargetSpot, FreeSpot, TargetDirect, FreeDirect, Omni, Skylight)
-- Works with Vray SP2 1.50 Lights (VrayLight, VrayIES, VrayAmbientLight, VraySun)
--****************************************************
-- TUTORIAL :
-- Select a light and turn the others one off. Allow you to adjust only one light easily in render.
--****************************************************
IsolateALightModuleVer = 1.1
try(removeSubRollout MakeToolbox.theSubrollout IsolateALightModule)catch()

global ALights
global SelectedLights
global VrayLights
global MaxLights
global VrayLightsArray
global MaxLightsArray 
global BacktoScene

fn BacktoScene =
(
	for i = 1 to VrayLightsArray.count do
		(VrayLightsArray[i].on = VrayLights[i])
						
	for i = 1 to MaxLightsArray.count do
		(MaxLightsArray[i].enabled = MaxLights[i])
						
		ALights =#()
		VrayLights = #()
		MaxLights = #()
		VrayLightsArray = #()
		MaxLightsArray = #()
		
)

rollout IsolateALightModule ("Isolate A Light")/* + (IsolateALightModuleVer as string))*/
(
	
	checkbutton ISLBtn "Isolate Selected" width: 159 height:20 checked:false offset:[0,-4] tooltip:"Select One Light."
	-- Main Functions
	on ISLBtn changed ISLBtnState do 
		(

			undo on 
			(
			if selection.count != 1 
			then 
				(
					--messageBox("Select One Light.") title:"Isolate A Light" 
					ISLBtn.checked = false
					BacktoScene()
				) 
			else
				( 
				try(
					TempSelection = selection as array
					if ISLBtnState == true
						then
							(							
								-- Variables
								ALights = lights as array
								VrayLights = #() --- For Storing All Vray Lights States in the scene before any changes
								MaxLights = #() --- For Storing All 3dsmax Lights States in the scene before any changes
								VrayLightsArray = #()
								MaxLightsArray = #()
								CheckVrayLight = #()
								ChecKMaxLight = #()
					
								-- Store State Lights (On or Off)
								for i = 1 to ALights.count do
									(
										if isProperty ALights[i] #size0 == true --Check if it's a Vray Light with a property of Vraylight (no size0 on 3dsmax light standard)
										then 
											(
												--print "this is a vraylight"
												append VrayLights ALights[i].on -- store lights state
												append VrayLightsArray ALights[i]	-- store vraylight only
												CheckVrayLight[1] = 1 --- Set  1 for "There is Vray Lights in the scene"
											)
										else 
											(
												--print "this is not a vraylight"
												append MaxLights ALights[i].enabled -- store lights state
												append MaxLightsArray ALights[i] -- store Maxlight only
												ChecKMaxLight[1] = 1 --- Set  1 for "There is 3dsmax Lights in the scene"
											)
									)
											
								--- For Vray Lights 
								if  ChecKVrayLight[1] == 1 
								then 
									(
										actionMan.executeAction 0 "40044" 
										for i = 1 to VrayLightsArray.count do
											(
												VrayLightsArray[i].on = off
											)					
										actionMan.executeAction 0 "40044"
										$.on = on		
									)
					
								--- For 3dsmax Lights
								if  ChecKMaxLight[1] == 1
								then 
									(		
										actionMan.executeAction 0 "40044" 
										for i = 1 to MaxLightsArray.count do
											(
												MaxLightsArray[i].enabled = off 
											)
										actionMan.executeAction 0 "40044"
										$.enabled = on
									)
							)
						else 
							(	
								deselect TempSelection 
								BacktoScene()
							)
				)catch(messagebox "Tell Romain to 'go make coffee!'")
			)
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout IsolateALightModule
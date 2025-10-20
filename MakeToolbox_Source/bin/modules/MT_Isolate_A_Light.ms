/*
--**********************************************************************************--
--                                                                                  --
--                                ISOLATE A LIGHT                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Isolate A Light
#VERSION: 1.2
#LAST UPDATED: 2025.10.05

#DESCRIPTION:
A utility that allows a user to select a single light and temporarily turn off all 
other lights in the scene. This makes it easy to adjust and preview one light at a 
time without affecting others.

#INSTRUCTIONS:
Select one light in the viewport and click the "Isolate Selected" button to turn 
off all other lights. Click the button again to restore all lights to their 
previous on/off states.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Isolate_a_Light

#CREDITS:
    #Author: Romain Faure (rf.romainfaure@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Code modernization and resilience improvements.

#HISTORY:
    - v1.2 (2025.10.05): Reworked code to be more procedural and not rely on specific light types.
    - v1.1 (2012.03.23): Integrated into MakeToolbox and updated UI.
    - v1.01 (2012.02.26): UI Update.
    - v1.0 (2011.05.12): Initial release.

--**********************************************************************************--
*/
IsolateALightModuleVer = 1.2
try(removeSubRollout MakeToolbox.theSubrollout IsolateALightModule)catch()

rollout IsolateALightModule ("Isolate A Light v" + IsolateALightModuleVer as string)
(
	local
	TempSelection,
	ALights,
	ALightsState = #()
	checkbutton ISLBtn "Isolate Selected" width: 159 height:20 checked:false offset:[0,-4] tooltip:"Select One Light."
	-- Main Function
	fn RestoreLights CurrentLight SwitchString SwitchState =
	(
		if SwitchString == "on" then
		(
			CurrentLight.on = SwitchState
		)
		else
		(
			CurrentLight.enabled = SwitchState
		)
	)
	fn TurnOffLights CurrentLight SwitchString = 
	(
		if SwitchString == "on" then
		(
			CurrentLight.on = false
		)
		else
		(
			CurrentLight.enabled = false
		)
	)
	-- Event Handlers
	on ISLBtn changed ISLBtnState do 
	(
		undo label:"Isolate a Light" on 
		(
			if (selection.count != 1) AND (ALightsState.count == 0) then
			(
				messageBox("Select One Light.") title:"Isolate A Light" 
				ISLBtn.checked = false
			) 
			else
			( 
				try
				(
					if ISLBtnState == true then
					(
						-- Variables
						TempSelection = $
						ALights = lights as array
						ALightsState = #() --- For Storing All Lights States in the scene before any changes
						for i = 1 to ALights.count do
						(
							if ((superclassof ALights[i]) == light) AND (ALights[i] != TempSelection) do
							(
								if (isProperty ALights[i] #on) == true then
								(
									ALightsState[i] = ALights[i].on -- store lights state
									TurnOffLights ALights[i] "on"
								)
								else
								(
									ALightsState[i] = ALights[i].enabled -- store lights state
									TurnOffLights ALights[i] "enabled"
								)
							)
						)
					)
					else 
					(
						for i = 1 to ALights.count do
						(
							if ((superclassof ALights[i]) == light) AND (ALights[i] != TempSelection) do
							(
								if (isProperty ALights[i] #on) == true then
								(
									RestoreLights ALights[i] "on" ALightsState[i]  
								)
								else
								(
									RestoreLights ALights[i] "enabled" ALightsState[i]  
								)
							)
						)
					)
				)
				catch(messagebox "Tell Romain to 'go make coffee!'")
			)
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout IsolateALightModule
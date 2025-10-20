/*
--**********************************************************************************--
--                                                                                  --
--                         VRAYPROXY DISPLAY CHANGER                              	--
--                                                                                  --
--**********************************************************************************--

#NAME: VrayProxy Display Changer
#VERSION: 1.0
#LAST UPDATED: 2025.02.28

#DESCRIPTION:
A utility to quickly change the viewport display mode for all selected VRayProxy 
objects simultaneously.

#INSTRUCTIONS:
Select one or more VRayProxy objects in the viewport and choose the desired display 
mode from the radio buttons.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_VRay_Displayer

#CREDITS:
    #Author: David Almeida (david.almeida@makevisual.com)

#HISTORY:
    - v1.0 (2025.02.28): Initial development.

--**********************************************************************************--
*/
VrayDisplayerToolModule = "1.0"
try(removeSubRollout MakeToolbox.theSubrollout VrayDisplayer)catch()

-- creates the UI
rollout VrayDisplayer ("Vray Display Mode v" + (VrayDisplayerToolModule as string))
(
	radiobuttons VrayDisplayerRadioButtons "VRayProxy Display Mode" labels:#("BoudingBox", "Preview from file (faces)", "Preview from file (edges)","Point","Show whole mesh")
	-- function for changing VrayProxy display mode
	function ProxyDisplayMode DispMode =
	(
		VrayProxyObjects = #()
		if selection.count != 0 do
		(
			VrayProxyObjects = for i in selection where ((classof i) == VRayProxy) collect i
			VrayProxyObjects.display = DispMode
		)
	)
	on VrayDisplayerRadioButtons changed state do
	(
		case state of
		(
			1:(DispMode = 0)
			2:(DispMode = 3)
			3:(DispMode = 1)
			4:(DispMode = 2)
			5:(DispMode = 4)
		)
		ProxyDisplayMode DispMode
	)
)

AddSubRollout MakeToolbox.theSubrollout VrayDisplayer
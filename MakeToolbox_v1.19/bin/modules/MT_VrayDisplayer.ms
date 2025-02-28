/*
#NAME: VrayProxy Display Changer
#VERSION:1.0
#SOURCE:David Almeida, david.almeida@makevisual.com
#HISTORY:02.28.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by David Almeida
--*****************************************************
-- HISTORY:
--- version 1.00 : 02.28.2025 >> Start Development
--*****************************************************
VrayDisplayerToolModule = "0.1"
try(removeSubRollout MakeToolbox.theSubrollout VrayDisplayer)catch()

-- creates the UI
rollout VrayDisplayer ("Vray Display Mode" + (VrayDisplayerToolModule as string))
(
	radiobuttons VrayDisplayerRadioButtons "VRayProxy Display Mode" labels:#("BoudingBox", "Preview from file (faces)", "Preview from file (edges)","Point","Show Whole")
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
-- function for changing VrayProxy display mode

AddSubRollout MakeToolbox.theSubrollout VrayDisplayer
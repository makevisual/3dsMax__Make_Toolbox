/*
#NAME:DistanceMonitor
#VERSION:0.10
#INSTRUCTIONS:Displays the distance between 2 objects or 2 vertices
#SOURCE:David Almeida, davidcalmeida@gmail.com
#HISTORY:02.25.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
DistancemonitorToolModuleVer = 0.1
try(
	removeSubRollout MakeToolbox.theSubrollout DistancemonitorToolModule
	unregisterRedrawViewsCallback GW_displayDistanceMonitor
	)catch()

-- creates the UI
rollout DistancemonitorToolModule ("Distance Monitor " + (DistancemonitorToolModuleVer as string))
(
	local
	Pos1 = undefined,
	Pos2 = undefined,
	Nd = undefined,
	PtsArray = #()
	checkbutton DistMonitorChckButton "Enable Distance Monitor" pos:[2,2] width:160 highlightColor:red tooltip:"Enable distance probing between two objects or vertices. Right-click to update selection" align:#left
	Label DistMonitorLbl "<-->"
	button DistMonitorButton "Print Distance to Listener" width:160 tooltip:"Press to print the current distance to Max listener"
-- function for cleaning up in case of error or cancelling
	function CleanUpFunction = 
	(	
		DistMonitorChckButton.state = false
		DistMonitorLbl.text = "<-->"
		DistMonitorChckButton.text = "Enable Distance Monitor"
		Pos1 = undefined
		Pos2 = undefined
		Nd = undefined
		PtsArray = #()
		unregisterRedrawViewsCallback GW_displayDistanceMonitor
	)
-- function for displaying the distance between objects on screen

function GW_displayDistanceMonitor = 
(
	undo on
	(
		try 
		(
			if PtsArray.count != 0 do
			(
				if Nd == undefined then
				(
					Pos1 = PtsArray[1].pos
					Pos2 = PtsArray[2].pos
				)
				else
				(
					Pos1 = PtsArray[1].pos*Nd.transform
					Pos2 = PtsArray[2].pos*Nd.transform
				)
				Dist = length (Pos1 - Pos2)
				Midpt = (Pos1 + Pos2)/2
				gw.setTransform (matrix3 1)
				gw.text Midpt (units.formatValue Dist) color:yellow
				gw.Polyline #(Pos1, Pos2) false rgb:#(red, blue)
				gw.Marker Pos1 #circle color:green
				gw.Marker Pos2 #circle color:green
				gw.enlargeUpdateRect #whole
			)
		)
		catch
		(
			--catches any errors
			CleanUpFunction()
			messagebox "Unexpected error, please try again."
		)
	)
)

-- function for setting the points to draw the distance from
	function SetPoints =
	(
		case (selection.count) of
		(
			(2):
			(	
				Nd = undefined
				PtsArray[1] = $[1]
				PtsArray[2] = $[2]
				registerRedrawViewsCallback GW_displayDistanceMonitor
				LabelText = (substring PtsArray[1].name 1 12) + " <--> " + (substring PtsArray[2].name 1 12)
				DistMonitorLbl.text = LabelText
			)
			(1):
			(
				if (classof $ == Editable_mesh) OR (classof $ == PolyMeshObject) OR (classof $ == Editable_Poly) then
				(
					if $.mesh.selectedverts.count == 2 then
					(
						Nd = $
						SelVerts = $.mesh.selectedverts
						PtsArray[1] = SelVerts[1]
						PtsArray[2] = SelVerts[2]
						registerRedrawViewsCallback GW_displayDistanceMonitor
						LabelText = "Vert #" + (substring (SelVerts[1].index as string) 1 12) + " <--> Vert #" + (substring (SelVerts[2].index as string) 1 12)
						DistMonitorLbl.text = LabelText
					)
					else
					(
						messageBox "Select 2 vertices only"
						CleanUpFunction()
					)
				)
				else
				(
					messageBox "                Select 2 objects \n\n                          OR \n\nSelect a poly/mesh object and 2 vertices"
					CleanUpFunction()
				)
			)
			default:
			(
				messageBox "                Select 2 objects \n\n                          OR \n\nSelect a poly/mesh object and 2 vertices"
				CleanUpFunction()
			)
		)
	)
	-- the buttons
	on DistMonitorChckButton changed state do
	(
		if state then
		(
			DistMonitorChckButton.text = "Right Click to Update"
			SetPoints()
		)
		else
		(
			CleanUpFunction()
		)
	)
	on DistMonitorChckButton rightclick do
	(
		if DistMonitorChckButton.state == true do
		(
			SetPoints()
		)
	)
	on DistMonitorButton pressed do
	(
		if Pos1 != undefined do
		(
			format "Distance:%\n" (units.formatValue (length (Pos1 - Pos2)))
		)
	)
	on DistancemonitorToolModule close do
	(
		CleanUpFunction()
	)
)
AddSubRollout MakeToolbox.theSubrollout DistancemonitorToolModule
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
LinkConstrainerToolModule = "1.0"
try(removeSubRollout MakeToolbox.theSubrollout LinkConstrainer)catch()

-- creates the UI
rollout LinkConstrainer ("Link Constrainer v" + (LinkConstrainerToolModule as string))
(
	button LinkConstrainButton "Create on Selection" tooltip:"Create a Link Constraint Custom Attribute on the selected objects"
	button LinkConstrainHelperButton "Create on new Helper" tooltip:"Create a Link Constraint Custom Attribute on a new Helper Object"
	-- function for changing VrayProxy display mode
	function LinkConstraintFunction obj =
	(
		Max Create Mode
		obj.Transform.controller = (Link_Constraint())
		obj.controller[1][1].controller = (position_list())
		obj.controller[1][1].controller[2].controller = (Position_XYZ())
		obj.controller[1][1].controller.setActive 2
		obj.controller[1][1].controller.setname 1 "Frozen Position"
		obj.controller[1][1].controller.setname 2 "Zero Pos XYZ"
		obj.controller[1][2].controller = (rotation_list())
		obj.controller[1][2].controller[2].controller = (Euler_XYZ())
		obj.controller[1][2].controller.setActive 2
		obj.controller[1][2].controller.setname 1 "Frozen Rotation"
		obj.controller[1][2].controller.setname 2 "Zero Euler XYZ"
		addModifier obj (EmptyModifier())
		local TM = NodeTransformMonitor()
		TM.node = obj

		cusat = attributes Link_Constraint_Controls attribID:#(181402853L, 3882376594L)
		(
			local
			CurrentNode,
			LinkConstController,
			NodesNamesArray = #(),
			NodeTimesArray = #()
			parameters main rollout:Link_Controls
			(
				SelfNode type:#MAXObject
			)
			function UpdateNodesArrayFunction =
			(
				NodesNamesArray = #()
				NodeTimesArray = #()

				for i = 1 to  LinkConstController.getNumTargets() do
				(
					ItemName = undefined
					Item = (LinkConstController.getNode i)
					if Item == undefined then
					(
						ItemName = "World"
					)
					else
					(
						ItemName = (LinkConstController.getNode i).name
						if ItemName.count > 16 then
						(
							ItemName = (substring ItemName 1 6) + "..." + (substring ItemName (ItemName.count - 10) ItemName.count)
						)
						else
						(
							IdentSpaces = ""
							for i = 1 to (18 - ItemName.count)*2 do
							(
								IdentSpaces += " "
							)
							ItemName = ItemName + IdentSpaces
						)
					)
					append NodesNamesArray ItemName
					append NodeTimesArray (LinkConstController.getFrameNo i)
				)
				--append NodeTimesArray 1000000
			)
			function LinkedDisplayFunction =
			(
				LinkedNodesArray = #()
				if NodesNamesArray.count > 0 then
				(
					for i = 1 to NodesNamesArray.count do
					(
						CurrenSymbol = (NodeTimesArray[i] as string)
						append LinkedNodesArray (CurrenSymbol + " - " + NodesNamesArray[i])
					)
				)
				CurrentNode.modifiers[1].Link_Constraint_Controls.Link_Controls.TargetsListBox.items = LinkedNodesArray
			)
			function GetNodeAndControllersFunction =
			(
				CurrentNode = SelfNode.node
				LinkConstController = CurrentNode.controller
			)
			rollout Link_Controls "Link Constraint"
			(
				listbox TargetsListBox "Linked Nodes" items:#() width:160 offset:[-12,0] tooltip:"C_TOW_HLP_Cable_Hook_Arm_Root"
				pickbutton AddNodeButton "+ Node" offset:[-10,0] across:3
				button DelNodeButton "- Node" offset:[-3,0]
				button WorldLinkButton "World" width:60 offset:[0,0]
				on AddNodeButton picked val do
				(
					LinkConstController.addTarget val slidertime
					UpdateNodesArrayFunction()
					LinkedDisplayFunction()
				)
				on DelNodeButton pressed do
				(
					LinkConstController.DeleteTarget TargetsListBox.selection
					UpdateNodesArrayFunction()
					LinkedDisplayFunction()
				)
				on WorldLinkButton pressed do
				(
					LinkConstController.addWorld frameNo:slidertime
					UpdateNodesArrayFunction()
					LinkedDisplayFunction()
				)
				on Link_Controls open do
				(
					GetNodeAndControllersFunction()
					UpdateNodesArrayFunction()
					LinkedDisplayFunction()
				)
			)
		)
		custAttributes.add obj.modifiers[1] cusat
		obj.modifiers[1].Link_Constraint_Controls.SelfNode = TM
		Max Modify Mode
	)
	on LinkConstrainButton pressed do
	(
		if selection.count != 0 then
		(
			for obj in selection do
			(
				LinkConstraintFunction obj
			)
		)
		else
		(
			messageBox "Select one or more objects"
		)
	)
	on LinkConstrainHelperButton pressed do
	(
		obj = point wirecolor:green
		LinkConstraintFunction obj
	)
)
AddSubRollout MakeToolbox.theSubrollout LinkConstrainer
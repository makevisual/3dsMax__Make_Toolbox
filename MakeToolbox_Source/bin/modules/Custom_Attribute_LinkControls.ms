--(local
	--MyMod = undefined
	--addModifier $ (EmptyModifier())
	--$.modifiers[1].name = "Frequency Control"
	--MyMod = $.modifiers[1]
		



	ca = custAttributes.getDef $.modifiers[1].LinkControls
	attributes LinkControls
	redefine:ca



	--cusat = attributes LinkControls
	(
		local
		CurrentNode,
		ParentNode,
		PosConstController,
		RotConstController
		parameters main rollout:Link_Controls
		(
			SelfNode type:#MAXObject
			NodesArray type:#nodeTab tabSizeVariable:true
			ShadowPtsArray type:#nodeTab tabSizeVariable:true
			NodeNamesArray type:#stringTab tabSizeVariable:true
		)
		function LinkedDisplayFunction =
		(
			LinkedNodesArray = #()
			for i = 1 to NodeNamesArray.count do
			(
				CurrentWeight = CurrentNode.controller[1][1].getWeight i
				append LinkedNodesArray (NodeNamesArray[i] + "  -  " + (CurrentWeight as string))
			)
			CurrentNode.modifiers[1].LinkControls.Link_Controls.TargetsListBox.items = LinkedNodesArray
		)
		function GetNodeAndControllersFunction =
		(
			CurrentNode = SelfNode.node
			ParentNode = CurrentNode.parent
			PosConstController = CurrentNode.controller[1][1]
			RotConstController = CurrentNode.controller[2][1]
		)
		function LinkNodesFunction ItemIndex Firstlink =
		(
			with redraw off
			with animate on
			(
				if Firstlink do
				(
					currentLayer = LayerManager.getLayerFromName "zz-AnimHelpers"
					if currentLayer == undefined do
					(
						LayerManager.newLayerFromName "zz-AnimHelpers"
						currentLayer = LayerManager.getLayerFromName "zz-AnimHelpers"
					)
					ShadowPoint = point centermarker:false axistripod:false cross:false box:false
					ShadowPoint.name = (NodesArray[ItemIndex].name + "_LinkPt")
					currentLayer.addNode ShadowPoint
					ShadowPoint.parent = NodesArray[ItemIndex]
					ShadowPoint.transform = CurrentNode.transform
					ShadowPtsArray[ItemIndex] = ShadowPoint
					PosConstController.appendTarget ShadowPtsArray[ItemIndex] 0.0
					RotConstController.appendTarget ShadowPtsArray[ItemIndex] 0.0
				)
				FixTime = false
				if slidertime == animationRange.start do
				(
					FixTime = true
					animationRange = interval (slidertime - 1) animationRange.end
				)
				slidertime = slidertime - 1
				for i = 1 to (PosConstController.getNumTargets()) do
				(
					(
						PosConstController.setWeight i (PosConstController.getWeight i)
						RotConstController.setWeight i (RotConstController.getWeight i)
					)
				)
				--$.controller[1][2].value = $.controller[1][2].value
				--$.controller[2][2].value = $.controller[2][2].value
				ShadowPtsArray[ItemIndex].transform = ShadowPtsArray[ItemIndex].transform
				slidertime = slidertime + 1
				if (PosConstController.getNumTargets()) == 1 then
				(
					ShadowPtsArray[ItemIndex].transform = ShadowPtsArray[ItemIndex].transform
				)
				else
				(
					ShadowPtsArray[ItemIndex].transform = CurrentNode.transform
				)
				for i = 1 to (PosConstController.getNumTargets()) do
				(
					(
						PosConstController.setWeight i 0.0
						RotConstController.setWeight i 0.0
					)
				)
				PosConstController.setWeight ItemIndex 100.0
				RotConstController.setWeight ItemIndex 100.0
				--macros.run "Animation Tools" "TransformToZero"
				if FixTime do
				(
					FixTime = false
					animationRange = interval (slidertime) animationRange.end
				)
			)
			LinkedDisplayFunction()
		)
		function CleanUpKeysFunction ItemIndex =
		(
			CurrentShadowPt = ShadowPtsArray[ItemIndex]
			KeysToDelete = PosConstController.controller[ItemIndex].controller.keys
			for i = 1 to ShadowPtsArray.count do
			(
				PosConstWeightController = PosConstController.controller[i].controller
				RotConstWeightController = RotConstController.controller[i].controller
				PosControllerShdwPt = ShadowPtsArray[i].controller[1].controller
				RotControllerShdwPt = ShadowPtsArray[i].controller[2].controller

				deselectKeys PosConstWeightController
				for j = 1 to  KeysToDelete.count do
				(
					selectKeys PosConstWeightController KeysToDelete[j].time
				)
				deleteKeys PosConstWeightController #selection


				deselectKeys RotConstWeightController
				for j = 1 to  KeysToDelete.count do
				(
					selectKeys RotConstWeightController KeysToDelete[j].time
				)
				deleteKeys RotConstWeightController #selection


				deselectKeys PosControllerShdwPt
				for j = 1 to  KeysToDelete.count do
				(
					
					selectKeys PosControllerShdwPt KeysToDelete[j].time
				)
				deleteKeys PosControllerShdwPt #selection

				deselectKeys RotControllerShdwPt
				for j = 1 to  KeysToDelete.count do
				(
					
					selectKeys RotControllerShdwPt KeysToDelete[j].time
				)
				deleteKeys RotControllerShdwPt #selection

			)
			delete CurrentShadowPt
		)
		rollout Link_Controls "Link Controls"
		(
			listbox TargetsListBox "Linked Nodes" items:#() width:160 offset:[-12,0] tooltip:"C_TOW_HLP_Cable_Hook_Arm_Root"
			pickbutton AddNodeButton "+ Node" offset:[-10,0] across:3
			button DelNodeButton "- Node" offset:[-3,0]
			button ReLinkNodeButton "ReLink" width:60 offset:[0,0]
			Label FreqCrlLBL "DON'T DELETE THIS MODIFIER"
			on TargetsListBox selected val do
			(
				print CurrentNode
				print PosConstController
				print RotConstController
				print TargetsListBox.items[val]
				print NodesArray
				print NodeNamesArray
			)
			on AddNodeButton picked val do
			(
				if (appendIfUnique NodesArray val) do
				(
					ItemName = val.name
					if ItemName.count > 16 then
					(
						ItemName = (substring ItemName 1 6) + "..." + (substring ItemName (ItemName.count - 5) ItemName.count)
					)
					else
					(
						IdentSpaces = ""
						for i = 1 to (16 - ItemName.count)*2 do
						(
							IdentSpaces += " "
						)
						ItemName = ItemName + IdentSpaces
					)
					appendIfUnique NodeNamesArray ItemName
					TargetsListBox.items = (NodeNamesArray as array)
					ItemIndex = NodeNamesArray.count
					--if (ItemIndex != 0) AND (ItemIndex != undefined)  do
					--(
						--PosConstController.appendTarget NodesArray[ItemIndex] 0.0
						--RotConstController.appendTarget NodesArray[ItemIndex] 0.0
					--)
					LinkNodesFunction ItemIndex true
				)
			)
			on DelNodeButton pressed do
			(
				ItemIndex = TargetsListBox.selection
				if (ItemIndex != 0) AND (ItemIndex != 1) AND (ItemIndex != undefined)  do
				(
					CleanUpKeysFunction ItemIndex
					deleteItem NodesArray ItemIndex
					deleteItem NodeNamesArray ItemIndex
					--delete ShadowPtsArray[ItemIndex]
					deleteItem ShadowPtsArray ItemIndex
					PosConstController.deleteTarget ItemIndex
					RotConstController.deleteTarget ItemIndex
					TargetsListBox.items = (NodeNamesArray as array)
					print TargetsListBox.selection
					print NodesArray
					print NodeNamesArray
					print ShadowPtsArray
					LinkedDisplayFunction()
				)
				if ItemIndex == 1 do
				(
					messageBox "Cannot remove parent node"
				)
			)
			on ReLinkNodeButton pressed do
			(
				ItemIndex = TargetsListBox.selection
				LinkNodesFunction ItemIndex false
			)
			on Link_Controls open do
			(
				GetNodeAndControllersFunction()
				if NodesArray.count == 0 do
				(
					appendIfUnique NodesArray ParentNode
					appendIfUnique NodeNamesArray "Parent                   "
					--ShadowPtsArray[1] = ParentNode
					LinkNodesFunction 1 true
				)
				print "Opened"
				registerTimeCallback LinkedDisplayFunction
				LinkedDisplayFunction()
			)
			on Link_Controls close do
			(
				print "Closed"
				unRegisterTimeCallback LinkedDisplayFunction
			)
		)
	)
	--custAttributes.add $.modifiers[1] cusat
	cusat = custAttributes.getDef $.modifiers[1].LinkControls
--)
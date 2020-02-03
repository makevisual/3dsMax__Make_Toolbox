/*
#NAME:Rivet Maker
#VERSION:1.1
#INSTRUCTIONS:
Use Rivet Maker to quickly attach geometry to a skinned surface.
http://www.makevisual.com/learning/MT_RivetMaker.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.12.2012  >> Integrated to MakeToolbox
05.25.2011 >> Release
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.25.2011 >> Release
--- version 1.1 : 03.12.2012  >> Integrated to MakeToolbox
--*****************************************************
RivetPointModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout RivetPointModule)catch()

Global PickedSurface
pickedSurface = undefined
PickedSurfaceArray = #()
DecalArray = #()

rollout RivetPointModule ("Rivet Point") /* + (RivetPointModuleVer as string))*/
(
	GroupBox GrpBox1 "Surface" width:160 height:39 offset:[-10,-3]
	Pickbutton RivetPointSelection "Select Rivet Surface" width:152 height:20 tooltip:"The skinned surface you are riveting to." offset:[0,-29]
	
	GroupBox GrpBox2 "Rivet" width:160 height:100 offset:[-10,0]
	Button RivetPointMaker "Create Rivit Point" width:152 height:20 tooltip:"Click on rivet surface" offset:[1,-90]
	Checkbox ConvertSkinCheck "Convert To Skin" tristate:1 offset:[0,-2]
	Checkbox ControlerPointCheck "Make Control Point" tristate:1 offset:[0,0]
	Spinner DecalSizeSpinner range:[1,20,3] width:35 type:#integer offset:[-88,0]
	label label1 "Size Offset" offset:[-2,-20]
	
	GroupBox GrpBox3 "Group Rivet to Skin" width: 160 height:80 offset:[-10,4]
	Button RivetGroupMaker "Rivet Selection" width:152 height:20 tooltip:"Grab Junk to Rivet" offset:[0,-70]
	Checkbox ControlerPointCheckB "Make Control Point" tristate:1 offset:[0,-2]
	Spinner DecalSizeSpinnerB range:[1,20,3] width:35 type:#integer offset:[-88,0]
	label label2 "Size Offset" offset:[-2,-20]
	
	on  RivetGroupMaker pressed do 
	(
	if pickedSurface == undefined then (messagebox "You must select a valid surface!") else
		(
		if selection.count == 0 then (messagebox "Select something to attach, silly!") else
			(
			DecalArray = #()
			newDecal = Plane length:DecalSizeSpinnerB.value width:DecalSizeSpinnerB.value pos:[0,0,0] lengthsegs:1 widthsegs:1 renderable:off
			newDecal.renderable = off
				
			for i in 1 to selection.count do
				(
				NewNodeSizeB = (DecalSizeSpinnerB.value*2)
				newNode = point wirecolor:red centermarker: off axistripod: off cross: on cross: on Box: off size: NewNodeSizeB
				newNode.transform = selection[i].transform
				NewDecalIteration = copy newdecal
				NewDecalIteration.transform = newNode.transform
				newDecalIteration.renderable = off
				newDecalIteration.wirecolor = [255,169,0]
				
				addmodifier NewDecalIteration (Skin_Wrap weightAllVerts:on meshlist:PickedSurfaceArray) 
				
				newNode.pos.controller = position_list ()
				farts = newNode.pos.controller.Available.controller = Attachment node: NewDecalIteration coord: [0,.5] face:1
				AttachCtrl.addNewKey farts 1
				
				join DecalArray #(newDecalIteration)
				
				if ControlerPointCheckB.checked == true then 
					(
					newCtrlNode = point wirecolor:Green centermarker: off axistripod: off cross: off cross: off Box: on size: NewNodeSizeB
					newCtrlNode.transform = selection[i].transform
					newCtrlNode.Parent = newNode
					selection[i].parent = newCtrlNode
					newCtrlNode.setSkinPose()
					)else(selection[i].parent = newNode)
				)
			delete newDecal
			select decalArray
			)
		)
	)
	
	on RivetPointSelection picked PickedSurfaceVar do
	(
		PickedSurfaceArray = #()
		PickedSurface = PickedSurfaceVar
		join PickedSurfaceArray #(PickedSurface)
		if classof PickedSurface.modifiers[1] == skin then
			(
			RivetPointSelection.text = PickedSurface.name
			print PickedSurface
			) else (messagebox "Top Modifier must be a 'Skin' Modifier")
	)
	
	------------------------------ allow non skinnned surfaces
	
	on RivetPointMaker pressed do
	(
		if pickedSurface == undefined then (messagebox "you must select a valid surface") else
			(
			try
				(
				maxOps.autoGrid = true
				newNodeArray = startObjectCreation point returnNewNodes:#first 
				
				disableSceneRedraw ()
					
				max modify mode
				clearSelection()
				NewNodeSize = (DecalSizeSpinner.value*2)
				newNode = newNodeArray[1]
				newNode.wirecolor = red
				newNode.centermarker = off
				newNode.axistripod = off
				newNode.cross = on
				newNode.Box = off
				newNode.size = NewNodeSize
				print newnode.size
				newDecal = Plane length:DecalSizeSpinner.value width:DecalSizeSpinner.value pos:[0,0,0] lengthsegs:1 widthsegs:1  isSelected:on renderable: off
				newDecal.transform = newNode.transform
				newDecal.wirecolor = [255,169,0]
				select newDecal
				
				macros.run "Modifier Stack" "Convert_to_Poly"
				subobjectLevel = 2
				$.EditablePoly.SetSelection #Edge #{2}
				$.EditablePoly.collapse #Edge
				subobjectLevel = 0
				
				modPanel.addModToSelection (Skin_Wrap ()) ui:on
				newDecal.modifiers[#Skin_Wrap].weightAllVerts = on
				newDecal.modifiers[#Skin_Wrap].meshlist = PickedSurfaceArray
				
				newNode.pos.controller = position_list ()
				farts = newNode.pos.controller.Available.controller = Attachment node: newDecal coord: [.5,0] face:1
				AttachCtrl.addNewKey farts 1
				
				------------------------------ allow non skinnned surfaces
				
				if convertSkinCheck.checked == true then
					(
					newDecal.modifiers[1].meshDeformOps.convertToSkin true
					deleteModifier newDecal 2
					)
				else ()
							
				if ControlerPointCheck.checked == true then
					(
					NewCtrlNodeSize = (DecalSizeSpinner.value*3)
					newControlerNode = point centermarker:off axistripod:off cross:off Box:on wirecolor:green size:NewCtrlNodeSize
					newControlerNode.transform = newNode.transform
					newControlerNode.parent = newNode
					newCOntrolerNode.setSkinPose()

					)			
				else ()
			)catch(messagebox "Something strange happened, try agian")
		enableSceneRedraw ()
		)
	)
 )
AddSubRollout MakeToolbox.theSubrollout RivetPointModule
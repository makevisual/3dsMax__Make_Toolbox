/*
--**********************************************************************************--
--                                                                                  --
--                                 ALIGN AND COPY                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Align and Copy
#VERSION: 1.1
#LAST UPDATED: 2025.03.19

#DESCRIPTION:
A utility to align and distribute copies of one or more source objects onto a selection
of target objects, with options for instancing, parenting, and pivot control.

#INSTRUCTIONS:
Add source object(s) to the "Objects to copy" list. Select one or more target objects
in the viewport. Choose your distribution and copy methods, then click the "Copy Objects
to Targets" button.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Align_and_Copy

#CREDITS:
    #Author: Tyson Ibele (tyson@tysonibele.com)
    #Contributors:
        - Aaron Dabelow (theonlyaaron@gmail.com): Integration into MakeToolbox
        - David Almeida (david.almeida@makevisual.com): Updated the script

#HISTORY:
    - v1.1 (2025.03.19): Updated the script's UI and functionality.
    - v1.0 (2012.03.12): Initial integration into MakeToolbox.

--**********************************************************************************--
*/
AlignAndCopyModuleVer = 1.1
try(removeSubRollout MakeToolbox.theSubrollout AlignAndCopyModule)catch()

-- creates the UI
rollout AlignAndCopyModule ("Align And Copy " + (AlignAndCopyModuleVer as string) )
(
	local
	RefNode,
	CopiedNodes = #(),
	ObjsToCloneList = #(),
	ObjsToCloneNameList = #(),
	CopyMethod = #instance,
	CopyMethodList = #(#copy, #instance)

	multiListBox ObjsToCloneMLB "Objects to copy" width:160 offset:[-10,0]
	button AddSelButton "+" width:53 height:20 offset:[-7,0] across:3 tooltip:"Adds selected object(s) to the copy list"
	button RemSelButton "-" width:54 height:20 offset:[1,0] tooltip:"Removes the object(s) selected in the copy list"
	button ClearListButton "Clear list" width:53 height:20 offset:[10,0] tooltip:"Removes all object(s) from the copy list"
	group "Distribution method"
	(
		radiobuttons DistMethodRB labels:#("All", "Cycle","Random") offsets:#([7,0],[-9,0],[-10,0]) tooltip:#("Clones all objects in the list over the selected objects",\
			"Sequentially clones the objects in the list over the selected object","Randomly clones the objects in the list over the selected object") columns:3 
	)
	group "Copy method"
	(
		radiobuttons CopyMethodRB labels:#("Copy", "Instance") default:2
	)
	groupBox OptionsGB "Options" width:158 height:60 offset:[-10,0]
	checkbox copyChildren "Copy Children" checked:true offset:[0,-45]
	checkbox ParentCheck "Parent to target" checked:true offset:[0,-3]
	button help "?" width:20 height:20 align:#right offset:[4,-40]

	groupBox PickBaseGB "" width:158 height:50 offset:[-10,25]
	checkbox RefObjChck "Pick reference" offset:[0,-55]
	pickbutton RefObjPckBtn "Reference node" width:129 height:20 offset:[7,0] enabled:false tooltip:"Pick the object whose pivot information you'd like to use instead of the source object's pivot" across:2
	button DelRefObjBtn "X" width:20 height:20 offset:[30,0] enabled:false tooltip:"Clear reference node"
	button Clone2TargetsBtn "Copy Objects to Targets" width:160 height:20 offset:[0,10] tooltip:"Copies and aligns the object(s) from the copy list to the selected targets" enabled:false
	function AlignPivotTo Obj Trgt =
	(
		-- Get matrix from object
		if classOf Trgt != matrix3 then Trgt = Trgt.transform
		
		-- Store child transforms
		local ChldTms = in coordSys Trgt ( for Chld in Obj.children collect Chld.transform )
		
		-- Current offset transform matrix
		local TmScale = scaleMatrix Obj.objectOffsetScale
		local TmRot = Obj.objectOffsetRot as matrix3
		local TmPos = transMatrix Obj.objectOffsetPos
		local TmOffset = TmScale * TmRot * TmPos
		
		-- New offset transform matrix
		TmOffset *= obj.transform * inverse Trgt
		
		-- Apply matrix
		Obj.transform = Trgt
		
		-- Restore offsets
		Obj.objectOffsetPos = TmOffset.translation
		Obj.objectOffsetRot = TmOffset.rotation
		Obj.objectOffsetScale = TmOffset.scale
		
		-- Restore child transforms
		for i = 1 to Obj.children.count do Obj.children[i].transform = ChldTms[i] * inverse Trgt * Obj.transform
	)
	function CopyInstancer Targetindex Cloneindex =
	(
		if RefObjChck.checked then
		(
			TempPoint = point()
			TempPoint.transform = ObjsToCloneList[Cloneindex].transform
			AlignPivotTo TempPoint RefNode
			maxops.clonenodes ObjsToCloneList[Cloneindex] expandhierarchy:copyChildren.checked cloneType:CopyMethod newNodes:&CopiedNodes
			CopiedNodes[1].parent = TempPoint
			TempPoint.transform = selection[Targetindex].transform
			delete TempPoint
		)
		else
		(
			maxops.clonenodes ObjsToCloneList[Cloneindex] expandhierarchy:copyChildren.checked cloneType:CopyMethod newNodes:&CopiedNodes
			CopiedNodes[1].transform = selection[Targetindex].transform
		)
		if (ParentCheck.checked) then
		(
			CopiedNodes[1].parent = selection[Targetindex]
		)
	)
	on help pressed do
	(
		str = "This script allows you to distribute object(s)
over a set of selected targets. \n\nIf you choose a reference object,
the object(s) will be distributed using that reference object's
pivot instead of its own."
		
		messagebox str title:"Help"
	)
	on ObjsToCloneMLB selectionend do
	(
		ToSelect = #()
		for i in ObjsToCloneMLB.selection do
		(
			append ToSelect ObjsToCloneList[i]
		)
		select ToSelect
	)
	on AddSelButton pressed do
	(
		if selection.count != 0 do
		(
			for i in selection do
			(
				appendIfUnique ObjsToCloneList i
				appendIfUnique ObjsToCloneNameList i.name
			)
			ObjsToCloneMLB.items = ObjsToCloneNameList
			if RefObjChck.checked == false then
			(
				Clone2TargetsBtn.enabled = true
			)
			else
			(
				if RefObjPckBtn.object == undefined then
				(
					Clone2TargetsBtn.enabled = false
				)
				else
				(
					Clone2TargetsBtn.enabled = true
				)
			)
		)
	)
	on RemSelButton pressed do 
	(
		CurrSelectedListObj = ObjsToCloneMLB.selection as array
		if CurrSelectedListObj.count != 0 do
		(
			for i = CurrSelectedListObj.count to 1 by -1 do
			(
				deleteitem ObjsToCloneList CurrSelectedListObj[i]
				deleteitem ObjsToCloneNameList CurrSelectedListObj[i]
			)
			ObjsToCloneMLB.items = ObjsToCloneNameList
		)
		if ObjsToCloneList.count == 0 do
		(
			Clone2TargetsBtn.enabled = false
		)
	)
	on ClearListButton pressed do
	(
		if ObjsToCloneList.count != 0 do
		(
			ObjsToCloneList = #()
			ObjsToCloneNameList = #()
			ObjsToCloneMLB.items = ObjsToCloneNameList
			Clone2TargetsBtn.enabled = false
		)
	)
	on CopyMethodRB changed state do
	(
		CopyMethod = CopyMethodList[state]
	)
	on RefObjPckBtn picked obj do
	(
		RefNode = obj
		RefObjPckBtn.text = RefNode.name
		DelRefObjBtn.enabled = true
		if ObjsToCloneList.count > 0 do
		(
			Clone2TargetsBtn.enabled = true
		)
	)
	on RefObjChck changed val do
	(
		RefObjPckBtn.enabled = val
		if val then
		(
			if RefObjPckBtn.object == undefined then
			(
				Clone2TargetsBtn.enabled = false
			)
			else
			(
				if ObjsToCloneList.count > 0 do
				(
					Clone2TargetsBtn.enabled = true
				)
			)
			if RefObjPckBtn.object != undefined do
			(
				DelRefObjBtn.enabled = val
			)
		)
		else
		(
			DelRefObjBtn.enabled = val
			if ObjsToCloneList.count > 0 then
			(
				Clone2TargetsBtn.enabled = (NOT val)
			)
			else
			(
				Clone2TargetsBtn.enabled = val
			)
		)
	)
	on DelRefObjBtn pressed do
	(
		RefObjPckBtn.object = RefNode = undefined
		RefObjPckBtn.text = "Reference node"
		DelRefObjBtn.enabled = false
		Clone2TargetsBtn.enabled = false
	)
	on Clone2TargetsBtn pressed do
	(
		if selection.count > 0 then
		(
			try
			(
				with undo "Align and Copy" ON
				(
					for i = 1 to selection.count do
					(
						case DistMethodRB.state of
						(
							(1):
							(
								for index = 1 to ObjsToCloneList.count do
								(
									CopyInstancer i index
								)
							)
							(2):
							(
								index = (mod (i - 1) ObjsToCloneList.count) + 1
								CopyInstancer i index
							)
							(3):
							(
								index = random 1 ObjsToCloneList.count
								CopyInstancer i index
							)
						)
					)
				)
			)
			catch
			(
				--catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
		else
		(
			messagebox "Select target objects"
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout AlignAndCopyModule
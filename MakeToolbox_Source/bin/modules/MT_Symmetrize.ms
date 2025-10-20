/*
--**********************************************************************************--
--                                                                                  --
--                                   SYMMETRIZE                                   --
--                                                                                  --
--**********************************************************************************--

#NAME: Symmetrize
#VERSION: 1.0
#LAST UPDATED: 2025.02.24

#DESCRIPTION:
A utility to make a mesh symmetrical along a specified axis while preserving its 
existing UV mapping coordinates.

#INSTRUCTIONS:
Pick a symmetrical "Base Object", select the object(s) in the scene you wish to 
symmetrize, choose an axis, and click "Symmetrize Objects".
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Symmetrize

#CREDITS:
    #Author: David Almeida (david.almeida@makevisual.com)

#HISTORY:
    - v1.0 (2025.02.24): Initial development and integration into MakeToolbox.

--**********************************************************************************--
*/
SymmetrizeToolModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout SymmetrizeToolModule)catch()

-- creates the UI
rollout SymmetrizeToolModule ("Symmetrize " + (SymmetrizeToolModuleVer as string))
(	
	local
	BaseNode = undefined,
	SymmetryNode = undefined,
	SelectedObjects = #()
	function Geo_Filter geo = ((superClassOf geo) == GeometryClass)
	group "Base Object"
	(
		pickbutton BaseObjButton "Select Base Object" filter:Geo_Filter tooltip:"Select Object in neutral, symmetrical pose"
		label AxisLabel "Symmetry Axis (Local)"
		radiobuttons AxisRadioButtons labels:#("X", "Y", "Z")
	)
	button SymmButton "Symmetrize Objects" pos:[2,100] width:160 tooltip:"Swaps the transforms between 2 objects" align:#left
	checkbox SymmCheckButton "Flip Instead of Symmetrize" align:#center
	checkbox CopyCheckButton "Make a copy of the Object" checked:true align:#center
-- function for symmetrizing the object while maintaining the texture coordinates
	function SymmetrizeFN Nd = 
	(
		undo on
		(
			max create mode
			try
			(
				if selection.count != 0 then
				(
					SelectedObjects = selection as array
					for i in SelectedObjects do
					(
						if i == Nd then
						(
							print "The Base Object cannot be symmetrized."
						)
						else
						(	
							BaseNode.transform = i.transform
							if SymmCheckButton.checked == true then
							(
								SymmetryNode = copy BaseNode
							)
							else
							(
								SymmetryNode = copy i
							)
							addModifier BaseNode (morpher())
							WM3_MC_BuildFromNode BaseNode.modifiers[1] 1 i
							addModifier BaseNode (mirror())
							BaseNode.modifiers[1].mirror_axis = AxisRadioButtons.state - 1
							addModifier SymmetryNode (skin_wrap())
							SymmetryNode.modifiers[1].meshlist = #(BaseNode)
							SymmetryNode.modifiers[1].engine = 0
							SymmetryNode.modifiers[1].falloff = 0.001 -- Maybe expose this value?
							redrawViews()
							WM3_MC_SetValue BaseNode.modifiers[2] 1 100.0
							maxops.collapsenodeto SymmetryNode 1 on
							if CopyCheckButton.checked then
							(
								MoveVector = [0,0,0]
								MoveVector[AxisRadioButtons.state] = (SymmetryNode.max[AxisRadioButtons.state] - SymmetryNode.min[AxisRadioButtons.state])
								in coordsys local (move SymmetryNode MoveVector)
							)
							else
							(	
								SymmetryNode.wirecolor = i.wirecolor
								SymmetryNode.material = i.material
								delete i
							)
							deleteModifier BaseNode 1
							deleteModifier BaseNode 1
							redrawViews()
						)
					)
					if BaseNode != undefined do (delete BaseNode)
				)
				else
				(
					messagebox "Select objects to symmetrize."
				)		
			)
			catch
			(
				--catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)
	-- the buttons
	on BaseObjButton picked obj do
	(
		if (close_enough obj.scale[1] 1.0 10) AND (close_enough obj.scale[2] 1.0 10) AND (close_enough obj.scale[3] 1.0 10) then
		(
			BaseObjButton.text = obj.name
		)
		else
		(
			messagebox "The object has been scaled. Please, apply a ResetXForm before using the tool"
		)
	)
	on BaseObjButton rightclick do
	(
		BaseObjButton.text = "Select Base Object"
	)
	on AxisRadioButtons changed state do
	(
		--print AxisRadioButtons.state
	)
	on SymmButton pressed do
	(
		--print AxisRadioButtons.state
		if BaseObjButton.object != undefined then
		(
			BaseNode = copy BaseObjButton.object
			SymmetrizeFN BaseObjButton.object
		)
		else
		(
			messagebox "Select Base Object."
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout SymmetrizeToolModule
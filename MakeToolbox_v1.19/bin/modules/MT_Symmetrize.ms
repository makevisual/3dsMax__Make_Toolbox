/*
#NAME:Symmetrize
#VERSION:0.10
#INSTRUCTIONS:Make the mesh symmetrical without losing mapping coordinates
#SOURCE:David Almeida, davidcalmeida@gmail.com
#HISTORY:02.24.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
SymmetrizeToolModuleVer = 0.1
try(removeSubRollout MakeToolbox.theSubrollout SymmetrizeToolModule)catch()

-- creates the UI
rollout SymmetrizeToolModule ("Symmetrize " + (SymmetrizeToolModuleVer as string))
(	local
	BaseNode = undefined,
	SymmetryNode = undefined
	function Geo_Filter geo = ((superClassOf geo) == GeometryClass)
	group "Base Object"
	(
		pickbutton BaseObjButton "Select Base Object" filter:Geo_Filter tooltip:"Select Object in neutral pose"
		label AxisLabel "Symmetry Axis (Local)"
		radiobuttons AxisRadioButtons labels:#("X", "Y", "Z")
	)
	button SymmButton "Symmetrize Objects" pos:[2,100] width:160 tooltip:"Swaps the transforms between 2 objects" align:#left
	checkbox SymmCheckButton "Flip Instead of Symmetrize" align:#center
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
					for i in selection do
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
							SymmetryNode.modifiers[1].falloff = 0.01
							redrawViews()
							WM3_MC_SetValue BaseNode.modifiers[2] 1 100.0
							maxops.collapsenodeto SymmetryNode 1 on
							MoveVector = [0,0,0]
							MoveVector[AxisRadioButtons.state] = (SymmetryNode.max[AxisRadioButtons.state] - SymmetryNode.min[AxisRadioButtons.state])
							in coordsys local (move SymmetryNode MoveVector)
							deleteModifier BaseNode 1
							deleteModifier BaseNode 1
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
		if obj.scale != [1,1,1] then
		(
			messagebox "The object has been scaled. Please, apply a ResetXForm before using the tool"
		)
		else
		(
			BaseObjButton.text = obj.name
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
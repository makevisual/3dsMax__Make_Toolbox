/*
#NAME:PRSswap
#VERSION:0.10
#INSTRUCTIONS:Selects all objects that share the same instanced modifier
#SOURCE:David Almeida, davidcalmeida@gmail.com
#HISTORY:02.21.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
SelModInstToolModuleVer = 0.1
try(removeSubRollout MakeToolbox.theSubrollout SelModInstToolModule)catch()

-- creates the UI
rollout SelModInstToolModule ("Slct Mod Instances " + (SelModInstToolModuleVer as string))
(	local
	InstacedModList = #(),
	InstacedModListNames = #()
	group "Object Select"
	(
		pickbutton ObjSel "Select Object" tooltip:"Select Object with instanced modifiers"
	)
	group "Instanced Modifier List"
	(
		listbox modlist ""
	)
	button SelInsModButton "Select Instaced Modifiers" pos:[2,225] width:160 tooltip:"Selects Objects with the selected instanced modifier" align:#left
-- function for finding modifiers that are instanced across other nodes
	function InstancerFinder Nd = 
	(
		undo on
		(
			try
			(
				InstacedModList = #()
				InstacedModListNames = #()
				for i = 1 to Nd.modifiers.count do
				(
					if (refs.dependentNodes (Nd.modifiers[i])).count != 1 do
					(
						append InstacedModList Nd.modifiers[i]
						append InstacedModListNames Nd.modifiers[i].name
					)
				)
				modlist.items = InstacedModListNames
			)
			catch
			(
				catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)
	-- function for selecting the nodes that share the selected instanced modifier
	function InstanceSelect = 
	(
		undo on
		(
			try
			(
				ObjSelection = #()
				if InstacedModList.count != 0 do
				(
					CurrentMod = InstacedModList[modlist.selection]
					for i in objects do
					(
						if i.modifiers.count > 0 do
						(
							for j = 1 to i.modifiers.count do
							(
								if i.modifiers[j] == CurrentMod do
								(
									append ObjSelection i
								)
							)
						)
					)
					select ObjSelection
				)
			)
			catch
			(
				catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)
	-- the buttons
	on ObjSel picked obj do
	(
		ObjSel.text = obj.name
		InstancerFinder obj
	)
	on SelInsModButton pressed do
	(
		InstanceSelect()
	)
)
AddSubRollout MakeToolbox.theSubrollout SelModInstToolModule
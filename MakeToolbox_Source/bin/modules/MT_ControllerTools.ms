/*
--**********************************************************************************--
--                                                                                  --
--                                CONTROLLER TOOLS                                  --
--                                                                                  --
--**********************************************************************************--

#NAME: Controller Tools
#VERSION: 1.2
#LAST UPDATED: 2025.08.11

#DESCRIPTION:
A utility to quickly zero out, clear, copy, and paste object controllers. It provides
options to freeze transforms, set skin poses, and save or load transform data to or 
from an external file.

#INSTRUCTIONS:
Select one or more objects. Use "Zero" to add new empty controllers or "Clear" to reset
them to default controllers. Use the "Copy" and "Paste" buttons (or "Save" and "Load"
when the checkbox is enabled) to transfer transform data between objects.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Controller_Tools

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
    - David Almeida (david.almeida@makevisual.com): Script cleanup and modernization.

#HISTORY:
    - v1.2 (2025.08.11): Fixed tooltips and cleaned up the codebase.
    - v1.1 (2014.01.06): Renamed buttons and added versioning.
    - v1.0 (2012.03.27): Initial release.

--**********************************************************************************--
*/
controllerToolsVer = 01.2
try(removeSubRollout MakeToolbox.theSubrollout controllerToolsModule)catch()

rollout controllerToolsModule ("Controller Tools v." + (controllerToolsVer as string))
(
	groupbox controlerSetupGroupbox "Controlers Setup" width:160 height:55 offset:[-11,-3] 
	button zeroControlersButton "Zero" width:76 height:20  align:#left offset:[-7,-45] tooltip:"Creates new list controllers and creates a new set of controllers for position and rotation."
	button clearControlersButton "Clear" width:76 height:20 align:#left offset:[69,-25] tooltip:"Removes previous list controllers and returns the node to single PRS tracks."
	checkbox freezeTransformsCheckBox "Freeze Transforms" offset:[-7,-3] checked:true tooltip:"Together with 'Zero', sets the skin pose and sets frozen tracks. Together with Clear, effectivelly do a 'Freeze Transforms'"
	
	groupbox CopyControlersGroupbox "Copy Transforms Controler" width:160 height:55 offset:[-11,-0] 
	button copyTransformsButton "Copy" width:76 height:20  align:#left offset:[-7,-45] tooltip:"Copies/saves the current object transform."
	button pasteTransformsButton "Paste" width:76 height:20 align:#left offset:[69,-25] tooltip:"Pastes/loads the stored transforms on the object."
	checkbox saveToFileCheckbox "Save to / Load from File" offset:[-7,-3] tooltip:"Toggles between Copy/Paste to Save/Load the transforms."

	function freezeAndSkinSet currentObject =
	(
		currentObject.position.controller = position_list()
		--currentObject.position.controller[1].controller = bezier_position()
		currentObject.position.controller[2].controller = position_xyz()
		
		currentObject.rotation.controller = rotation_list()
		currentObject.rotation.controller[2].controller = euler_xyz()
		
		currentObject.position.controller.setname 1 "Frozen Position" 		
		currentObject.position.controller.setname 2 "Zero Pos XYZ"
		currentObject.position.controller.active = 2
		currentObject.rotation.controller.setname 1 "Frozen Rotation" 		
		currentObject.rotation.controller.setname 2 "Zero Euler XYZ"
		currentObject.rotation.controller.active = 2

		currentObject.setskinpose()
	)
	
	function zeroControllersFunction =
	(
		try
		(
			for i in 1 to selection.count do
			(
				selection[i].pos.controller = position_list ()
				selection[i].pos.controller.Available.controller = Position_XYZ ()
				selection[i].rotation.controller = rotation_list ()
				selection[i].rotation.controller.Available.controller = Euler_XYZ ()
				
				if freezeTransformsCheckBox.checked == true then
				(
					freezeAndSkinSet selection[i]
				)
			)
		)catch(Messagebox "unexpected error")
	)

	function clearControlersFunction =
	(
		Try
		(
			for i in 1 to selection.count do
			(
				selection[i].pos.controller = Position_XYZ ()
				selection[i].rotation.controller = Euler_XYZ ()
				
				if freezeTransformsCheckBox.checked == true then
				(
					freezeAndSkinSet selection[i]
				)
			)
		)catch(Messagebox "unexpected error")
	)
	
	function transformsCopyFunction saveFileVal =
	(
		try
		(
			-- builds the global arrays needed to store the transfoms matrix array in the clipboard
			global transformsShuttle = #()
			global selectionHolder = #()
			selectionHolder = selection as array 
			
			 for i in 1 to selectionHolder.count do
			(
				-- adds selection to the array, to be stored
				select selectionHolder[i]
				transformsShuttlePiece = $.transform
				append transformsShuttle #(transformsShuttlePiece)
			)

			if saveFileVal == true then
			(
				try
				(
					TransformsFileName = GetSaveFileName filename:"c:/transforms.txt" types:"text(*.txt)"
					if TransformsFileName != undefined then
					(
						-- adds stored transforms to the file and saves
						TransformsFile = createfile TransformsFileName	
						format "%" transformsShuttle to:TransformsFile
						close TransformsFile
						edit TransformsFileName
						
					)else()	-- if you cancel save
				)catch(Messagebox "unexpected error")
			)else()
			
			select selectionHolder
			
		)catch(Messagebox "unexpected error")
	)
	
	function transformsPasteFunction saveFileVal =
	(
	undo on(
		try
		(
			global selectionHolder = #()
			selectionHolder = selection as array 
			
			if saveFileVal == false then -- READS FROM MEMORY
			(
				for i in 1 to selectionHolder.count do
				(
					try
					(
						transformsShuttlePiece = transformsShuttle[i]
						select selectionHolder[i]
						$.transform = transformsShuttlePiece[1]
					)catch()
				)
			)
			else -- READS FROM FILE
			(
			transformsFileName = getopenfilename ()
			transformsFile = openfile transformsFilename
			execute transformsFile

			for i in 1 to selectionHolder.count do
				(
				try(
					transformsShuttlePiece = transformsShuttle[i]
					select selectionHolder[i]
					$.transform = transformsShuttlePiece[1]
					)catch()
				)
			)
		)catch(Messagebox "unexpected error")
	)
	)
	
	on zeroControlersButton pressed do
	(
		zeroControllersFunction()
	)
	
	on clearControlersButton pressed do
	(
		clearControlersFunction()
	)
	
	on copyTransformsButton pressed do
	(
		transformsCopyFunction saveToFileCheckbox.checked
	)
	
	on pasteTransformsButton pressed do
	(
		undo on(
		transformsPasteFunction saveToFileCheckbox.checked
		)
	)
	
	on saveToFileCheckbox changed state do
	(
	if saveToFileCheckbox.checked == true then
		(
		copyTransformsButton.text = "Save"
		pasteTransformsButton.text = "Load"
		)
		else
		(
		copyTransformsButton.text = "Copy"
		pasteTransformsButton.text = "Paste"
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout controllerToolsModule
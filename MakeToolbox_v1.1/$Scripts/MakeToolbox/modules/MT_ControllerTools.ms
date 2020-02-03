/*
#NAME:AE Position Exporter
#VERSION:1.0
#INSTRUCTIONS:Copy Paste Reset and Clear an objects controller, as well as optionally setting the transforms and skin poses to zero. Simple common task time saver.
http://www.makevisual.com/learning/MT_ControllerTools.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY: 03.27.2012 >> Release
*/
--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.27.2012 >> Release -ad
--*****************************************************
controllerToolsVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout controllerToolsModule)catch()

rollout controllerToolsModule ("Controller Tools")
(
	groupbox controlerSetupGroupbox "Controlers Setup" width:160 height:55 offset:[-11,-3] 
	button zeroControlersButton "Zero" width:76 height:20  align:#left offset:[-7,-45] tooltip:"Lock or Unlock all cameras in the scene."
	button clearControlersButton "Clear" width:76 height:20 align:#left offset:[69,-25] tooltip:"Lock or Unlock all objects in the scene."
	checkbox freezeTransformsCheckBox "Freeze Transforms" offset:[-7,-3] checked:true
	
	groupbox CopyControlersGroupbox "Copy Transforms Controler" width:160 height:55 offset:[-11,-0] 
	button copyTransformsButton "Copy" width:76 height:20  align:#left offset:[-7,-45] tooltip:"Lock or Unlock all cameras in the scene."
	button pasteTransformsButton "Paste" width:76 height:20 align:#left offset:[69,-25] tooltip:"Lock or Unlock all objects in the scene."
	checkbox saveToFileCheckbox "Save to / Paste from File" offset:[-7,-3]

	function freezeAndSkinSet currentObject =
	(
		currentObject.position.controller = position_list()
		currentObject.position.controller[2].controller = position_xyz()
		
		currentObject.rotation.controller = rotation_list()
		currentObject.rotation.controller[2].controller = euler_xyz()
		
		currentObject.position.controller.setname 1 "Frozen Position" 		
		currentObject.position.controller.setname 2 "Zero Position XYZ"
		currentObject.position.controller.active = 2
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
)
AddSubRollout MakeToolbox.theSubrollout controllerToolsModule
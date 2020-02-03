--Destroys dialog if it exists
try(destroyDialog MakeToolboxSettingsdialog)catch()


function updateFilesFunction =
(
global MTBScripts = getfiles "$Scripts\\MakeToolbox\\presets\\*.ms"
global theCurrentScript=MTBScripts[1]
global MTBScriptNames=#()
global currentModulesArray = #()
global numberOfScripts = MTBScripts.count

for j in 1 to numberOfScripts do (join MTBScriptNames #((getFilenameFile MTBScripts[j])))
)

updateFilesFunction()

rollout MakeToolboxSettingsdialog "Tab Presets" width:225 height:174
(
	groupbox choosePresetGroup "Choose Preset" offset:[-8,-2] width:214 height:70
	Dropdownlist theDrop "" items:MTBScriptNames width: 200  offset:[0,-55]
	button choosePresetButton "Apply" width:150 align:#left offset:[0,-6]
	button deletePresetButton "Delete"  width:50 align:#left offset:[150,-26]
	
	groupbox createPresetGroup "Create Preset" offset:[-8,10] width:214 height:90
	button clearPanelButton "Clear Panel" width:100 align:#left offset:[-3,-78]
	button addModuleToPresetButton "Add Module" width:100 align:#left offset:[100,-26]
	edittext presetEditText text:"Custom_Preset_01" align:#left width:204 offset:[-4,0]
	button savePresetButton "Save Current as Preset" width:200 align:#left offset:[0,-5]
	
	function deletePresetFunction =
	(
	if querybox "are you sure you want to delete the selected script ?" == true then
		(
		try(deletefile theCurrentScript)catch()
		)
		else()
	updateFilesFunction()
	theDrop.items = MTBScriptNames	
	)
	
	on deletePresetButton pressed do
	(
		deletePresetFunction()
	)
	
	function savePresetFunction = 
	(
	newFileName = @"$Scripts\MakeToolbox\presets\" + presetEditText.text +".ms"
	print newFileName
	if (doesfileexist newFileName) == false then
		(
		print currentModulesArray
		FileString = ""
		for i in 1 to currentModulesArray.count do
			(
			print i
			FileString = FileString+ "
try(filein \"" + currentModulesArray[i] +"\") catch()
"
			)
		newFile = createFile newFileName
		format  FileString to:newFile
		close newFile
		)
		else(messagebox "Preset already exists, pick a new name.")
	updateFilesFunction()
	theDrop.items = MTBScriptNames	
	)
	
	on theDrop selected i do
		(
		theCurrentScript=MTBScripts[i]
		print theCurrentScript
		)
	
	on choosePresetButton pressed do
		(
		filein theCurrentScript
		try(destroyDialog MakeToolboxSettingsdialog)catch()
		)
		
	on clearPanelButton pressed do
		(
		for i in 1 to MakeToolbox.theSubrollout.rollouts.count do
			(
			removeSubRollout MakeToolbox.theSubrollout MakeToolbox.theSubrollout.rollouts[MakeToolbox.theSubrollout.rollouts.count]
			)
		)
		
	on addModuleToPresetButton pressed do
		(
		global scriptmanager_open
		filein "$Scripts\MakeToolbox\MakeToolboxScriptmanager.ms"
		scriptManager_open (modulesDirectory + "\\") buttonText:"Add Module" titleText:"Choose module to add"
		)
		
	on savePresetButton pressed do
		(
		savePresetFunction()
		updateFilesFunction()
		theDrop.items = MTBScriptNames	
		)
)

createDialog MakeToolboxSettingsdialog
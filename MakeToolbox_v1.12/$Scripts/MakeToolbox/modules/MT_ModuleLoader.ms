--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 12.07.2012 >> Release -ad
--*****************************************************

ModuleLoaderModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout ModuleLoaderModule)catch()

ScriptNames=#()
Scripts=#()

rollout ModuleLoaderModule ("Module Loader v" + (ModuleLoaderModuleVer as string))
(
	dropdownlist theDrop items:ScriptNames height:100 width:137 tooltip:"Select your script from the dropdown." offset:[-10,-3]
	button clearModules " C" width:19 height:19 tooltip:"Edits the chosen script." pos:[140,5]
	
	fn FN_updateTheDrop =
		(
		Scripts = getfiles (getdir #maxRoot + "\\Scripts\\MakeToolbox\\modules\\*.ms")
		theCurrentScript=Scripts[1]
		ScriptNames=#()
		numberOfScripts = Scripts.count
				
		for j in 1 to numberOfScripts do (join ScriptNames #((substring (getFilenameFile Scripts[j]) 4 1000 )))
				
		theDrop.items = ScriptNames
		)
		
	fn FN_removeRollouts =
		(
		for i in 1 to MakeToolbox.theSubrollout.rollouts.count do
			(
			removeSubRollout MakeToolbox.theSubrollout MakeToolbox.theSubrollout.rollouts[MakeToolbox.theSubrollout.rollouts.count]
			)
		)
	
	on theDrop selected i do
		(
		theCurrentScript=Scripts[i]
		filein theCurrentScript
		)
		
	on clearModules pressed do
		(
		FN_removeRollouts()
		filein ((getdir #scripts) + "\MakeToolbox\modules\MT_ModuleLoader.ms")
		)
	
	on ModuleLoaderModule open do
		(
		FN_updateTheDrop()
		)
)
AddSubRollout MakeToolbox.theSubrollout ModuleLoaderModule
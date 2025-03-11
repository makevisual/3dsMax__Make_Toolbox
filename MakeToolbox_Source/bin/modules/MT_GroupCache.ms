/*
#NAME:TurntableMaker
#VERSION:1.0
#INSTRUCTIONS:
Make a turntable.
#SOURCE:Romain Faure, rf.romainfaure@gmail.com
#HISTORY: 05.30.2012 >> Release Beta v1.00
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Romain Faure rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.30.2012 >> Release Beta v1.10
--****************************************************
BakerToolModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout BakerToolModule)catch()

MaxSceneFile = (maxFilePath + maxFileName)
CopyObjects = #()
BtnPathValue = maxFilePath
AssetTextValue = ""
FileNamePrefix = "_PointCache"
ProgressBarValue = 0

RecordStartValue = animationRange.start
RecordEndValue = animationRange.end

ScenesDir = undefined
CachesDir = undefined
ObjWithModifier = #()
ObjModifiers = #()
ObjPointCache = #()
ObjTransformBake = #()

fn FnListXForm =
	(
		ObjWithModifier = #()
		ObjTransformBake = #()
		
		for i = 1 to selection.count do 
		(	
			ObjModifiers = #()
			for j = 1 to selection[i].modifiers.count do 
			(
				append ObjModifiers (classof selection[i].modifiers[j])
			)
			
			if finditem ObjModifiers Skin == 0 then --- Search Skin/Sinwrap in modifers stack 
				( 
					if finditem ObjModifiers Skin_Wrap == 0 then
						(append ObjTransformBake selection[i])
					else 
						(
							if finditem ObjModifiers XForm == 0 then --- Search Xform in modifers stack
								(append ObjWithModifier selection[i])
						)
				)
			else 
				(
					if finditem ObjModifiers XForm == 0 then --- Search Xform in modifers stack
						(append ObjWithModifier selection[i])
				)
		)
		
		MsgBoxTextTitle = "These following objects don't have an Xform modifier:"
		MsgBoxTextBody = ""
		MsgBoxTextFoot = "You need to had one first."
-- 		
		if ObjWithModifier.count != 0 then 
			(
			for i = 1 to ObjWithModifier.count do  
				(
					MsgBoxTextBody += "\n" + (ObjWithModifier[i].name) as string + "."
				)
				messageBox (MsgBoxTextTitle + "\n "+ MsgBoxTextBody + "\n\n" + MsgBoxTextFoot) title:"BakeTool"	
			)
		else(return true)
	)	

	
fn FnBaketransform =
	(
			disableSceneRedraw()
			
			GlobalPoint  = point ()
					
			oldAnimationRange = animationRange
			animationRange = interval RecordStartValue RecordEndValue
			oldSliderTime = sliderTime
				
			StoredSelection = selection
				
			for j = 1 to selection.count do
				(
				
				select = storedSelection
				theanimatedobject = selection[j]
				
				if theanimatedobject != undefined then
					(
						
					theNewPoint = Point pos:[0,0,0] size:70 Box:on cross:on axistripod:off centermarker:off wirecolor:red
						
					sliderTime = RecordStartValue
						
					max tool animmode
					set animate on
						
						
					 for i = RecordStartValue to RecordEndValue do
						(
						theNewPoint.transform = theAnimatedObject.transform
						
						currentFrameText = "	"+((currentTime as integer)/TicksPerFrame) as string
						print currentFrameText
						
						sliderTime =(sliderTime+1)
						)
						
					max tool animmode
					set animate off

						theanimatedobject.parent = globalpoint
							
						posCtrl = theNewPoint.pos.controller
						rotCtrl = theNewPoint.rotation.controller
						scaleCtrl = theNewPoint.scale.controller
						theAnimatedObject.pos.controller = posCtrl
						theAnimatedObject.rotation.controller = rotCtrl
						theAnimatedObject.scale.controller = scaleCtrl
							
						delete theNewPoint
						
					)
				
				ProgressBarValue = 100.*j/selection.count
				progressUpdate ProgressBarValue
					
				)

				delete GlobalPoint
			ProgressBarValue = 0
			animationRange = oldAnimationRange 
			SliderTime = oldSliderTime		
			theanimatedobject = "undefined"	
			enableSceneRedraw()
	)
	
fn FnExportCreatePointCache = 
	(
		disableSceneRedraw()
		AllObjectsSelected = selection as array
	
		for i = 1 to AllObjectsSelected.count do 
			(
				ObjectModifiersArray = AllObjectsSelected[i].modifiers
				ModifierIndexAt = 0
				
				ProgressBarValue = (100.0*(i/AllObjectsSelected.count))
				progressUpdate ProgressBarValue
				
				for j = 1 to ObjectModifiersArray.count do
					(
					if ObjectModifiersArray[j] == ObjectModifiersArray["XForm"]
						then exit (ModifierIndexAt  = j)
					)

					addModifier AllObjectsSelected[i](Point_Cache ()) before:(ModifierIndexAt) --- ModifierIndexAt  == 4 (in my test scene)
					AllObjectsSelected[i].modifiers[#Point_Cache].filename = (CachesDir + "\\" + ((AllObjectsSelected[i].name) as string) + ".xml")
					AllObjectsSelected[i].modifiers[#Point_Cache].recordStart = RecordStartValue
					AllObjectsSelected[i].modifiers[#Point_Cache].recordEnd = RecordEndValue
					cacheOps.RecordCache AllObjectsSelected[i].modifiers[#Point_Cache]
							
						copy AllObjectsSelected[i] isselected:on -- Copy source object and keep it selected
						maxOps.CollapseNodeTo $ (ModifierIndexAt+2) off -- Collapse all Modifiers stack under point cache (needed for make point cache working)
						$.name = ("PCObject_" + (AllObjectsSelected[i].name as string))
						$.wirecolor = blue
						append CopyObjects $ -- Copy of source in an array (to delete later)
						deletemodifier AllObjectsSelected[i] (ModifierIndexAt+1) -- Delete point cache on source object	
			
			)
		enableSceneRedraw()
	)

fn FnExportPointCacheScene  = 
	(
		disableSceneRedraw()
		unfreeze objects
		select objects
		deselect CopyObjects
		delete $
		savemaxfile (ScenesDir + "\\" + AssetTextValue + FileNamePrefix +".max")
		enableSceneRedraw()
		progressEnd()
		--loadMaxFile MaxSceneFile
	
	)

fn FnExportUpdatePointCache = 
	(
		disableSceneRedraw()
		delete CopyObjects
		enableSceneRedraw()
		progressEnd()
	)		

fn FnImportReload = 
	(
		
		for i = 1 to selection.count do 
		(
			ObjectModifiersArray = selection[i].modifiers
			ModifierIndexAt = 0

			for j = 1 to ObjectModifiersArray.count do
				(
					if ObjectModifiersArray[j] == ObjectModifiersArray["PointCache"]
						then exit (ModifierIndexAt  =  j)
				)
			
			modPanel.setCurrentObject selection[i].modifiers[ModifierIndexAt+1]
			cacheOps.Reload selection[i].modifiers[ModifierIndexAt+1]
			clearSelection()
		)
	)
	
fn FnCreateFolder =
	(
		makeDir (BtnPathValue + "\\" + "Scenes")
		makeDir (BtnPathValue + "\\" + "Caches")
		ScenesDir = (BtnPathValue + "\\" + "Scenes")
		CachesDir = (BtnPathValue + "\\" + "Caches")
	)
	
fn FnCheck = 
	(
		if AssetTextValue != ("XXX") and AssetTextValue != "" then 
			(
				return true
			)
		else 
			(
			 messageBox ("No asset name defined.")
			)
		
	)

rollout BakerToolModule ("Group Cache")
(
	groupbox ExportGpB "Export" width:152 height:117 offset:[0,-5] align:#center 
	groupbox OutputGpB "Settings" width:140 height:96 offset:[0,-109] align:#center 
	
	label OutputTextLabel "Output Path:" align:#left offset:[5,-82]
	button BtnPath "Browse" width:60 height:20 align:#right offset:[-5,-20]
	edittext OutputText text:BtnPathValue width:130 height:20 align:#left labelOnTop:true offset:[4,0] tooltip:BtnPathValue
	label AssetTextLabel "Name:" align:#left offset:[5,5]
	edittext AssetText text:AssetTextValue width:95 height:20 align:#right offset:[-5,-20] 

	--button BtnInfo "Search For"  width:135 height:20 align:#center 
	
	groupbox FrangeGpB "Frame Range" width:152 height:68 offset:[0,10] align:#center 
	spinner StartSpinner "Start" width:60 range:[0,999,RecordStartValue] type:#integer offset:[-50,-53] 
	spinner EndSpinner "End" width:60 range:[0,999,RecordEndValue] type:#integer offset:[17,-21] 
	
	button BtnPress "Record" width:138 height:20 tooltip:"Bake transforms and point cache objectd s"

	groupbox ImportGpB "Import" width:152 height:65 offset:[0,2] align:#center 
	button BtnImport "Merge File..." width:138 height:20 align:#center offset:[0,-55] 
	button BtnReload "Reload" width:138 height:20 align:#center offset:[0,0] 
	
	
	on BtnInfo pressed do 
		(
			FnBaketransform()
		)
	
	on BtnPath pressed do 
	(
		ThePath = getSavePath caption:"Choose a directory :" initialDir:maxFilePath

		if ThePath != undefined then 
			(
				BtnPathValue = ThePath
				OutputText.text = ThePath
			)
		else 
			(
				BtnPathValue = BtnPathValue
				OutputText.text = BtnPathValue
			)
	)
	
	on AssetText changed txt do 
		(
			AssetTextValue = AssetText.text
		)
	
	on StartSpinner changed StartValue do
		(
			RecordStartValue = StartSpinner.value
		)
	
	on EndSpinner change EndValue do
		(
			RecordEndValue = EndSpinner.value
		)
	
	
	on BtnPress pressed do 
	
	(
		if FnCheck() == true then
			(
		FnCreateFolder() 
		saveMaxFile maxFileName
		if selection.count != 0
		then 
		(
			if FnListXForm() == true then 
			(
					if isMaxFile (ScenesDir + "\\" + AssetTextValue + FileNamePrefix +".max") == true
				then
				(
					Qbox = queryBox("The file already exists. Do you want to overwrite it?")
					if Qbox == true then 
						(
							if BtnPathValue != "" then
								(
									--progressStart "caption" 
									FnBaketransform() FnExportCreatePointCache() FnExportPointCacheScene()
								)
							else (messageBox "No output path." title:"BakeTool")
						)
					if Qbox == false then
						(
							if BtnPathValue != "" then
								(
									--progressStart "caption" 
									FnBaketransform() FnExportCreatePointCache() FnExportUpdatePointCache()
								)
							else (messageBox "No output path." title:"BakeTool")
						)
				)
				else 
					(
						if BtnPathValue != "" then
							(
								--progressStart "caption" 
								FnBaketransform() FnExportCreatePointCache() FnExportPointCacheScene()
							)
						else (messageBox "No output path." title:"BakeTool")
					)
			)
		)
		else (messageBox "Select all object(s) that you want to point cache." title:"Ouiiiiiiiiii!") 
	)
)

	on BtnImport pressed do
	(
		MergeFile = getOpenFileName caption:"Merge File" types:"3ds Max(*.max)" filename:(ScenesDir + "\\" + AssetTextValue + FileNamePrefix +".max")

		if MergeFile != undefined then 
			(
				mergeMAXFile MergeFile #noRedraw
			)
		else 
			(
				MergeFile = ""
			)
	)
	
	on BtnReload pressed do 
	(
		if selection.count != 0 then
			( FnImportReload())
		else
			( messageBox "Select object(s)." title:"BakerTool" )
	)

)

AddSubRollout MakeToolbox.theSubrollout BakerToolModule

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 06.07.2013 >> Release -ad
--- version 1.01 : 06.18.2013 >> Added batch path setting -ad
--- version 1.02 : 09.11.2013 >> Added toggle cache modifiers -ad
--- version 1.03 : 09.11.2013 >> Fixed progressbar bugs -ad
--*****************************************************
PointCacheBatchVer = 01.03
global start = 0
global end = 10

try(removeSubRollout MakeToolbox.theSubrollout PointCacheBatchModule)catch()

rollout PointCacheBatchModule ("Point Cache Batch v" + (PointCacheBatchVer as string))
(
button cacheIt "cache selection" height:18 width:130 pos:[8,8]--offset:[-10,0]
button cacheItPath "..." height:18 width:20 pos:[138,8]
button reloadIt "reload selection" height:18 width:130 pos:[8,26]--offset:[-10,-5]
button reloadItPath "..." height:18 width:20 pos:[138,26]
checkBox timelineCheckBox "" pos:[8,50]
spinner fromTime "From" range:[-9999,9999,0] type:#integer width:58 align:#left pos:[28,50] enabled:false
spinner toTime "To" range:[-9999,9999,100] type:#integer width:53 align:#left pos:[100,50] enabled:false
button buttonCachesOnSel "turn mod on" height:18 pos:[8,70] width:75 tooltip:"turn on point cache modifiers in selection"
button buttonCachesOffSel "turn mod off"  height:18 pos:[84,70] width:75 tooltip:"turn off point cache modifiers in selection"

fn updateCommandPanel =
	(
		setCommandPanelTaskMode #create
		setCommandPanelTaskMode #modify
		enablesceneredraw()
		redrawviews()
	)
	
fn FN_FixTime_from = (if	fromTime.value > toTime.value then (toTime.value = fromTime.value))
	
fn FN_FixTime_to = (if	toTime.value < fromTime.value then (fromTime.value = toTime.value))

fn FN_CacheModsOn =
	(
		undo on
		(
			disablesceneredraw()
			modifierSelection=selection
			
			for i in modifierSelection do try 
			(
				i.modifiers["Point Cache"].enabledInViews = true
				i.modifiers["Point Cache"].enabled = true
				i.modifiers["Point Cache"].enabledInRenders = true
			)
			catch ()
		)
	updateCommandPanel()
	)
	
fn FN_CacheModsOff =
	(
		undo on
		(
			disablesceneredraw()
			modifierSelection=selection
			
			for i in modifierSelection do try 
			(
				i.modifiers["Point Cache"].enabledInViews = false
				i.modifiers["Point Cache"].enabled = false
				i.modifiers["Point Cache"].enabledInRenders = false
			)
			catch ()
		)
	updateCommandPanel()
	)
	
fn FN_ToggleTime =
	(
	if timelineCheckBox.checked == true then
		(
		fromTime.enabled = true
		toTime.enabled = true
		)
	else
		(
		fromTime.enabled = false
		toTime.enabled = false		
		)
	)
	
fn FN_CacheIt pathArg startArg endArg =
	(
	global cachePath = undefined

	global rangeToggle = 0
	if pathArg == 1 then
		(
		cachePath = getSavePath initialDir:maxFilePath
		if cachePath == undefined then (return "end" )else()
		)else()
		
	if timelineCheckBox.checked == true then
		(
		rangeToggle = 1
		start = startArg
		end = endArg
		)
		else()
		
	try(destroyDialog cacheProgressDialog)catch()

	rollout cacheProgressDialog "Point Cache Batch Progress" width:450 height:70
		(
		label currentObjectLabel "cur obj"
		label iterationLabel "iteration"
		progressbar theBar height:20
			
		function cacheSelectionFunction =
			(
			objArr = selection as array
			
			for i in 1 to objArr.count do 
				(
				taco = ("Caching: " + (objArr[i].name))
				print taco
				currentObjectLabel.text = taco--("Caching: " + (objArr[i].name))
					
				iterationLabel.text = ((i as string) + " of " + (objArr.count as string))
				theBar.value = (((i + 0.00) / objArr.count) * 100)
					
				if cachePath != undefined then
					(
					try(
						curPath = (cachePath + @"\" + objArr[i].name + ".xml" )
						objArr[i].modifiers[#Point_Cache].filename = curPath
						)catch()
					)else()

				
				if rangeToggle == 1 then
					(
					try(
					objArr[i].modifiers[#Point_Cache].recordStart = start
					objArr[i].modifiers[#Point_Cache].recordEnd = end
					)catch()
					)
					
				try(cacheOps.RecordCache objArr[i].modifiers[#Point_Cache])catch(print ("No cache recorded for " + ((objArr[i])as string)))
				)
			)	
			
		on cacheProgressDialog open do 
			(
			cacheSelectionFunction()
			try(destroyDialog cacheProgressDialog)catch()
			redrawViews()
			)	
		)
	createDialog cacheProgressDialog
	)

fn FN_ReloadIt pathArg =
	(
	global relaodPath = undefined
	if pathArg == 1 then
		(
		relaodPath = getSavePath initialDir:maxFilePath
		if relaodPath == undefined then (clearselection() )else()
		)else()
		
	try(destroyDialog cacheProgressDialog)catch()

	rollout reloadProgressDialog "Point Cache Batch Progress" width:450 height:70
		(
		label currentObjectLabel "cur obj"
		label iterationLabel "iteration"
		progressbar theBar height:20
			
		function reloadSelectionFunction =
			(
			objArr = selection as array
			max modify mode
			
			for i in 1 to objArr.count do 
				(
				currentObjectLabel.text = ("Loading: " + (objArr[i].name))
				iterationLabel.text = ((i as string) + " of " + (objArr.count as string))
				theBar.value = (((i + 0.00) / objArr.count) * 100)
				
				if relaodPath != undefined then
					(
					try(
						curPath = (relaodPath + @"\" + objArr[i].name + ".xml" )
						objArr[i].modifiers[#Point_Cache].filename = curPath
						)catch()
					)else()
				
				try(
				modPanel.setCurrentObject objArr[i].modifiers[#Point_Cache]
				cacheOps.Reload objArr[i].modifiers[#Point_Cache]
					)catch(print ("No cache loaded on " + ((objArr[i])as string)))
				)
			select objArr
			)	
			
		on reloadProgressDialog open do 
			(
			reloadSelectionFunction()
			try(destroyDialog reloadProgressDialog)catch()
			redrawViews()
			)	
		)
	createDialog reloadProgressDialog
	)
on cacheIt pressed do (FN_CacheIt 0 fromTime.value toTime.value)
on cacheItPath pressed do (FN_CacheIt 1 fromTime.value toTime.value)
on reloadIt pressed do (FN_ReloadIt 0)
on reloadItPath pressed do (FN_ReloadIt 1)
on timelineCheckBox changed state do (FN_ToggleTime())
on fromTime changed state do (FN_FixTime_from())
on toTime changed state do (FN_FixTime_to())
on buttonCachesOnSel pressed do (FN_CacheModsOn())
on buttonCachesOffSel pressed do (FN_CacheModsOff())
)
AddSubRollout MakeToolbox.theSubrollout PointCacheBatchModule
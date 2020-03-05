--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 06.07.2013 >> Release -ad
--- version 1.01 : 06.18.2013 >> Added batch path setting -ad
--- version 1.02 : 09.11.2013 >> Added toggle cache modifiers -ad
--- version 1.03 : 09.11.2013 >> Fixed progressbar bugs -ad
--- version 1.04 : 01.8.2014 >> Added testing and auto setup of the point cache modifier on a selection - ad
--- version 1.5 : 10.30.2014 >> Added automatic point cache turn on before caching - ad
--- version 1.6 : 10.30.2014 >> Added automatic point cache turn on before caching - ad
--- version 1.7 : 9.22.2015 >> Added saftey pre-cache calc for jiggle modifier bug
--- version 1.8 : 9.22.2015 >> Added 4 samples per frame override
--- version 1.9 : 9.22.2015 >> Added Match Geo modifer toggle
--- version 1.9.1 : 9.22.2015 >> Performance optimizations
--- version 1.9.1 : 2.18.2016 >> Better global scope names
--- version 1.10.1 : 2.18.2016 >> Better settings and stuff
--- version 1.11.0 : 3.24.2017 >>
---						added support for MakePoint Cache save/load and WSM pointcache support
-- 						automatically detects top valid point cache version
---						Converted all caches to use .pc2 format
---						Auto timesnap on when opened
---
---	version 1.11.1 : 4.30.2018 >> Added ui and fuction for setting .xml or .pc2 file types - NB

--*****************************************************

--todo: #Point_Cache_Binding ablility
--todo: autoTimesnap on open
--todo: convert to PC2 format

PointCacheBatchVer = "1.11.1"
global tempStartFrame = 0
global tempEndFrame = 10
global fileFormat = ".xml"

	global cachePath = undefined
	global rangeToggle = 0


try(removeSubRollout MakeToolbox.theSubrollout PointCacheBatchModule)catch()

rollout PointCacheBatchModule ("PointCacheBatch v" + (PointCacheBatchVer as string))
(
button cacheIt "cache selection" height:18 width:130 pos:[8,8]--offset:[-10,0]
button cacheItPath "..." height:18 width:20 pos:[138,8]
button reloadIt "reload selection" height:18 width:130 pos:[8,26]--offset:[-10,-5]
button reloadItPath "..." height:18 width:20 pos:[138,26]
checkBox timelineCheckBox "" pos:[8,50]
spinner fromTime "From" range:[-9999,9999,0] type:#integer width:58 align:#left pos:[28,50] enabled:false
spinner toTime "To" range:[-9999,9999,100] type:#integer width:53 align:#left pos:[100,50] enabled:false

button buttonTimeSnap "Snap to timeline" height:18 pos:[8,67] width:151
spinner spinnerSamplesPerFrame "Frames per sample" range:[0.1, 1.0, 0.25] type:#float align:#right width:130 offset:[6,0]
dropdownList ddl_fileFormat "" height:26 width:130 align:#right offset:[-3,-5] items:#(".xml", ".pc2")
checkbox chk_presim "Settle realtime dynamics" offset:[-4,-2]

button buttonCachesOnSel "cache mod on" height:18 pos:[8,150] width:75 tooltip:"turn on point cache modifiers in selection"
button buttonCachesOffSel "cache mod off"  height:18 pos:[84,150] width:75 tooltip:"turn off point cache modifiers in selection"

button buttonMatchesOnSel "match mod on" height:18 pos:[8,169] width:75 tooltip:"turn on point cache modifiers in selection"
button buttonMatchesOffSel "match mod off"  height:18 pos:[84,169] width:75 tooltip:"turn off point cache modifiers in selection"

groupbox setupGroup "Setup" width:155 height:55 offset:[-8,-2]
button buttonAddMod "Add Point Caches above Skin" height:18 width:145 align:#left offset:[-3,(-1 * setupGroup.height + 8)]
button buttonCheckMod "Test Sel. for Point Caches" height:18 width:145 align:#left offset:[-3,-5]

-- Creates the report window that allows you to operate on selected
fn FN_GroupCacheTestWindow arg =
	(
	cacheReport = arg
	global namesArr = #()
	global handlesArr = #()
		
	for i in 1 to cacheReport.count do
	(	
		if cacheReport[i][1]==true then
		(
		)
		else
		(
			curObj = maxOps.getNodeByHandle cacheReport[i][3]
			join namesArr #(curObj.name)
			join handlesArr #(cacheReport[i][3])
		)
	)		
		
		try (destroydialog reportsRollout) catch()

		rollout reportsRollout ("Point Cache Report") --Create the rollout
		(
			label lab1 "Objects without Cache Modifiers:"
			multilistbox mlb "" items:#() width:340 pos:[5,22]
			button selectAllButton "select objects" height:20 width:170 pos:[5,160]
	-- 			button selectPickedButton "select picked" height:20 width:170 pos:[175,160]
			
			on reportsRollout open do
			(
			mlb.items = namesArr
			)

			on selectAllButton pressed do 
			(
			-- print handlesArr
			clearSelection()
			
			for i in 1 to handlesArr.count do
				(
				selectMore (maxOps.getNodeByHandle handlesArr[i])
				)
			)
			
			on selectPickedButton pressed do 
			(
			)
		)
	createDialog reportsRollout 350 185 style:#(#style_titlebar, #style_border, #style_sysmenu) lockWidth:true
	)

-- Searches the object for the first point cache, make point cache, or WSM point cache modifier
fn FN_GetCacheClassModifier arg =
(
	curObj = arg

	for curMod in curObj.modifiers do
	(
		curModClass = ( classof curMod )

		if curModClass == Point_CacheSpacewarpModifier or curModClass == MAKE_Point_Cache or curModClass == Point_Cache
		then 
		(
			-- print ( ( curModClass as string ) + " is the topmost cache modifier " )
			return curMod
		)
	) 
)

-- Test passed args modifiers for the 'skin' modifier
fn FN_SkinTest arg = 
	(
	obj = arg
	for j in 1 to obj.modifiers.count do
		(
		curTest = (classof obj.modifiers[j])
		if curTest == Skin then
			(
			return #(true,j,obj.inode.handle)  -- True- PointCache modifier, j modifier index, inode.handle
			)
		else
			(
			)
		)
	return #(false,0,obj.inode.handle) -- false- no modifier, 0 modifier index
	)

-- Test passed args modifiers for the 'Point_Cache' modifier	
fn FN_CacheTest arg = 
	(
	obj = arg
	for j in 1 to obj.modifiers.count do
		(
		print obj.modifiers[j]
		curTest = (classof obj.modifiers[j])
		if curTest == Point_Cache then
			(
			return #(true,j,obj.inode.handle)  -- True- PointCache modifier, j modifier index, inode.handle
			)
		else
			(
			)
		)
	#(false,0,obj.inode.handle) -- false- no modifier, 0 modifier index	
	)
	
fn FN_addCacheFail arg =
	(
	cacheReport = arg
	global namesArr = #()
	global handlesArr = #()
		
	for i in 1 to cacheReport.count do
	(	
		if cacheReport[i][1]==true
		then()
		else
		(
			curObj = maxOps.getNodeByHandle cacheReport[i][3]
			join namesArr #(curObj.name)
			join handlesArr #(cacheReport[i][3])
		)
	)		
		try (destroydialog reportsRollout) catch()
	
		rollout reportsRollout ("Point Cache Report") --Create the rollout
		(
			label lab1 "Objects without Skin Modifiers:"
			multilistbox mlb "" items:#() width:340 pos:[5,22]
			button selectAllButton "select objects" height:20 width:170 pos:[5,160]
			
			on reportsRollout open do(mlb.items = namesArr)
			on selectAllButton pressed do 
			(
			-- print handlesArr
			clearSelection()
			
			for i in 1 to handlesArr.count do
				(
				selectMore (maxOps.getNodeByHandle handlesArr[i])
				)
			)
			on selectPickedButton pressed do 
			(
			)
		)
	createDialog reportsRollout 350 185 style:#(#style_titlebar, #style_border, #style_sysmenu) lockWidth:true
	)

fn FN_addCachePass =
	(
		try (destroydialog addCachePassRoll) catch()

		rollout addCachePassRoll ("Add Point Caches - Success") --Create the rollout
		(
		label lab0 ""
		Label lab1 "Point cache(s) were successfully"
		Label lab2 "to any objects without them."
		)
	createDialog addCachePassRoll 250 90 style:#(#style_titlebar, #style_border, #style_sysmenu) lockWidth:true
	)

-- puts a pointCache modifier in an objects stack, above the skin modifier, if it has one
fn FN_addCache arg1 arg2 =
	(
	failArr = #()
	objArr = arg1 -- the objects to operate on
	skinReports = arg2 -- the reports on weather they have skin or not
	
	for i in 1 to objArr.count do
		(
		
		if skinReports[i][1] == true -- Checks if the object has a skin modifier
		then -- if it has a skin modifier
			(
			-- Test for existing point cache modifier
			curTest = FN_CacheTest objArr[i]
			if curTest[1] == true -- If the object already has a point cache mod
			then () -- skip it
			else -- Put one on
				(
				newCache = pointCache()
				addmodifier objArr[i] newCache before:(skinReports[i][2] - 1) -- Apply to the right place in the stack
				)
			)
		else (join failArr #(skinReports[i]))-- if it does not have a skin modifier
		)
	if failArr.count == 0 -- checks if the script was unable to apply a point cache modifier
	then (FN_addCachePass()) -- launch the success window
	else (FN_addCacheFail failArr) -- launch the reporter window, with failed objects in it
	
	)
	
fn FN_AutoAddMod =
	(
		
	skinReports = #()

	objArr = selection as array
	for i in 1 to objArr.count do
		(
		skinReport = FN_SkinTest objArr[i]
		print (skinReport as string)
		join skinReports #(skinReport)
		)
	print (skinReports as string)
		
	-- Add point cache modifier modifiers to objects that have a skin modifier
	FN_addCache objArr skinReports
	)
	
fn FN_GroupCacheTest =
	(
	cacheReports = #()
	objArr = selection as array
	for i in 1 to objArr.count do
		(
		cacheReport = FN_CacheTest objArr[i]
		join cacheReports #(cacheReport)
		)
	FN_GroupCacheTestWindow cacheReports
	)	

fn updateCommandPanel =
	(
		setCommandPanelTaskMode #create
		setCommandPanelTaskMode #modify
		enablesceneredraw()
		redrawviews()
	)
	
fn FN_FixTime_from = (if	fromTime.value > toTime.value then (toTime.value = fromTime.value))
	
fn FN_FixTime_to = (if	toTime.value < fromTime.value then (fromTime.value = toTime.value))

fn FN_MatchModsOn =
	(
		undo on
		(
			disablesceneredraw()
			modifierSelection=selection
			
			for i in modifierSelection do try 
			(
				i.modifiers["MAKE Match Geo"].enabledInViews = true
				i.modifiers["MAKE Match Geo"].enabled = true
				i.modifiers["MAKE Match Geo"].enabledInRenders = true
			)
			catch ()
		)
	updateCommandPanel()
	)

fn FN_MatchModsOff =
	(
		undo on
		(
			disablesceneredraw()
			modifierSelection=selection
			
			for i in modifierSelection do try 
			(
				i.modifiers["MAKE Match Geo"].enabledInViews = false
				i.modifiers["MAKE Match Geo"].enabled = false
				i.modifiers["MAKE Match Geo"].enabledInRenders = false
			)
			catch ()
		)
	updateCommandPanel()
	)

fn FN_CacheModsOn =
	(
		undo on
		(
			disablesceneredraw()
			modifierSelection=selection
			
			for i in modifierSelection do try 
			(
				curMod = FN_GetCacheClassModifier i

				curMod.enabledInViews = true
				curMod.enabled = true
				curMod.enabledInRenders = true
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
				curMod = FN_GetCacheClassModifier i

				curMod.enabledInViews = false
				curMod.enabled = false
				curMod.enabledInRenders = false
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

	if chk_presim.checked 
	then
	(
		FN_CacheModsOff()
		slidertime = animationrange.start
		val = 1
		for j in 1 to 100 do
		(
			slidertime = slidertime+val
			val *= -1
			--print j
		)
	)
	else()


		
	if pathArg == 1 then
	(
		cachePath = getSavePath initialDir:maxFilePath
		if cachePath == undefined
		then
		(
			return "end" 
		)
		else
		(
			FN_CacheModsOn()
			FN_MatchModsOn()
		)
	)else()
		
	if timelineCheckBox.checked == true then
		(
		rangeToggle = 1
		tempStartFrame = startArg
		tempEndFrame = endArg
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

			FN_CacheModsOn()
			
			for i in 1 to objArr.count do 
			(

				curMod = FN_GetCacheClassModifier objArr[i]
				--print curMod

				taco = ("Caching: " + (objArr[i].name))

				currentObjectLabel.text = taco--("Caching: " + (objArr[i].name))
					
				iterationLabel.text = ((i as string) + " of " + (objArr.count as string))
				theBar.value = (((i + 0.00) / objArr.count) * 100)

				curMod.loadType = 1
					
				if cachePath != undefined then
				(
					try(
						curPath = (cachePath + @"\" + objArr[i].name + fileFormat )
						curMod.filename = curPath
					)catch()
				)else()

				
				if rangeToggle == 1 then
				(
					try(
						curMod.recordStart = tempStartFrame
						curMod.recordEnd = tempEndFrame
					)catch()
				)
				
 				--objArr[i].modifiers[#Point_Cache].sampleRate = spinnerSamplesPerFrame.value
 				curMod.sampleRate = spinnerSamplesPerFrame.value

					-- DO THE RECORD --
				case of
				(
					(classof curMod == Point_CacheSpacewarpModifier):
						(
							--print "WSM"
							cacheOps.RecordCache curMod --objArr[i].modifiers[#Point_Cache]
						)
					(classof curMod == MAKE_Point_Cache):
						(
 							--print "MAKE PC"
							makeCacheOps.RecordCache curMod --objArr[i].modifiers[#Point_Cache]
						)
					(classof curMod == Point_Cache):
						(
 							--print "PC"
							cacheOps.RecordCache curMod --objArr[i].modifiers[#Point_Cache]
						)	
				)
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
	
	FN_MatchModsOff()
	
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

				curMod = FN_GetCacheClassModifier objArr[i]

				currentObjectLabel.text = ("Loading: " + (objArr[i].name))
				iterationLabel.text = ((i as string) + " of " + (objArr.count as string))
				theBar.value = (((i + 0.00) / objArr.count) * 100)
				
				if relaodPath != undefined then
					(
  					try(
						curPath = (relaodPath + @"\" + objArr[i].name + fileFormat )

						curMod.filename = curPath
						curMod.enabledInViews = true
						curMod.enabled = true
						curMod.enabledInRenders = true
						curMod.loadType = 1

  						)catch()
					)else()
				
				try(
				modPanel.setCurrentObject curMod --objArr[i].modifiers[#Point_Cache]
				cacheOps.Reload curMod --objArr[i].modifiers[#Point_Cache]
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

fn FN_SnapToTimeline mode = 
(

	fromTime.value = ( animationrange.start ) -- as integer
	toTime.value = ( animationrange.end ) -- as integer

	if mode == 2 then 
		(
		timelineCheckBox.checked = true
		fromTime.enabled = true
		toTime.enabled = true
		)
)
	
on cacheIt pressed 					do (FN_CacheIt 0 fromTime.value toTime.value)
on cacheItPath pressed 				do (FN_CacheIt 1 fromTime.value toTime.value)
on reloadIt pressed 				do (FN_ReloadIt 0)
on reloadItPath pressed 			do (FN_ReloadIt 1)
on timelineCheckBox changed state 	do (FN_ToggleTime())
on fromTime changed state 			do (FN_FixTime_from())
on toTime changed state 			do (FN_FixTime_to())

on buttonTimeSnap pressed 			do (FN_SnapToTimeline 2 )
on ddl_fileFormat selected state do
(
	if state == 2 then
	(
		fileFormat = ".pc2"
	)
	else if state == 1 then
	(
		fileFormat = ".xml"
	)

) 

on buttonCachesOnSel pressed 		do (FN_CacheModsOn())
on buttonCachesOffSel pressed 		do (FN_CacheModsOff())

on buttonMatchesOnSel pressed 		do (FN_MatchModsOn())
on buttonMatchesOffSel pressed 		do (FN_MatchModsOff())

on buttonAddMod pressed 			do (FN_AutoAddMod())
on buttonCheckMod pressed 			do (FN_GroupCacheTest())

on PointCacheBatchModule open do ( FN_SnapToTimeline 2 )
)
AddSubRollout MakeToolbox.theSubrollout PointCacheBatchModule
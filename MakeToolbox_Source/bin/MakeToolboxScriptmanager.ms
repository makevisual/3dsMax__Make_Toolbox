/*
---see BELOW for instructions on how to run this script properly from within the maketoolbox sidebar

---Also, the following text shows an example of the syntax required for the script manager to display proper
---script info in its info panel. Note that this information can appear in the selected script itself,
---or in any file within the selected script's folder, that has the same name as the selected script
---but a different extension. 
---Most importantly, the info MUST be contained within two comment brackets. Ie,  /* . . . */

/*
#NAME:Script Manager
#VERSION:1.0
#INSTRUCTIONS:
The script manager is a tool to view a list of scripts within a particular directory.
You can run the scripts from within the manager, or view info about them in this side panel.
#SOURCE:Tyson Ibele http://www.tysonibele.com
#HISTORY:03.23.2012 >> Completed version 1.0

*/

dotNet.loadAssembly "MaxCustomControls.dll"

try (scriptManager.hide())catch()


global ScriptManager_Ver = (1.0 as string)
global ScriptManager
global ScriptManager_iconStr
global sm_searchBar
global sm_setIcons
global sm_runScript
global sm_folderRoot
global sm_walkDirectory
global sm_updateFolderStruct
	
----this is the root directory that the script manager will get the list of scripts from
----NOTE: this variable is assigned whatever path you send to the "scriptManager_open" function,
-------------so you don't necessarily have to change this variable directly. Just pass the correct
-------------path name to the "scriptManager_open" open function when you run it and this variable
-------------will be updated accordingly
	
struct folderNode
(
	folderName,
	folderParent,
	subFolders = #(),
	files = #(),
	matchesPattern = false 
)

-----THE FOLLOWING LINE OPENS THE SCRIPT MANAGER.
-----[buttonText] is what you want the run button to say
-----[titleText] is what you want the title bar of the window to say
-----if those arguments are not included in the function call, the button/title will retain its original text

-----this function is called once at the very bottom of this script! Remove that function call once you're ready to implement this into the maketoolbox sidebar
fn scriptManager_open sDir buttonText:"" titleText:""=
(
	try (scriptManager.hide())catch()
		
	ScriptManager_scriptDir = sDir
	
	ScriptManager.ShowModeless()
	
	sm_folderRoot = folderNode()
	sm_folderRoot.folderName = scriptManager_scriptDir
	sm_walkDirectory sm_folderRoot
	
	sm_folderRoot.folderName = ""
	
	sm_updateFolderStruct sm_searchBar.text false
	
	
	
	
	if titleText != "" then (scriptmanager.text = titleText)
	if buttonText != "" then sm_runScript.text = buttonText
	

	sm_setIcons()
	sm_searchBar.focus()
	
)



(
	
	iconStr = ""
	iconImg = undefined
	maxFolderDepth = 1 --this sets max folder search depth!
	folderDepth = 0
	
	--start Declare functions
	setRightControls
	rSplitter
	strToBit
	folderNameFromPath
	recurseMatchUp
	resetStruct
	cullStruct
	countParents
	sm_walkDirectory
	FillInTreeView
	sm_updateFolderStruct
	setInfobox
	setIcons
	--End declare functions

	leftControls = #()
	lastSizeY = 0
	oldSizeY = 0
	mOffset = [0,0]
	lastMPos = [0,0]
	resizeSplitter = false		
	minimized = false
	minimizing = false
	oldWidth = 0
	lastSize 
	sizeDelta = 0
	sm_folderRoot = undefined
	oldSizeY = 0
	sizeYDelta = 0
	WM_SETREDRAW=0xB
	h = undefined
	
	splitter = dotNetObject "Label"
	splitter.location = dotNetObject "System.Drawing.Point" 198 -2
	splitter.width = 5
	splitter.height = 520
	splitter.enabled = false
	splitter.backColor = (dotnetclass "System.Drawing.Color").fromARGB 180 180 180 
	splitter.autoSize = false
		
	clearText = dotNetObject "Button"
	clearText.location = dotNetObject "System.Drawing.Point" 177 265
	clearText.text = "X"
	clearText.width = 20
	clearText.height = 20
	clearText.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").flat
	clearText.backColor =  (dotnetclass "System.Drawing.Color").white
	clearText.foreColor =  (dotnetclass "System.Drawing.Color").fromARGB 200 200 200 
	dnFontStyle = dotNetClass "System.Drawing.FontStyle"
	myFontStyle = dnFontStyle.bold 
	clearText.font = dotNetObject "System.Drawing.Font" "Ariel" 7 myFontStyle
	clearText.flatAppearance.borderSize = 0
	clearText.FlatAppearance.BorderColor = (dotnetclass "System.Drawing.Color").white
	
	sm_searchBar = dotNetObject "TextBox"
	sm_searchBar.location = dotNetObject "System.Drawing.Point" 3 265
	sm_searchBar.width = 175
	sm_searchBar.height = 20
	sm_searchBar.autoSize = false
	sm_searchBar.borderstyle = (dotnetclass "BorderStyle").none
	sm_searchBar.AutoCompleteMode = (dotnetclass "AutoCompleteMode").suggestAppend
	sm_searchBar.AutoCompleteSource = (dotnetclass "AutoCompleteSource").customsource
	sm_searchBar.AutoCompleteCustomSource = (dotnetobject "autocompletestringcollection")
	sm_searchBar.AutoCompleteCustomSource.Clear()
		
	sm_runScript = dotNetObject "Button"
	sm_runScript.text = "Run Script"
	sm_runScript.location = dotNetObject "System.Drawing.Point" 3 288
	sm_runScript.width = 195
	sm_runScript.height = 24
	sm_runScript.autoSize = false
	sm_runScript.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").system
	
	theTreeView = dotNetObject "TreeView"
	theTreeView.location = dotNetObject "System.Drawing.Point" 3 3
	theTreeView.Width = 195
	theTreeView.height = 260	
	theTreeView.hideselection = false
	theTreeView.Indent = 12  -- <System.Int32>
	theTreeView.BackColor = (dotNetClass "System.Drawing.Color").white --<System.Drawing.Color>
	theTreeView.ShowPlusMinus = true --<System.Boolean>
	theTreeView.fullrowselect = true
	theTreeView.DrawMode = (dotnetclass "TreeViewDrawMode").OwnerDrawText

	theTreeView.font = font
	theTable = dotNetObject "RichTextBox"
	theTable.Location = dotNetObject "System.Drawing.Point" 203 3
	theTable.Width = 325
	theTable.Height = 310
	theTable.MultiLine = true
	theTable.readOnly = true
	--theTable.AcceptsTab=true
	--theTable.acceptsReturn = true
	--theTable.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Horizontal
	theTable.WordWrap = true
	theTable.backColor =  (dotnetclass "System.Drawing.Color").fromARGB 200 200 200 
	
	expanderButton = dotNetObject "Button" 
	expanderButton.text = ">"
	expanderButton.width = 14
	expanderButton.height = 310
	expanderButton.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").system
	expanderButton.Location = dotNetObject "System.Drawing.Point" 203 3
	expanderButton.visible = false
	
	compressorButton = dotNetObject "Button" 
	compressorButton.text = "<"
	compressorButton.width = 14
	compressorButton.height = 310
	compressorButton.flatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").system
	compressorButton.Location = dotNetObject "System.Drawing.Point" 531 3
	
	-- Create Max Form
	ScriptManager = dotNetObject "MaxCustomControls.MaxForm"
	ScriptManager.Size = dotNetObject "System.Drawing.Size" 565 355
	ScriptManager.Text =  ("ScriptManager v" + ScriptManager_ver)
	ScriptManager.Controls.Add(theTable)
	ScriptManager.Controls.Add(expanderButton)
	ScriptManager.Controls.Add(compressorButton)	
	ScriptManager.Controls.Add(theTreeView)
	ScriptManager.Controls.Add(sm_searchBar)
	ScriptManager.Controls.Add(sm_runScript)
	ScriptManager.Controls.Add(clearText)
	ScriptManager.Controls.Add(splitter)
	ScriptManager.ShowInTaskbar = false
	ScriptManager.MinimizeBox = false
	ScriptManager.MaximizeBox = false
	
	

	fn ScriptManager_lbuttondown sender arg =
	(		
		val = [arg.location.x, arg.location.y]

		if (not minimized and val[1] >= splitter.location.x - 1 and val[1] <= splitter.location.x + splitter.width + 1) then
		(
			if (val[2] >= splitter.location.y - 1 and val[2] <= splitter.location.y + splitter.height + 1) then
			(
				resizeSplitter = true
				lastMPos = val
			)
		)		
	)
	fn ScriptManager_lbuttonup sender arg =
	(
		resizeSplitter = false
	)
	
	fn setRightControls =
	(
		
		expanderButton.location.x = splitter.location.x + splitter.width
		
		thetable.location.x =  splitter.location.x + splitter.width + 1
		theTable.width = ScriptManager.width - splitter.location.x - splitter.width - compressorButton.width - 24
		
		if (not minimized) then
		(
			compressorButton.location.x = thetable.location.x + thetable.width + 3
		)else
		(
			compressorButton.location.x = 5000
		)
	)
	
	fn rSplitter val cursorChange giveDelta:false=
	(
		
		--if (not minimized) then
		--(
		
			if (cursorChange) then
			(
				cursors = dotNetClass "System.Windows.Forms.Cursors"
				cursor = dotNetClass "System.Windows.Forms.Cursor"
				cursor.current = cursors.SizeWE
			)
			
			if (resizeSplitter) then
			(
				
				diagPos = [ScriptManager.location.x, scriptManager.location.y]
				
				if (not giveDelta) then
				(
					mOffset = val - lastMpos
					lastMPos = val
				)else
				(
					mOffset = val
				)
				
				oldPos = [splitter.location.x, splitter.location.y]

				if not minimizing then
				(
					splitter.location.x += mOffset[1]				
					splitter.location.x = aMax #(splitter.location.x, 30)
				)
				if not minimized then
				(

					splitter.location.x = aMin#(ScriptManager.width - 50, splitter.location.x)
				)
				
				deltaX = oldPos[1] - splitter.location.x
				
				if ([splitter.location.x, splitter.location.y] != oldPos) then
				(
				
					for q in 1 to leftcontrols.count do
					(
						leftcontrols[q].width += -deltaX
					)
					clearText.location.x += -deltaX
					setRightControls()
				)
				
			
			)
		--)
	)
	
	fn ScriptManager_mousemove sender arg =
	(
		val = [arg.location.x, arg.location.y]
		
		if not minimized and (val[1] >= splitter.location.x and val[1] <= splitter.location.x + splitter.width) then
		(
			cursors = dotNetClass "System.Windows.Forms.Cursors"
			cursor = dotNetClass "System.Windows.Forms.Cursor"
			cursor.current = cursors.SizeWE
		)
		if (not minimized and resizeSplitter) then
		(
			if val[1] >= 30 and val[1] <= ScriptManager.width - 30 then
			(
				rSplitter val true
			)
		)
	)
	
	fn ScriptManager_resized sender arg =
	(
		
		val = [sender.width, sender.height] 
	
		if ScriptManager.height < 100 then ScriptManager.height = 100
		
		sizeYDelta = ScriptManager.height - oldSizeY
		oldSizeY = ScriptManager.height
		
		theTreeView.height += sizeYdelta
		sm_searchBar.location.y += sizeYDelta
		sm_runScript.location.y += sizeYDelta
		theTable.height += sizeYDelta
		compressorButton.height += sizeYDelta
		expanderButton.height += sizeYDelta
		clearText.location.y += sizeYDelta
		
		
		if (not minimized) then
		(
			sizeDelta = 0
			if (val[1] < expanderButton.location.x + 50) then
			(
				if (val[1] > 50) then
				(
					resizeSplitter = true
					lastMPos = [splitter.location.x,0]
					xVal = val[1] - 30
					rSplitter [xVal,0] false
					
					lastSize = [ScriptManager.width, ScriptManager.height]
					resizeSplitter = false
				)else
				(
					ScriptManager.width = lastSize[1]
					ScriptManager.height = lastSize[2]
				)
			)else
			(
				lastSize = [ScriptManager.width, ScriptManager.height]
			)
		)else
		(
					
			resizeSplitter = true
			rSplitter [val[1] - lastSize[1], 0] false giveDelta:true
			sizeDelta += (val[1] - lastSize[1])
			
			resizeSplitter = false
			lastSize = [ScriptManager.width, ScriptManager.height]

		)
		
		setRightControls()
		
		
	)
	
	fn ScriptManager_formClosing sender arg =
	(
		if scriptManager == sender then 
		(
			arg.cancel = true
			sender.hide()
		)else
		(
			
		)
	)
	
	fn clearText_click sender arg =
	(
		sm_searchBar.text = ""
		sm_updateFolderStruct sm_searchBar.text false
		sm_searchBar.focus()

	)
	
	fn sm_searchBar_keyup sender arg =
	(

			
		if (arg.keycode == (dotnetclass "System.Windows.Forms.Keys").down) or 
		(arg.keycode == (dotnetclass "System.Windows.Forms.Keys").up) then
		(
		)else
		(
			if sm_searchBar.text != "" then
			(
				
				searchStr = ""
				if (sm_searchBar.selectionstart > 0) then
				(
					for q in 1 to sm_searchBar.selectionstart do
					(
						searchStr += sm_searchBar.text[q]
					)
				)else
				(
					searchStr = sm_searchBar.text
				)
				sm_updateFolderStruct searchStr true
			)else
			(
					
				sm_updateFolderStruct sm_searchBar.text false
			)
		)
	)

	currentlySelectedNode = undefined
	canChangeNode = true
	
	theTreeView_mouseup
	
	fn theTreeView_drawNode sender args =
	(

		try
		(
			
			if (args.node.isSelected or args.state.tostring() == "Focused") then
			(
			--	if (findstring (args.state.tostring()) "Focused" != undefined) then
				--(
					--currentlyselectednode = args.node
					--theTreeView_mouseup undefined undefined
				--)				
				g = args.graphics
				nodeForeColor = (dotnetclass "system.drawing.color").black
				
				brush1 = (dotnetobject "system.drawing.solidbrush" ((dotnetclass "system.drawing.color").fromARGB 200 200 200))
				brush2 = (dotnetobject "system.drawing.solidbrush" nodeForeColor)
				
				g.fillrectangle brush1 args.node.bounds

				val = dotnetobject "system.drawing.rectangle" args.bounds.left (args.bounds.top - 2) args.bounds.width args.bounds.height
				
				fontName = dotnetobject "system.drawing.fontfamily" (dotnetclass "system.drawing.text.genericfontfamilies").sansserif
				font = dotnetobject "system.drawing.font" fontName 8
				
				(dotnetclass "system.windows.forms.TextRenderer").drawText args.graphics args.node.text sender.font val nodeForeColor
				
			)else
			(
				args.drawdefault = true
			)
			
		)catch(print (getcurrentexception()))

			
	)
	
	
	fn theTreeView_mouseup sender args =
	(
		uiaccessor.sendmessage scriptmanager.handle WM_SETREDRAW 1 0
	)
	
	fn getNodeInfo=
	(
		if currentlySelectedNode == undefined then return false
					
		if (currentlySelectedNode.tag != undefined) then
		(
			fileDir = getfilenamepath currentlySelectedNode.tag
			fileN = getfilenamefile currentlySelectedNode.tag
			copyPath = fileDir + fileN + ".*"
			
			fList = getFiles copyPath
			
			newPath = "$scripts\\nannyTemp\\"
			makeDir (newPath) all:true
			
			parsedInfo = #()
			for q in 1 to fList.count do
			(
				newFile = newPath + filenamefrompath fList[q]
				
				copyFile fList[q] newFile
				
				sFile = openFile newFile mode:"r"
				
				if (sFile != undefined) then
				(
					grabInfo = false
					lineCount = 0
					infoArr = #()
					while not eof sFile and lineCount < 50 do
					(
						lineCount += 1
						str = readLine sFile
						
						
						if findstring str "/*" != undefined then
						(
							grabInfo = true					
						)else if (findstring str "*/" != undefined) then
						(
							exit
						)else if grabInfo then
						(
							if (str.count > 0) then
							(
								append infoArr str
							)
						)						
					)		
					
					close sFile
					
					currentInfoInx = 0
					for q in 1 to infoArr.Count do
					(
						
						subStr = infoArr[q]
						if findstring (toupper infoArr[q]) "#NAME:" != undefined then
						(
							currentInfoInx = 1
							subStr = substring infoArr[q] 7 infoArr[q].count
						)else if (findstring (toupper infoArr[q]) "#VERSION:" != undefined) then
						(
							currentInfoInx = 2
							subStr = substring infoArr[q] 10 infoArr[q].count
						)else if (findstring (toupper infoArr[q]) "#INFORMATION:" != undefined) then
						(
							currentInfoInx = 3
							subStr = substring infoArr[q] 15 infoArr[q].count
						)else if (findstring (toupper infoArr[q]) "#INSTRUCTIONS:" != undefined) then
						(
							currentInfoInx = 3
							subStr = substring infoArr[q] 15 infoArr[q].count
						)else if (findstring (toupper infoArr[q]) "#SOURCE:" != undefined) then
						(
							currentInfoInx = 4
							subStr = substring infoArr[q] 9 infoArr[q].count
							
						)else if (findstring (toupper infoArr[q]) "#HISTORY:" != undefined) then
						(
							currentInfoInx = 5
							subStr = substring infoArr[q] 10 infoArr[q].count
						)else
						(
							if (currentInfoInx > 0) then
							(
								if parsedInfo[currentInfoInx] != undefined and parsedInfo[currentInfoInx].count > 0 then
								parsedInfo[currentInfoInx] += (dotNetClass "System.Environment").newline + "   "
							)
							
						
						)
						
						if currentInfoInx > 0 then
						(
							
							if parsedInfo[currentInfoInx] == undefined then
							(
								parsedInfo[currentInfoInx] = ""						
							)
							if substr.count > 0 then parsedInfo[currentInfoInx] += subStr
						)
					)
					
					
				)
				
				deleteFile newFile
				
				found = false
				for q in 1 to parsedInfo.count do
				(
					if (parsedInfo[q] != undefined and parsedInfo[q] != "") then
					(
						found = true
					)
				)
				if found then exit
						
				
			)
			
			for q in 1 to 5 do
			(
				if parsedInfo[q] == undefined or parsedInfo[q] == "" then
				(
					parsedInfo[q] = "   N/A"
				)
			)
				
			dosCmd =  ("rd \"" + (getfilenamepath newPath) + "\"")
			hiddendoscommand dosCmd
			
			if parsedInfo[1] == undefined or parsedInfo[1] == "   N/A" then
			(
				n1 = filenamefrompath currentlySelectedNode.tag
			)else
			(
				n1 = parsedInfo[1] as string
			)
			v1 = parsedInfo[2] as string
			d1 = (getFileModDate currentlySelectedNode.tag)
			i1 = parsedInfo[3] as string
			s1 = parsedInfo[4] as string
			h1 = parsedInfo[5] as string
			
			setInfoBox n1 v1 d1 i1 s1 h1
		)else
		(
			theTable.text = ""
		)
		
		
		
	)
	
	fn theTreeView_mousedown sender args =
	(	
		
		n = (theTreeView.HitTest args.x args.y).node
		
		if (n != undefined) then
		(
			l1 = args.location.x
			l2 = args.location.y
			n1 = n.bounds.x
			n2 = n.bounds.y
			n3 = n1 + n.bounds.width
			n4 = n2 + n.bounds.height
			
			if (l1 >= n1 and l1 <= n3 and l2 >= n2 and l2 <= n4) then
			(
				currentlySelectedNode = n
				theTreeView.selectedNode = n
					
				
			)
		)
		

		uiaccessor.sendmessage scriptmanager.handle WM_SETREDRAW 1 0
		
		
	)
	
	fn theTreeView_keydown sender args =
	(	
		
		currentlySelectedNode = theTreeView.selectedNode
		getNodeInfo()
		theTable.refresh()

		
		
	)
	
	
	fn theTreeView_mouseclick sender args =
	(
		
		uiaccessor.sendmessage scriptmanager.handle WM_SETREDRAW 1 0

	)

	fn theTreeView_mouseleave sender args =
	(
		uiaccessor.sendmessage scriptmanager.handle WM_SETREDRAW 1 0
	
	)
	
	
	
	fn sm_runScript_click sender arg =
	(
		if (theTreeView.selectedNode != undefined) then
		(
			if (theTreeView.selectedNode.tag != undefined) then
			(
				
				try
				(
					filein theTreeView.selectedNode.tag
					
					try(join currentModulesArray #((theTreeView.selectedNode.tag as string)))catch()
						
					if addModuleToMemory == true then
					(
						append MT_CurrentTabExtraModule theTreeView.selectedNode.tag
					)else()
				)catch
				(
					messagebox ("Error running script: \n\n" + getcurrentexception())
				)
			)
		)
		
	)
	
	fn expanderButton_click sender arg =
	(
		minimized = false
		TheTable.visible = true
		oldWidth += sizeDelta
		ScriptManager.width = oldWidth
		expanderButton.visible = false
		
		setRightControls()
	)
	fn compressorButton_click sender arg =
	(
		minimizing = true
		lastSize = [expanderButton.location.x + 17, scriptManager.height]
		lastMPos = [0,0]
		oldWidth = ScriptManager.width
		minimized = true
		TheTable.visible = false
		
		ScriptManager.width = expanderButton.location.x + 34

		expanderButton.visible = true
		
		setRightControls()
		
		minimizing = false
	)
	
	fn theTable_linkClicked sender arg =
	(
		shellLaunch arg.linkText ""
	)
	
	/**************************************************************************************	
	All tree functions are below	
	***************************************************************************************/
	
	fn strToBit str inx=
	(
		bitArr = execute str
		bit1 = bitmap 16 16
		
		for q in 0 to 15 do
		(
			
			for g in 0 to 15 do
			(
				setpixels bit1 [g, q] #(bitArr[(q + 1)][inx*16 + g + 1])
			)
		)

		bit1
	)


	fn folderNameFromPath p =
	(
		fString = filterString p "\\"
		fString[fString.count]
	)

	fn recurseMatchUp fNode =
	(
		fNode.matchesPattern = true
		if fNode.folderParent != undefined then recurseMatchUp fNode.folderParent
	)
	
	fn resetStruct fNode =
	(
		fNode.matchesPattern = false
		for subDir in fNode.subFolders do
		(
			resetStruct subDir
		)
	)
	
	fn cullStruct fNode pattern =
	(
		if pattern == "" and fNode.files.count == 0 then recurseMatchup fNode
		for file in fNode.files do
		(
			if pattern == "" or findString (toupper(getfilenamefile file)) (toupper pattern) != undefined then
			(
				recurseMatchUp fNode
			)
		)
		for subDir in fNode.subFolders do
		(
			cullStruct subDir pattern
		)
	)
	
	fn countParents fNode =
	(
		if (fNode.folderParent != undefined) then
		(
			folderDepth += 1
			countParents fNode.folderParent
		)else
		(
			return folderDepth
		)
	)	
	fn sm_walkDirectory fSys =
	(
		
		fSys.files = #()
		
		join fSys.files (getfiles (fSys.folderName + "*.ms"))
		join fSys.files (getfiles (fSys.folderName + "*.mcr"))
		join fSys.files (getfiles (fSys.folderName + "*.mse"))

		for f in fSys.files do
		(
			sm_searchBar.AutoCompleteCustomSource.Add (getfilenamefile f)
		)
		
		folderDepth = 0
		if (countParents fSys >= maxFolderDepth) then
		(
			
		)else
		(
			for dirName in (getdirectories (fSys.folderName + "*")) do
			(
				append fSys.subFolders (foldernode())
				fSys.subFolders[fSys.subFolders.Count].folderName = dirName
				fSys.subFolders[fSys.subFolders.Count].folderParent = fSys	
				sm_walkDirectory fSys.subFolders[fSys.subFolders.count] 
			
			)
		)


	)
	
	fn FillInTreeView fNode tNode pattern expand =
	(
	
		if (fNode.matchesPattern) then
		(			
			if (fNode.folderName != "") then 
			(
				newTNode = (dotNetObject "TreeNode" (folderNameFromPath fNode.folderName))
				if (fNode.files.count > 0) then
				(
					tNode.nodes.Add newTNode
				)
			
			)else
			(
				newTNode = tNode
			)
			
			
			
			for f in fNode.files do
			(
				if pattern == "" or findString (toupper(getfilenamefile f)) (toupper pattern) != undefined then
				(
					fileNode =  (dotNetObject "TreeNode" (getfilenamefile f))
					fileNode.tag = f
					fType = (tolower (getfilenametype f))
					if fType == ".mcr" then
					(
						fileNode.imageIndex = 2
						fileNode.selectedimageIndex = 2
					)else if fType == ".mse" then
					(
						fileNode.imageIndex = 3
						fileNode.selectedimageIndex = 3
					)else
					(
						fileNode.imageIndex = 1
						fileNode.selectedImageIndex = 1
					)
					newTNode.nodes.Add fileNode
				)
				
			)
			
			for subDir in fNode.subFolders do
			(
				fillInTreeView subDir newTNode pattern expand
			)
			try
			(
				if expand then newTNode.expand()
			)catch()
		)	
	)
	
	
	fn sm_updateFolderStruct pattern expand=
	(
		
		theTreeView.nodes.clear()
		
		resetStruct sm_folderRoot
		cullStruct sm_folderRoot pattern

		theTreeView.BeginUpdate()
		
		fillInTreeView sm_folderRoot theTreeView pattern expand
		
		theTreeView.EndUpdate()
		
	)
	
	fn appendText txt cr bold:false=
	(
		start = theTable.text.count
		theTable.appendText txt	
		end = theTable.text.count
				
		theTable.select start (end - start)
		
		if (bold) then
		(
			theTable.selectionFont = (dotnetobject "system.drawing.font" "Arial" 9 (dotnetclass "system.drawing.fontstyle").bold)
			
		)else
		(
			theTable.selectionColor = (dotnetclass "system.drawing.color").fromARGB 60 60 60
		)
		
			
		theTable.selectionLength = 0
		
		if cr then theTable.appendText ((dotNetClass "System.Environment").newline)
	)
	fn setInfobox n1 v1 d1 i1 s1 h1 =
	(
		theTable.SuspendLayout()
		
		theTable.text = ""
		
		appendText n1 true bold:true
		
		appendText ("   Version: " + v1) true
		
		
		appendText ("   Last modified: " + d1)  true
		appendText ""  true
		appendText ""  true 
		
		appendText ("Information:") true bold:true
		appendText ("   " + i1) true
		appendText ""  true 
		
		appendText ("Source:") true bold:true
		appendText ("   " + s1)  true
		appendText "" true 
		
		appendText ("History:")  true bold:true
		appendText ("   " + h1)  true
		appendText ""  true 	

		theTable.ResumeLayout()
	)
	
	
	fn sm_setIcons =
	(
		imglist = dotnetobject "System.Windows.Forms.ImageList"
		imglist.imagesize =  dotnetobject "System.Drawing.Size" 16 16
		cDepth = dotnetclass "System.Windows.Forms.Colordepth"
		imgList.colorDepth = cDepth.depth16bit
		
		for q in 0 to 3 do
		(
			iconBit = strToBit ScriptManager_iconStr q
			setClipboardBitmap iconBit
			iconImg = (dotnetclass "System.Windows.Forms.Clipboard").GetImage()			
			imglist.images.add iconImg
		)
				
		theTreeView.imageList = imgList
	)
	
	dotnet.addEventHandler ScriptManager "MouseDown" ScriptManager_lbuttondown
	dotnet.addEventHandler ScriptManager "MouseUp" ScriptManager_lbuttonup
	dotnet.addEventHandler ScriptManager "MouseMove" ScriptManager_mousemove
	dotnet.addEventHandler ScriptManager "Resize" ScriptManager_resized
	dotnet.addEventHandler ScriptManager "FormClosing" ScriptManager_formClosing
	dotnet.addEventHandler sm_searchBar "KeyUp" sm_searchBar_keyup
	dotnet.addEventHandler clearText "Click" clearText_click
	dotnet.addEventHandler theTreeView "MouseClick" theTreeView_mouseclick
	dotnet.addEventHandler theTreeView "MouseUp" theTreeView_mouseup
	dotnet.addEventHandler theTreeView "MouseLeave" theTreeView_mouseleave
	dotnet.addEventHandler theTreeView "MouseDown" theTreeView_mousedown
	dotnet.addEventHandler theTreeView "AfterSelect" theTreeView_keyDown
	dotnet.addEventHandler theTreeView "DrawNode" theTreeView_drawNode
	dotnet.addEventHandler sm_runScript "Click" sm_runScript_click
	dotnet.addEventHandler expanderButton "Click" expanderButton_click
	dotnet.addEventHandler compressorButton "Click" compressorButton_click
	dotnet.addEventHandler theTable "LinkClicked" theTable_linkClicked
	dotnet.addEventHandler theTreeView "DoubleClick" sm_runScript_click
	
	
	append leftControls theTreeView
	append leftControls sm_searchBar
	append leftControls sm_runScript
	
		
	lastSize = [ScriptManager.width, ScriptManager.height]
	oldSizeY = ScriptManager.height
		
	
)
ScriptManager.location = dotNetObject "System.Drawing.Point" 100 100

--scriptManager_open scriptManager_scriptDir buttonText:"Run script temp text" titleText:"Script manager temp text"


-----icon string for treeview icons
ScriptManager_iconStr = "#(#((color 247 247 247), (color 247 247 247), (color 246 235 173), (color 245 231 142), (color 244 228 141), (color 242 224 137), (color 241 222 136), (color 241 221 137), (color 239 219 134), (color 238 217 131), (color 236 215 128), (color 234 213 124), (color 234 215 137), (color 240 229 188), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247)), #((color 247 247 247), (color 246 246 245), (color 245 231 141), (color 251 246 177), (color 253 251 233), (color 244 234 153), (color 237 223 135), (color 220 205 120), (color 250 245 188), (color 253 250 194), (color 253 250 194), (color 253 250 194), (color 249 244 182), (color 231 212 133), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 215 216 215), (color 209 209 209), (color 202 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 171), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 98 97 97), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 215 216 215), (color 209 209 209), (color 202 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 171), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 98 97 97), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 215 216 215), (color 209 209 209), (color 202 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 171), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 98 97 97), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 247 247 247)), #((color 247 247 247), (color 247 247 247), (color 245 231 141), (color 251 247 180), (color 251 247 180), (color 255 255 252), (color 255 255 252), (color 224 203 104), (color 213 198 126), (color 246 238 174), (color 252 249 191), (color 251 247 187), (color 250 244 183), (color 228 205 113), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 220 220 219), (color 213 213 213), (color 206 206 206), (color 198 199 198), (color 191 191 191), (color 182 183 182), (color 175 175 175), (color 167 169 168), (color 161 162 161), (color 155 155 155), (color 98 97 97), (color 255 255 255), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 220 220 219), (color 213 213 213), (color 206 206 206), (color 198 199 198), (color 191 191 191), (color 182 183 182), (color 175 175 175), (color 167 169 168), (color 161 162 161), (color 155 155 155), (color 98 97 97), (color 255 255 255), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 220 220 219), (color 213 213 213), (color 206 206 206), (color 198 199 198), (color 191 191 191), (color 182 183 182), (color 175 175 175), (color 167 169 168), (color 161 162 161), (color 155 155 155), (color 98 97 97), (color 255 255 255), (color 0 0 0), (color 247 247 247), (color 247 247 247)), #((color 247 247 247), (color 247 247 247), (color 245 231 141), (color 251 247 180), (color 251 247 180), (color 251 247 180), (color 255 255 255), (color 221 200 99), (color 209 192 119), (color 229 210 129), (color 250 244 183), (color 249 242 177), (color 247 239 172), (color 226 204 111), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 223 223 223), (color 217 217 217), (color 210 211 211), (color 203 203 203), (color 195 196 195), (color 188 188 188), (color 179 180 180), (color 172 173 172), (color 165 165 165), (color 158 159 158), (color 98 97 97), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 247 247 247), (color 0 0 0), (color 223 223 223), (color 217 217 217), (color 210 211 211), (color 203 203 203), (color 195 196 195), (color 188 188 188), (color 179 180 180), (color 172 173 172), (color 165 165 165), (color 158 159 158), (color 98 97 97), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 247 247 247), (color 0 0 0), (color 223 223 223), (color 217 217 217), (color 210 211 211), (color 203 203 203), (color 195 196 195), (color 188 188 188), (color 179 180 180), (color 172 173 172), (color 165 165 165), (color 158 159 158), (color 98 97 97), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 247 247 247)), #((color 247 247 247), (color 247 247 247), (color 245 230 141), (color 251 247 180), (color 251 247 180), (color 251 247 180), (color 255 255 252), (color 218 196 94), (color 208 190 115), (color 227 207 124), (color 247 239 172), (color 245 236 165), (color 243 233 158), (color 225 202 109), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 226 226 226), (color 221 221 220), (color 215 214 214), (color 208 208 207), (color 200 200 200), (color 193 192 192), (color 185 185 184), (color 176 177 177), (color 169 170 169), (color 162 163 162), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 0 0 0), (color 0 0 0), (color 226 226 226), (color 221 221 220), (color 215 214 214), (color 208 208 207), (color 200 200 200), (color 193 192 192), (color 185 185 184), (color 176 177 177), (color 169 170 169), (color 162 163 162), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 0 0 0), (color 0 0 0), (color 226 226 226), (color 221 221 220), (color 215 214 214), (color 208 208 207), (color 200 200 200), (color 193 192 192), (color 185 185 184), (color 176 177 177), (color 169 170 169), (color 162 163 162), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 98 97 97), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 243 229 138), (color 251 247 180), (color 251 247 180), (color 249 245 176), (color 254 253 244), (color 215 192 89), (color 206 188 109), (color 225 204 117), (color 243 233 158), (color 242 229 151), (color 240 226 144), (color 223 201 106), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 229 229 229), (color 224 224 224), (color 218 218 218), (color 212 212 212), (color 205 205 205), (color 197 197 197), (color 189 190 189), (color 181 182 181), (color 173 174 173), (color 167 167 166), (color 160 160 160), (color 154 155 154), (color 149 150 149), (color 146 147 146), (color 0 0 0), (color 0 0 0), (color 229 229 229), (color 224 224 224), (color 218 218 218), (color 212 212 212), (color 205 205 205), (color 197 197 197), (color 189 190 189), (color 181 182 181), (color 173 174 173), (color 167 167 166), (color 160 160 160), (color 154 155 154), (color 149 150 149), (color 146 147 146), (color 0 0 0), (color 0 0 0), (color 229 229 229), (color 224 224 224), (color 218 218 218), (color 212 212 212), (color 205 205 205), (color 197 197 197), (color 189 190 189), (color 181 182 181), (color 173 174 173), (color 167 167 166), (color 160 160 160), (color 154 155 154), (color 149 150 149), (color 146 147 146), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 242 227 136), (color 251 247 180), (color 249 245 176), (color 247 241 170), (color 252 250 232), (color 212 189 85), (color 205 185 103), (color 224 201 111), (color 240 226 144), (color 238 222 137), (color 236 218 130), (color 226 204 110), (color 232 218 162), (color 247 247 247), (color 0 0 0), (color 231 231 231), (color 227 227 227), (color 221 222 221), (color 215 216 216), (color 209 209 209), (color 201 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 170), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 148 148 148), (color 0 0 0), (color 0 0 0), (color 231 231 231), (color 227 227 227), (color 221 222 221), (color 215 216 216), (color 209 209 209), (color 201 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 170), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 148 148 148), (color 0 0 0), (color 0 0 0), (color 231 231 231), (color 227 227 227), (color 221 222 221), (color 215 216 216), (color 209 209 209), (color 201 202 202), (color 194 194 194), (color 186 186 186), (color 178 178 178), (color 171 171 170), (color 164 164 164), (color 157 158 157), (color 152 152 152), (color 148 148 148), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 240 224 132), (color 249 245 176), (color 247 241 170), (color 244 236 163), (color 246 241 198), (color 210 186 81), (color 203 182 96), (color 222 198 104), (color 236 218 130), (color 234 215 121), (color 232 211 114), (color 230 208 108), (color 220 197 100), (color 247 247 247), (color 0 0 0), (color 232 232 232), (color 230 229 230), (color 225 225 224), (color 220 219 220), (color 213 213 213), (color 206 206 206), (color 198 199 199), (color 191 191 190), (color 182 183 182), (color 175 176 175), (color 168 169 167), (color 161 161 161), (color 155 155 155), (color 150 151 150), (color 0 0 0), (color 0 0 0), (color 232 232 232), (color 230 229 230), (color 225 225 224), (color 220 219 220), (color 213 213 213), (color 206 206 206), (color 198 199 199), (color 191 191 190), (color 182 183 182), (color 175 176 175), (color 168 169 167), (color 161 161 161), (color 155 155 155), (color 150 151 150), (color 0 0 0), (color 0 0 0), (color 232 232 232), (color 230 229 230), (color 225 225 224), (color 220 219 220), (color 213 213 213), (color 206 206 206), (color 198 199 199), (color 191 191 190), (color 182 183 182), (color 175 176 175), (color 168 169 167), (color 161 161 161), (color 155 155 155), (color 150 151 150), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 238 222 129), (color 247 241 170), (color 244 236 163), (color 240 231 155), (color 236 225 146), (color 208 183 77), (color 201 178 90), (color 220 194 98), (color 232 211 114), (color 230 208 108), (color 228 205 101), (color 236 236 236), (color 219 195 98), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 236 219 124), (color 244 236 163), (color 240 231 155), (color 236 225 146), (color 232 219 137), (color 206 180 73), (color 200 175 83), (color 218 191 91), (color 228 205 101), (color 227 202 95), (color 225 199 90), (color 236 236 236), (color 218 194 97), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 233 216 120), (color 240 231 155), (color 236 225 146), (color 232 219 137), (color 228 212 128), (color 204 178 70), (color 198 172 77), (color 217 188 85), (color 225 199 90), (color 224 197 85), (color 223 195 81), (color 236 236 236), (color 217 193 95), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 231 212 116), (color 236 225 146), (color 232 219 137), (color 228 212 128), (color 224 206 118), (color 202 176 68), (color 196 169 72), (color 216 186 81), (color 223 195 81), (color 222 193 77), (color 222 193 77), (color 92 185 221), (color 216 192 93), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 228 209 111), (color 232 219 137), (color 228 212 128), (color 224 206 118), (color 221 201 110), (color 202 175 67), (color 196 168 68), (color 215 184 77), (color 222 193 77), (color 222 193 77), (color 222 193 77), (color 72 165 211), (color 215 191 92), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 225 206 107), (color 228 212 128), (color 224 206 118), (color 221 201 110), (color 218 196 102), (color 202 175 67), (color 195 166 66), (color 215 184 77), (color 222 193 77), (color 222 193 77), (color 222 193 77), (color 221 193 79), (color 218 198 113), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 229 213 140), (color 217 195 94), (color 214 192 92), (color 214 191 93), (color 214 191 95), (color 202 175 67), (color 193 166 74), (color 212 184 85), (color 215 192 93), (color 215 191 92), (color 214 190 91), (color 218 198 112), (color 232 222 177), (color 247 247 247), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0), (color 0 0 0), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 255 255 255), (color 0 0 0)), #((color 247 247 247), (color 247 247 247), (color 247 247 247), (color 243 241 230), (color 231 222 181), (color 217 199 124), (color 204 179 76), (color 195 174 98), (color 215 204 169), (color 241 237 225), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0)))"


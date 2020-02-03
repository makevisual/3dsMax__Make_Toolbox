/*
#NAME:MT_AutoBack
#VERSION:1.1
#INSTRUCTIONS:
Leave open to automatically backup your scene at set interval
#SOURCE:Tyson Ibele, ivanisiavich@yahoo.com
Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.1.2012 >> Integrated into MakeToolBox
*/
--*****************************************************
-- HISTORY:
--    - v1.0 (3.20.2012):
--        1st version
--    - v1.0 (6.6.2012):
--        Disabled autosave during playback
--*****************************************************

try(destroydialog MT_autoback)catch()

global MT_autoback

fn themeClass =
(
	source = "Imports System.Runtime.InteropServices
		
	Public Class themeOps
		
		
		<DllImport(\"dwmapi.dll\")> Public Shared Function DwmIsCompositionEnabled(ByRef enabled As Boolean) As Integer
		End Function
	
		Public Function AeroEnabled() As Boolean
			Dim enabled As Boolean
			DwmIsCompositionEnabled(enabled)
			Return enabled
		End Function
	
	End Class"

	VBProvider = dotnetobject "Microsoft.VisualBasic.VBCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.GenerateInMemory = on
	compilerResults = VBProvider.CompileAssemblyFromSource compilerParams #(source)

	if (compilerResults.Errors.Count > 0 ) then
	(
		errs = stringstream ""
		for i = 0 to (compilerResults.Errors.Count-1) do
		(
			err = compilerResults.Errors.Item[i]
			format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line \
			err.Column err.ErrorText to:errs
		)
			MessageBox (errs as string) title: "Errors encountered while compiling VB code"
		return undefined
	)

	return compilerResults.CompiledAssembly.CreateInstance "themeOps"
)

global themeOps = themeClass()



rcmenu MT_autoback_menu
(
	menuItem openDir "Open backup file directory"
	menuItem defPos "Restore to default position"
	
	on defPos picked do
	(
			MT_autoback.wPosOffset = [0,0]
			MT_autoback.setWPos true
		
	)
	submenu "Save interval"
	(
		
		menuItem min5 "5 minutes" 
		menuItem min10 "10 minutes"
		menuItem min15 "15 minutes"
		menuItem min20 "20 minutes"
		menuItem min25 "25 minutes"
		menuItem min30 "30 minutes"
		
	)
	
	menuItem closeMe "Close"
	
	on closeMe picked do
	(
		MT_autoback.closeMe()
	)
	
	on opendir picked do
	(
		if MT_autoback.savedirname != "" then
		(
			if (MT_autoback.savefilename == "" or not (doesfileexist mt_autoback.savefilename) or not MT_autoback.hasSaved) then
			(
				
				shellLaunch "explorer" ("\"" + mt_autoback.saveDirName +"\\\"")
			
				
			)else
			(
				
				shellLaunch "explorer" ("/e,/select, \"" + mt_autoback.saveFileName + "\"")
				
			)
			
			
		)else
		(
			messagebox "No backup directory exists yet. Please save your max file first."
		)
	)
	
	on min5 picked do
	(
		MT_autoback.totalTime = 5 * 1000 * 60
		min10.checked = false
		min15.checked = false
		min20.checked = false
		min25.checked = false
		min30.checked = false
		
		min5.checked = true
		
	)
	on min10 picked do
	(
		MT_autoback.totalTime = 10 * 1000 * 60
		min5.checked = false
		min15.checked = false
		min20.checked = false
		min25.checked = false
		min30.checked = false
		
		min10.checked = true
	)
	on min15 picked do
	(
		MT_autoback.totalTime = 15 * 1000 * 60
		min5.checked = false
		min10.checked = false
		min20.checked = false
		min25.checked = false
		min30.checked = false
		
		min15.checked = true
	)
	on min20 picked do
	(
		MT_autoback.totalTime = 20 * 1000 * 60
		min5.checked = false
		min10.checked = false
		min15.checked = false
		min25.checked = false
		min30.checked = false
		
		min20.checked = true
		
	)
	on min25 picked do
	(
		MT_autoback.totalTime = 25 * 1000 * 60
		min5.checked = false
		min10.checked = false
		min15.checked = false
		min20.checked = false
		min30.checked = false
		
		min25.checked = true
		
	)
	on min30 picked do
	(
		MT_autoback.totalTime = 30 * 1000 * 60
		min10.checked = false
		min15.checked = false
		min20.checked = false
		min25.checked = false
		min5.checked = false
		
		min30.checked = true
		
	)
)

rollout MT_autoback "MT_autoback"
(
	local col1 = color 150 150 150
	local col2 = color 11 11 11
	local col3 = color 10 10 10
	local hasSaved = false
	local inc = 0
	local totalTime = 300000
	local counter = 0
	local theLocalPath
 	local theThread
	local lastSize = -1
	local sizeAlert = false
	local bCol = red
	local saveDir = ""
	local saveFileName = ""
	local saveDirName = ""
	local saveFileNameOnly = ""
	
	local lastWPos
	local lastWSize
	local useCustomPos = false
	local setWPos
	
	local closeMe
	
	local iconsStr = "#(#((color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 93 93 93), (color 224 224 224), (color 224 224 224), (color 93 93 93), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 224 224 224), (color 93 93 93), (color 93 93 93), (color 224 224 224), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 224 224 224), (color 93 93 93), (color 93 93 93), (color 224 224 224), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 93 93 93), (color 224 224 224), (color 224 224 224), (color 93 93 93), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192)), #((color 0 0 0), (color 136 168 115), (color 136 168 115), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 136 168 115), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192)), #((color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192)))"
	
	fn strToBit str =
	(
		bitArr = execute str
		bit1 = bitmap bitArr[1].count bitArr.Count
		
		for q in 0 to bitArr.count - 1 do
		(
			setpixels bit1 [0, q] bitArr[q + 1]
		)
		
		bit1
	)
	
	checkbutton pauseMe "Pause" align:#right height:14 offset:[-5,-3] width:14 checked:true tooltip:"Resume auto-backups"
	button forceMe ">>" align:#right height:14 offset:[-21,-19] width:14 tooltip:"Do backup right now"
	button menu "Menu" align:#right height:14 offset:[11,-19] width:14 tooltip:"Menu"
	
	spinner interv "Interval: " type:#integer range:[1,20,5] offset:[0,-20] width:55 align:#left visible:false
	progressbar prog1 "" color:col1 offset:[-10,-18] width:165 height:10 --enabled:False 
	
	--label status "Status: Idle" align:#left offset:[100,-20]
	timer saveTimer interval:500
	
	timer moveTimer interval:10 active:true
	
	
	local canMove = false
	local lastMovePos = [0,0]
	local moveDelta = [0,0]
	local wPosOffset = [0,0]
	
	local loadINIFile
	
	on MT_autoback open do
	(
		loadINIFile()
		
		iconBit = strToBit iconsStr
		
		forceMe.images = #(iconBit, iconBit, 4,1,1,1,1 )
		pauseMe.images = #(iconBit, iconBit, 4,2,3,2,3 )
		menu.images = #(iconBit, iconBit, 4,4,4,4,4)
		
	)
	
	function saveINIFile =
	(
	
		folderString = @"$scripts\makeToolbox"
		
		fileString = @"$scripts\makeToolbox\mt_autoback_settings.ini"
		
		if not doesfileexist folderstring then
		(
			makedir folderstring all:true
		)
		if not doesfileexist filestring then
		(
			createfile filestring
		)
				
		setINISetting fileString "Settings" "posOffset" (wPosOffset as string)
		
	)
	
	function loadINIFile =
	(
		fileString =  @"$scripts\makeToolbox\mt_autoback_settings.ini"
		
		offVal = getINISetting fileString "Settings" "posOffset"
		if (offVal != "") then
		(
			wPosOffset =  (execute offVal )
			setWPos true
		)
	)
	
	
	on menu pressed do
	(
		popupmenu MT_autoback_menu pos:mouse.screenpos
	)
	on menu rightclick do
	(
		popupmenu MT_autoback_menu pos:mouse.screenpos
	)
	
	on MT_autoback mousemove pos do
	(
		if (canMove) then
		(
			try(
				
				cursor = dotnetclass "System.Windows.Forms.Cursor"
				curPos = cursor.position
				
				useCustomPos = true
				
				moveDelta = [curPos.x, curPos.y] - lastMovePos
				wPosOffset += moveDelta
				
				lastMovePos = [curPos.x, curPos.y]
				
				setwpos true
				--currPos = getdialogpos MT_autoback
				--setdialogpos MT_autoback (currPos + moveDelta)
				
			)catch()

		)
	)
	on MT_autoback lbuttondown pos do
	(
		moveTimer.active = false
		cursor = dotnetclass "System.Windows.Forms.Cursor"
		curPos = cursor.position
		
		lastMovePos = [curPos.x, curPos.y]
		canMove = true
		
	)
	on MT_autoback lbuttonup pos do
	(
		canMove = false
		moveTimer.active = true
		
	)	
	
	function setWPos force1=
	(
		wPos = getmaxwindowpos()
		wSize = getmaxwindowsize()
		
		sp = dotnetclass "System.Windows.SystemParameters"
		
		if (themeOps.aeroenabled()) then
		(
			titleHeight = sp.WindowCaptionHeight + sp.ResizeFrameHorizontalBorderHeight + 2
			verticalBorderWidth = sp.ResizeFrameVerticalBorderWidth + 2
		)else
		(
			titleHeight = sp.WindowCaptionHeight + 4
			verticalBorderWidth = 4
		)

		pos = wPos + wSize

		pos =  [(pos[1] - verticalBorderWidth ), (wPos[2] + titleHeight )]

		
		if (wPos != lastWPos or wSize != lastWSize or force1) then
		(
			
			setdialogpos MT_autoback ([pos[1] - ((getdialogsize mt_autoback)[1] + 2) , pos[2] ] + wPosOffset)
			lastWPos = wPos
			lastWSize = wSize
		)		
		saveINIFile()
	)
	
	local oldMaxPos = [0,0]
	local oldMaxSize = [0,0]
	on moveTimer tick do
	(
		
		try(
			if (getmaxwindowsize()) != oldMaxSize or (getmaxwindowpos()) != oldMaxPos then
			(
				setWPos false
				oldMaxPos = getmaxwindowpos()
				oldMaxSize = getmaxwindowsize()
				
			)
		)catch()
	)
	

	
	on forceMe pressed do
	(
		prog1.color = col1
		counter = 100000000
		prog1.value = 100
		sleep .05
		saveTimer.active = true
		
		saveTimer.tick()
	)
	on pauseMe changed val do
	(
		
		saveTimer.active = val
		
		
		if not saveTimer.active then (prog1.value = 100; prog1.color = col2) else saveTimer.tick()		
		
		if (prog1.color == col3) then
		(
			messagebox "Auto-backups will only be created\nonce your scene file is saved!"
		)
		
		if pauseme.checked then
		(
			if pauseme.tooltip != "Pause auto-backups" then
			(
				pauseme.tooltip = "Pause auto-backups"
			)
			
		)else
		(
			if pauseme.tooltip != "Resume auto-backups" then
			(
				pauseme.tooltip = "Resume auto-backups"
			)
		)
		
	)
	
	fn copyFileTest dosave=
 	(
		try(
		
			saveDir = maxfilepath + "\\MT_autoback"
			saveDirName = maxfilepath + "MT_autoback"
			makeDir saveDir
			if inc < 10 then
			(
				incStr = "0" + (inc as string)
			)else
			(
				incStr = inc as string
			)
			saveFileNameOnly =getFilenameFile(maxfilename) + "_bak_" + incStr + ".max"
			saveFile = saveDir + "\\" + saveFileNameOnly
			saveFileName = saveDirName + "\\" + getFilenameFile(maxfilename) + "_bak_" + incStr + ".max"
			
			if (dosave) then
			(
				saveMaxFile saveFile clearNeedSaveFlag:false useNewFile:false quiet:true
				hasSaved = true
			)
	

		)catch(print "MT_autoback error!")
 	)
	
	function postSave =
	(

		copyFileTest false
		counter = 0
		hasSaved = false
		
	)
	
	function postOpen =
	(

		copyFileTest false
		counter = 0
		hasSaved = false
		
	)
	
	
	function postReset =
	(

		savedirname = ""
		savefilename = ""
		savedir = ""
		savefilenameonly = ""
		counter = 0
		hasSaved = false
		
	)
	
	fn closeMe =
	(
		destroyDialog MT_autoback
	)	
	
	on saveTimer tick do
	(
		if maxFileName != "" then
		(
			isPlaying = isAnimPlaying()
			if isPlaying == false then
			(	
				counter += saveTimer.interval
				if counter > totalTime then 
				(
					inc += 1
					if inc > 15 then
					(
						inc = 0
					)
					--status.text = "Status: Saving file"
					
					copyFileTest true
					
					counter = 0
					prog1.value = 0
					
					
				)
				prog1.color = col1
				prog1.value = (counter/totalTime as float)*100
				pauseme.checked = true
				if pauseme.tooltip != "Pause auto-backups" then
				(
					pauseme.tooltip = "Pause auto-backups"
				)
			)else()
		)else
		(
			pauseMe.checked = false
			prog1.color = col3
			prog1.value = 100
			if pauseme.tooltip != "Resume auto-backups" then
			(
				pauseme.tooltip = "Resume auto-backups"
			)
			
		)
	)
)


wPos = getmaxwindowpos()
wSize = getmaxwindowsize()

createdialog MT_autoback style:#(#style_sunkenedge) pos:[-10000,-10000] width:220 height:17


MT_autoback_menu.min5.checked = true
MT_autoback.copyfiletest false


callbacks.removeScripts id:#MT_autobackCallback1
callbacks.addScript #filePostSave "try(MT_autoback.postSave())catch(print \"MT_autoback callback1 error\")" id:#MT_autobackCallback1

callbacks.removeScripts id:#MT_autobackCallback2
callbacks.addScript #systemPostReset "try(MT_autoback.postReset())catch(print \"MT_autoback callback2 error\")" id:#MT_autobackCallback2

callbacks.removeScripts id:#MT_autobackCallback3
callbacks.addScript #filePostOpen "try(MT_autoback.postOpen())catch(print \"MT_autoback callback3 error\")" id:#MT_autobackCallback3


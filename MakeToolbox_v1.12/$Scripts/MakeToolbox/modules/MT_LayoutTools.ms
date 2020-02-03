/*
#NAME:Layout Tools
#VERSION:1.1
#INSTRUCTIONS:
Quickly and easily save/load 3dsmax 
UI Layouts.
http://www.makevisual.com/learning/MT_LayoutTools.htm
#SOURCE:Tyson Ibele http://www.tysonibele.com
#HISTORY:03.26.2012 >> Integrated into toolbox
*/

options.printallelements = true

if (LayerManager.getLayerFromName "zz-MAKE") == undefined then
(
	-- Setting up the MAKE Tools Layer and MAKE_SceneSettingsRoot
	global MAKE_SceneSettingsLayer = layermanager.newLayerFromName "zz-MAKE"
	global MAKE_SceneSettingsRoot = (point name:"MAKE_SceneSettingsRoot" pos:[0,0,-1000] centermarker:off axisTripod:off cross:on box:off size:20 wirecolor:[255,0,0])
	MAKE_SceneSettingsLayer.on = false
	MAKE_SceneSettingsLayer.lock = True
	MAKE_SceneSettingsLayer.addNode MAKE_SceneSettingsRoot
)else
(
	global MAKE_SceneSettingsLayer = layermanager.getLayerFromName  "zz-MAKE"
	
	-- Tests for MAKE_SceneSettingsRoot
	if $MAKE_SceneSettingsRoot == undefined then
	(
		
		-- If unable to define the MAKE_SceneSettingsRoot, prompts tue user to rebuild them.
		if querybox "MAKE SceneSettings have become corrupt, would you like rebuild?" then
			(
				
				-- Re-creates the MAKE_SceneSettingsRoot
				global MAKE_SceneSettingsRoot = (point name:"MAKE_SceneSettingsRoot" pos:[0,0,-1000] centermarker:off axisTripod:off cross:on box:off size:20 wirecolor:[255,0,0])
				MAKE_SceneSettingsLayer.addNode MAKE_SceneSettingsRoot
			)
			else()
	)
	
	-- Initalizes the MAKE_SceneSettingsRoot
	else(MAKE_SceneSettingsRoot = $MAKE_SceneSettingsRoot)
)

			
try(removeSubRollout MakeToolbox.theSubrollout layoutPresetsModule)catch()
layoutPresetsModuleVer = 1.0

fn DialogWindowOpsClass =
(
	source = "Imports System.Runtime.InteropServices
	Imports System.Drawing
	Imports System.Text
	Imports System
		
	Public Class DialogWindowOps
		Public Const MOUSEEVENTF_LEFTDOWN As Int32 = &H2 ' left button down
		Public Const MOUSEEVENTF_LEFTUP As Int32 = &H4 ' left button up

		Public Structure RECT
			Public left As Integer
			Public top As Integer
			Public right As Integer
			Public bottom As Integer
			Public ReadOnly Property Width() As Integer
				Get
					Return right - left
				End Get
			End Property
			Public ReadOnly Property Height() As Integer
				Get
					Return bottom - top
				End Get
			End Property
		End Structure
		Public Structure POINTAPI
			Public x As Integer
			Public y As Integer
		End Structure
		Public Structure WINDOWPLACEMENT
			Public Length As Integer
			Public flags As Integer
			Public showCmd As Integer
			Public ptMinPosition As POINTAPI
			Public ptMaxPosition As POINTAPI
			Public rcNormalPosition As RECT
		End Structure
		<DllImport(\"user32.dll\")> Public Shared Function MoveWindow(ByVal hWnd As System.IntPtr, ByVal x As Integer, ByVal y As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal bRepaint As Boolean) As Boolean
		End Function
		<DllImport(\"user32.dll\")> Public Shared Function GetWindowRect(ByVal hWnd As System.IntPtr, ByRef lpRect As RECT) As Boolean
		End Function
		<DllImport(\"user32.dll\")> Public Shared Function GetWindowPlacement(ByVal hWnd As System.IntPtr, ByRef lpwndpl As WINDOWPLACEMENT) As Boolean
		End Function
		<DllImport(\"user32.dll\")> Public Shared Function GetWindowText(ByVal hWnd As System.IntPtr, ByVal lpString As StringBuilder, ByVal nMaxCount As Integer) As Integer
		End Function
		<DllImport(\"user32.dll\")> Public Shared Function GetWindowTextLength(ByVal hWnd As System.IntPtr) As Integer
		End Function

		Declare Function apimouse_event Lib \"user32.dll\" Alias \"mouse_event\" (ByVal dwFlags As Int32, ByVal dX As Int32, ByVal dY As Int32, ByVal cButtons As Int32, ByVal dwExtraInfo As Int32) As Boolean

			Declare Function SetCursorPos Lib \"user32.dll\" (ByVal x As Integer, ByVal y As Integer) As Long
			
			 Public Declare Function WindowFromPoint Lib \"user32\" (ByVal Point As Point) As Integer

		Public Declare Function GetAncestor Lib \"user32\" (ByVal hWnd As IntPtr, ByVal flags As Integer) As IntPtr

		Public Function WindowSize(ByVal Hwnd As System.IntPtr) As System.Drawing.Size
			Dim LPRECT As RECT
			GetWindowRect(Hwnd, LPRECT)
			Dim WinSize As System.Drawing.Size = New System.Drawing.Size(LPRECT.Width, LPRECT.Height)
			Return WinSize
		End Function
		
		Public Function WindowPosition(ByVal Hwnd As System.IntPtr) As System.Drawing.Point
			Dim intRet As Integer
			Dim wpTemp As WINDOWPLACEMENT = New WINDOWPLACEMENT()
			wpTemp.Length = System.Runtime.InteropServices.Marshal.SizeOf(wpTemp)
			intRet = GetWindowPlacement(Hwnd, wpTemp)
			Dim WinPoint As System.Drawing.Point = New System.Drawing.Point(wpTemp.rcNormalPosition.left, wpTemp.rcNormalPosition.top)
			Return WinPoint
		End Function
		
			Public Function getWindowFromPoint(ByVal x as Integer, ByVal y as Integer) As Integer
			Dim hwnd as Integer = WindowFromPoint(New System.Drawing.Point(x, y))

			Return (GetAncestor(New System.IntPtr(hwnd), 2))
		  
		End Function
		
			 Public Sub movewindow(ByVal hwnd As IntPtr, ByVal x As Integer, ByVal y As Integer)
			movewindow(hwnd, x, y, WindowSize(hwnd).Width, WindowSize(hwnd).Height, True)
			End Sub
		
		Public Function dragmouse(ByVal startX As Integer, ByVal startY As Integer, ByVal endX As Integer, ByVal endY As Integer) As Boolean
			
			SetCursorPos(startX, startY)

			apimouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)

			SetCursorPos(endX, endY)

			apimouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
			
			
				'SetCursorPos(p3.X + 50, p3.Y + p1.Y + 90)

			'apimouse_event(MOUSEEVENTF_LEFTDOWN, 10, 10, 0, 0)

			'SetCursorPos(p3.x + 100, p3.y + 10)

			'apimouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
				 
				 Return True
		End Function
	End Class"

	VBProvider = dotnetobject "Microsoft.VisualBasic.VBCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.add "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.drawing.dll"
	compilerParams.GenerateInMemory = on
	compilerResults = VBProvider.CompileAssemblyFromSource compilerParams #(source)


	-- this is very useful to debug your source code and check for referencing errors
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
	return compilerResults.CompiledAssembly.CreateInstance "DialogWindowOps"
)

global WindowOps = DialogWindowOpsClass()
intPtrLayerManagerHandle = dotnetobject "System.IntPtr" (windows.getmaxhwnd())
global MT_windowArr = #()
global MT_windowPosArr = #()
global layoutPresets
global localLayoutMenu
	
global lp_presetName
global lp_presetName_text = "Choose local preset name"
	
rollout lp_presetName lp_presetName_text
(
	edittext nameText "" width:190 align:#left offset:[-12,0]
	button okay "OK" width:30 height:20 offset:[183,-23] align:#left

	on okay pressed do
	(
		layoutpresetsmodule.pName = nameText.text
		if nameText.text == "" then
		(
			messagebox ("Valid preset name required!")
		)else
		(
			if (layoutPresetsModule.saveType == "local") then
			(
				layoutPresetsModule.saveNewLayout nameText.text
				try(destroydialog lp_presetName)catch()
				
			)else
			(
				layoutPresetsModule.saveToScene nameText.text
				try(destroydialog lp_presetName)catch()
			)
		)
		
	)
	
	on nameText entered val do
	(
		okay.pressed()
	)
	on lp_presetName close do
	(
		layoutpresetsModule.pName = ""
	)
	on lp_presetName open do
	(
		
		nameText.text = layoutPresetsModule.nameText
		setfocus nameText
	)
)

global saveMenu

rcmenu saveMenu
(
	menuItem saveLocal "Save Locally..."
	menuItem saveScene "Save To Scene..."
	
	on saveLocal picked do
	(
		layoutPresetsModule.saveLocal()
	)
	
	on saveScene picked do
	(
		layoutPresetsModule.saveScene()
	)
	
	
)

rollout layoutPresetsModule ("Layout Presets")
(
	local iconsStr = "#(#((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 190 190 190), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195)), #((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 192 192 192), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 204 204 204), (color 127 127 127)), #((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 192 192 192), (color 204 204 204), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 127 127 127)), #((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 192 192 192), (color 204 204 204), (color 102 102 102), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 192 192 192), (color 204 204 204), (color 102 102 102), (color 229 229 229), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 128), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 184 184 184), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 192 192 192), (color 204 204 204), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 128 128 128), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 128), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 184 184 184), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 184 184 184), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 128 128 128), (color 0 0 0), (color 255 255 255), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 153 153 153), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 0 0 0), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 255 255 255), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 255), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 128 128 128), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 128), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 205 205 205), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 184 184 184), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 184 184 184), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 191 191 191), (color 191 191 191), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 0), (color 255 255 255), (color 255 255 0), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 128), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 128 128 128), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 184 184 184), (color 205 205 205), (color 184 184 184), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 184 184 184), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 184 184 184), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 153 153 153), (color 191 191 191), (color 191 191 191), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 255), (color 255 255 0), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 205 205 205), (color 184 184 184), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 255 255 255), (color 0 0 0), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 229 229 229), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 255 255 0), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 128 128 128), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 128 128 128), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 184 184 184), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 184 184 184), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 184 184 184), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 102 102 102), (color 127 127 127)), #((color 0 0 0), (color 0 0 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 128 128 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 164 164 164), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 174 174 174), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 247 247 247), (color 247 247 247), (color 255 255 255), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 247 247 247), (color 0 0 0), (color 127 127 127), (color 127 127 127), (color 127 127 127), (color 127 127 127), (color 127 127 127), (color 127 127 127), (color 127 127 127)), #((color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 192 192 192), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 164 164 164), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 0 0 0), (color 128 128 128), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195), (color 195 195 195)))"
	local pName
	local defaultDir = "$Scripts\\MakeToolbox\\MAKE_layoutTools\\"
	local localDir =  "$Scripts\\MakeToolbox\\MAKE_layoutTools\\"
	
	local strToBit 
	local bitToArr
	
	local iconBits = #()
	
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
	
	fn bitToArr bit1 =
	(
		bitArr = #()
		for g in 0 to 3 do
		(
			append bitArr (bitmap 16 16)
			for q in 0 to 15 do
			(
				p = getpixels bit1 [0 + 16*g,q] 16
				setpixels bitarr[bitarr.count] [0,q] p
			)

		)
		bitArr
	)

	local thisSessionPreset
	local sceneObjName = "MAKE_layoutPresets"
	local sceneObj
	
	local oldActive
	local isMaxed = false
	
	local saveType = "local"
	
	local localSep = "- - - - - - - Local - - - - - - -"
	local sceneSep = "- - - - - - - Scene - - - - - -"
		
	local layoutType = #(undefined, undefined)
	local layoutFiles = #(undefined, undefined)
	local layoutFileNames = #(undefined, undefined)
	local layoutData = #(undefined, undefined)
	local isBeingUpdated = #(undefined, undefined)
	local activeFile = undefined
	local activeType = undefined
	
	local loadViewportLayout
	local resizeViewport
	local getViewportSizeInfo
	local getViewportSizeArr
	local getOrthoZoomBounds
	local restoreWindows
	local getOffendingWindows
	local isMaximized
	local getScenePresets


	
	local lastLayoutDList = 0	
	
	local localStart = 0	
	local sceneStart = 0
	
	local loadFromFile
	local updateListItems
	local loadFromScene
	local getDefaultPresets
	local loaddata
	local applyLayout
	local saveToScene
	local deleteScenePreset
	local deleteLocalPreset
	local saveNewLayout
	
	local saveLocal
	local saveScene
	
	local nameText = ""
	button applyPreset ">" width:20 height:21 offset:[130, 0] align:#left 	
	
	dropdownlist layoutDList "" width:138 height:15 offset:[-10, -26] selection:0 items:#(localSep, sceneSep)
	
	button loadPreset "" width:20 height:20 align:#left offset:[-8,-4] visible:false
	button savePreset "" width:20 height:20  align:#left offset:[-8, -25] enabled:false
	button revertPreset "" width:20 height:20  align:#left offset:[15, -25]
	button deletePreset "" width:20 height:20  align:#left offset:[38, -25] enabled:false
	
	on savePreset pressed do
	(
		
		popupmenu saveMenu pos:mouse.screenpos
	)
	
	on revertPreset pressed do
	(
			if layoutDList.selected != localSep and layoutDList.selected != sceneSep then
			(
				
				isBeingUpdated[layoutdList.selection] = false
				if activeFile == layoutFiles[layoutdList.selection] then 
				(
				
					activeFile = undefined
					activeType = undefined
					applyLayout ()
				)
				
				
			)
	)
	
	on deletePreset pressed do
	(
		if layoutDlist.selection < localStart then
		(
			
		)else if layoutDlist.selection < sceneStart then
		(
			if layoutDList.selected != localSep and layoutDList.selected != sceneSep then
			(
				deleteLocalPreset()
			)
		)else
		(
			
			if layoutDList.selected != localSep and layoutDList.selected != sceneSep then
			(
				deleteScenePreset()
			)
			
		)
		
		
		
	)
	
	on applyPreset pressed do
	(
		if layoutdlist.selected == localSep or layoutdlist.selected == sceneSep then return false
		applyLayout()
	)
	
	fn getCategories =
	(
		localStart = layoutDList.items.count + 1
		sceneStart = layoutDList.items.count + 1
		
		for q in 1 to layoutDList.items.count do
		(
			if layoutDList.items[q] == localSep then localStart = q
			if layoutDList.items[q] == sceneSep then sceneStart = q
		)
		
		if localStart > sceneStart then localStart = sceneStart
		if sceneStart < localStart then sceneStart = localStart
	)
	
	fn updateLayoutDListSelection =
	(
				
		if layoutDList.selection > 0 then
		(
			
			if (layoutDList.items[layoutDList.selection] == localSep or layoutDList.items[layoutDList.selection] == sceneSep)  then
			(
				if 	lastLayoutDList > 0 and lastLayoutDList <= layoutDList.items.count and layoutDList.items[lastLayoutDList] != localSep and layoutDList.items[lastLayoutDList] != sceneSep then
				(
						layoutDList.selection = lastLayoutDList
				)else
				(
					layoutDList.selection = 0
					lastLayoutDList = 0
				)
			
				
			)else
			(
				lastLayoutDList = layoutDList.selection
				
			)
			
			
			
		)
		
		getcategories()
		
		if (layoutDList.selection <= 0) then
		(
			loadPreset.enabled = false
			savePreset.enabled = true
			revertPreset.enabled = false
			deletePreset.enabled = false
			
		)else if layoutDlist.selection < localStart then
		(

			loadPreset.enabled= false
			savePreset.enabled = true
			revertPreset.enabled = true
			deletePreset.enabled = false
			
		)else if layoutDList.selection < sceneStart then
		(
			loadPreset.enabled= false
			savePreset.enabled = true
			revertPreset.enabled = true
			deletePreset.enabled = true
			
		)else
		(
			loadPreset.enabled = false
			savePreset.enabled= true
			revertPreset.enabled = true
			deletePreset.enabled = true
		)
		
		
	)
	
	on layoutDList selected val do
	(
		updateLayoutDListSelection()
		
	)
	
	on layoutpresetsmodule open do
	(
		thisSessionPreset = getViewportSizeArr "default" ""
		getViewportSizeInfo thisSessionPreset
		
		makeDir defaultDir
		makeDir localDir
		
		sceneObj = getnodebyname sceneObjname
		if not isvalidnode sceneObj then
		(
			sceneObj = point()
			sceneObj.wirecolor = yellow
			sceneObj.name = sceneObjName
			
			mLayer = LayerManager.getLayerFromName "zz-MAKE"
			if mLayer != undefined then
			(
				mLayer.addNode sceneObj
			)
		
	
			if (isvalidnode $MAKE_SceneSettingsRoot) then
			(
				sceneObj.parent = $MAKE_SceneSettingsRoot
			)
			
			
			
		)
		
		
		farr = getFiles (localDir + "*.mlp")
		
		for q in 1 to farr.count do
		(
			loadfromfile filename:farr[q]
		)
		
		loadFromscene()
		
		getDefaultPresets()
		
			

		iconBit = strToBit iconsStr
		
		loadPreset.images = #(iconBit, iconBit, 9,1,1,5,5 )
		savePreset.images = #(iconBit, iconBit, 9,2,2,6,6 )
		revertPreset.images = #(iconBit, iconBit, 9,3,3,7,7 )
		deletePreset.images = #(iconBit, iconBit, 9,4,4,8,8 )
		
		applyPreset.images = #(iconBit, iconBit, 9,9,9,9,9 )
		
		layoutDList.selection = 1
		
		updateLayoutDListSelection()
		
		
	)
	
	fn loadFromFile filename:"" data:""=
	(
		getCategories()
		
		added = false
		data = undefined
		
		presetfilepath = filename

			
		if presetFilePath != undefined then
		(
			presetfile = fopen presetFilePath "rb"
			if presetfile != undefined then
			(
				saveData = readString presetFile
				
				if saveData != "" then
				(
					data = execute saveData
					
					fItem = 0
					
					for q in 1 to layoutFiles.count do
					(
						if layoutType[q] == "local" and layoutFiles[q] == presetfilePath then (fItem = q; exit)
					)
					
					if fItem == 0 then
					(
						insertItem presetFilePath layoutFiles sceneStart
						insertItem data layoutData  sceneStart
						insertItem data[1] layoutType sceneStart
						insertItem false isBeingUpdated  sceneStart
						updateListItems()
						layoutDList.selection = sceneStart
			
					)else
					(
						if (activeFile == layoutFiles[fItem] and activeType == layoutType[fItem]) then (activeFile = undefined; activeType = undefined)
						layoutData[fItem] = data
						isBeingUpdated[fItem] = false
						layoutDList.selection = fItem
					)
					
				)
			)
			
			fclose presetFile
		)
		
		getCategories()
		
		data
		
	)
	
	fn updateListItems =
	(
		
		getcategories()
		
		sceneObj = getnodebyname sceneObjName
		
		layoutFileNames = #()
	
		defaultFileNames = #()
		localFileNames = #()
		sceneFileNames = #()
		
		q = 1
		while q <= layoutFiles.count do
		(
			if layoutFiles[q] == undefined then
			(
				deleteItem layoutFiles q
				deleteItem layoutType q
				deleteItem layoutData q
				deleteItem isBeingUpdated q
				
				continue
			)
				
			if layoutType[q] == "default" then
			(
				append defaultFileNames layoutdata[q][2]
			
			)else if layoutType[q] == "local" then
			(
				
				append localFileNames ((getfilenamefile layoutFiles[q]) )
			)else
			(
				if (isvalidnode sceneObj) then
				(					
					append sceneFileNames layoutdata[q][2]
					
				)
			)
			q += 1
		)
		
		globalDList = #()
		
		for q in 1 to defaultFileNames.count do
		(
			append globalDList defaultFileNames[q]
			
		)
		
		if localFileNames.count > 0 then 
		(
			insertItem undefined layoutFiles (defaultFileNames.count + 1)
			insertItem undefined layoutType (defaultFileNames.count + 1)
			insertItem undefined layoutFileNames (defaultFileNames.count + 1)
			insertItem undefined layoutData (defaultFileNames.count + 1)
			insertItem undefined isBeingUpdated (defaultFileNames.count + 1)
			
			append globalDList localSep
		)
		
		for q in 1 to localFileNames.count do
		(
			append globalDList localFileNames[q]
		)
		
		if sceneFileNames.count > 0 then 
		(
			startInx = -1
			if localFileNames.count > 0 then
			(
				startInx = (defaultFileNames.count + 1 + localFileNames.Count + 1)
			)else
			(
				startInx = (defaultFileNames.count + 1)
			)
			
			insertItem undefined layoutFiles startInx
			insertItem undefined layoutType startInx
			insertItem undefined layoutFileNames startInx
			insertItem undefined layoutData startInx
			insertItem undefined isBeingUpdated startInx
			
			append globalDList sceneSep
		)
		
		for q in 1 to sceneFileNames.count do
		(
			append globalDList sceneFileNames[q]
		)
		
		layoutDList.items = globalDList
		
		getcategories()
	)
	
	fn loadfromscene =
	(
		sceneObj = getnodebyname sceneObjName
		if (isvalidnode sceneObj) then
		(
			for q in 300 to 400 do
			(
				data = getappdata sceneObj q
				
				if data != undefined and data != "" then
				(
					data = execute data
					
					fItem = 0
					
					for q in 1 to layoutfiles.count do
					(
						if layoutFiles[q] == data[2] and layouttype[q] == "scene" then
						(
							fItem = q
						)
					)
					
					if fItem == 0 then
					(
							
						append layoutFiles data[2]
						append layoutData data
						append layoutType data[1]
						append isBeingUpdated false
						updateListItems()
						layoutDList.selection = layoutDList.items.count
		
						
					)else
					(
						if (activeFile == layoutFiles[fItem] and activeType == layoutType[fItem]) then (activeFile = undefined; activeType = undefined)
						layoutData[fItem] = data
						isBeingUpdated[fItem] = false
						layoutDList.selection = fItem
					)
					
				)
			)
		)
		
	)
	
	fn getScenePresets presetInx:-1=
	(
		sceneObj = getnodebyname sceneObjName
		if isvalidnode sceneObj then
		(
			if presetInx != -1 then
			(
				d = getAppData sceneObj (300 + (presetInx - 1))
				if d != undefined and d != "" then return (execute d)
			)
		)
		return ""
	)
	
	
	fn getDefaultPresets presetInx:-1=
	(
		
		iniFile = (defaultDir + sceneObjName + ".ini")
		if not doesfileexist iniFile then
		(
			newFile = createfile iniFile
			close newFile
		)
		
		for q in 1 to 5 do
		(
			if presetInx != -1 and q != presetInx then continue
				
			data = ""
			--data = getinisetting iniFile "Layout Presets" ("Preset" + q as string)
			
			if q == 1 then
			(
				thisSessionPreset[2] = "[default]"
				data = thisSessionPreset as string
				
				setinisetting iniFile "Layout Presets" ("Preset" + q as string) data
				
			)else if q == 2 then
			(
				data  = #("default", "Animation", #layout_4, 1, [0,0], [2290,1050], true, [2290,-1], [1549,1051], false, [0,0], [0,0], false, #(true, [0,0], [0,0]), "layoutStart", 2, #(1, "v", 844), #(1, "h", 386), 4, #view_top, (matrix3 [1,0,0] [0,1,0] [0,0,1] [4.13919,-3.89571,0]), 58.8531, "", #([-84.2201,-76.1852,-80.0809], [75.9417,83.9766,80.0809]), #view_front, (matrix3 [1,0,0] [0,0,-1] [0,1,0] [4.11185,-3.62811,0]), 61.0049, "", #([-83.9063,-79.7944,-76.1663], [75.6826,79.7944,83.4225]), #view_left, (matrix3 [0,0,-1] [-1,0,0] [0,1,0] [3.73898,-3.73898,0]), 54.0321, "", #([-79.6159,-75.877,-75.877], [79.6159,83.3549,83.3549]), #view_persp_user, (matrix3 [0.707107,0.353553,-0.612372] [-0.707107,0.353553,-0.612372] [0,0.866025,0.5] [0,0,-250]), 45.0, "", #([0,0,0], [0,0,0]))
				data = data as string
				setinisetting iniFile "Layout Presets" ("Preset" + q as string) data
					
			)else if (q == 3) then
			(
				data  = #("default", "Particles", #layout_4, 1, [0,0], [2290,1050], false, [0,0], [0,0] , true,  [2290,-1], [1549,1051], false, #(true, [0,0], [0,0]), "layoutStart", 2, #(1, "v", 844), #(1, "h", 386), 4, #view_top, (matrix3 [1,0,0] [0,1,0] [0,0,1] [4.13919,-3.89571,0]), 58.8531, "", #([-84.2201,-76.1852,-80.0809], [75.9417,83.9766,80.0809]), #view_front, (matrix3 [1,0,0] [0,0,-1] [0,1,0] [4.11185,-3.62811,0]), 61.0049, "", #([-83.9063,-79.7944,-76.1663], [75.6826,79.7944,83.4225]), #view_left, (matrix3 [0,0,-1] [-1,0,0] [0,1,0] [3.73898,-3.73898,0]), 54.0321, "", #([-79.6159,-75.877,-75.877], [79.6159,83.3549,83.3549]), #view_persp_user, (matrix3 [0.707107,0.353553,-0.612372] [-0.707107,0.353553,-0.612372] [0,0.866025,0.5] [0,0,-250]), 45.0, "", #([0,0,0], [0,0,0]))
				data = data as string
				setinisetting iniFile "Layout Presets" ("Preset" + q as string) data
			)
			
			
			
			
			if data != "" then
			(
				loaddata (execute data)
			)
			
			if presetInx != -1 then return (execute data )
				
		)
		return ""
	)
	fn loadData data =
	(
		getcategories()
		fItem = 0
		for q in 1 to layoutfiles.count do
		(
		
			if layoutFiles[q] == data[2] and layouttype[q] == "local" then
			(
				fItem = q
				exit
			)else if layoutFiles[q] == data[2] and layouttype[q] == "default" then
			(
				fItem = q
				exit
			)
		)
		
		if fItem == 0 then
		(
			insertitem data[2] layoutFiles localStart
			insertitem data layoutData localStart
			insertitem data[1] layoutType localStart
			insertitem false isBeingUpdated localStart
			updateListItems()
			layoutdList.selection = localStart
			
		)else
		(
			if (activeFile == layoutFiles[fItem] and activeType == layoutType[fItem]) then (activeFile = undefined; activeType = undefined)
			layoutData[fItem] = data
			layoutDList.selection = fItem
			isBeingUpdated[fItem] = false
			
		)
	)
	
	fn applyLayout =
	(
		
		if activeFile != undefined and activeType != undefined then
		(
			arrInx = 0
			
			for q in 1 to layoutFiles.count do
			(
				if layoutFiles[q] == activeFile and layoutType[q] == activeType then
				(
					arrInx = q
					exit
				)
			)
			
			if (arrInx > 0 ) then
			(
				isBeingUpdated[arrInx] = true
				newDataArr = getViewportSizeArr layoutdata[arrinx][1] layoutdata[arrinx][2]
				getViewportSizeInfo newDataArr
				layoutData[arrInx] = newDataArr
			
			)
			
		)
				
		if layoutDList.selection > 0 then
		(
			
			disablesceneredraw()
			
			try
			(
				if (isBeingUpdated[layoutDList.selection]) then
				(
					data = layoutData[layoutDList.selection]
				)else
				(
					if (layoutType[layoutDList.selection] == "default") then
					(
						data = getDefaultPresets presetInx:(layoutDList.selection )
					)else if (layoutType[layoutDList.selection] == "local") then
					(
						data = loadFromFile filename:layoutFiles[layoutDList.selection]	
					)else
					(
					
						data = getScenePresets presetInx:((layoutDList.selection - sceneStart))
					)
				)
			
				
				if data == undefined or data == "" then
				(
					msgbox ("Could not load data")
				)else
				(
					loadViewportLayout data
				)
				
				
				activeFile = layoutFiles[layoutDList.selection]
				activeType = layoutType[layoutDList.selection]
					
				
			)catch(print (getcurrentexception()))		
			
			enablesceneredraw()
				
			redrawviews()
		)
		
	)
	
	
	fn isMaximized =
	(
		
		l1 = viewport.getlayout()
		
		if (l1 == #layout_1) then
		(
			max tool maximize
			l2 = viewport.getlayout()
			max tool maximize
		)		
		if (l1 == #layout_1) then
		(
			if (l1 == l2) then 
			(
				false
			)else
			(
				true
			)				
		)else
		(
			false
		)
		
	)
	
	fn getOffendingWindows startX startY =
	(
		WindowOps.SetCursorPos startX startY
					
		maxHwnd = (windows.getmaxhwnd() as integer)
		windowHwnd = WindowOps.getWindowFromPoint mouse.screenpos[1] mouse.screenpos[2]
			
		while (windowHwnd != maxHwnd) do
		(	
		
			append MT_windowArr windowHwnd
			wPos = WindowOps.WindowPosition (dotnetobject "System.IntPtr" (windowHwnd))
			append MT_windowPosArr [wPos.x, wPos.y]
				
			WindowOps.movewindow (dotnetobject "System.IntPtr" (windowHwnd)) (sysInfo.desktopsize[1] - 75) (sysinfo.desktopsize[2] - 75)

			windowHwnd = WindowOps.getWindowFromPoint mouse.screenpos[1] mouse.screenpos[2]

		)
	)
	
	fn restoreWindows =
	(
		WindowOps.moveWindow intPtrLayerManagerHandle oldPos[1] oldPos[2] oldSize[1] oldSize[2] true
		viewport.setLayout oldLayout
		viewport.resetallviews()
		viewport.activeviewport = oldActive
	)
	
	fn getOrthoZoomBounds =
	(
		if not viewport.IsPerspView() then
		(
			theMagicNumber = 2.34651
			
			viewFactor = ( getScreenScaleFactor [0,0,0] ) / theMagicNumber
			theScale = [viewFactor, viewFactor, viewFactor]
			
			viewOffset = -(inverse (getViewTM())).row4
			pointA = -theScale - viewOffset
			pointB = theScale - viewOffset
			
			#(pointA, pointB)
		)else
		(
			#([0,0,0], [0,0,0])
		)
	)
  
	fn getCommandPanelInfo =
	(
		cmdInfo = #()
		
		cmdOpen = windows.getchildhwnd 0 "Command Panel"
		
		if (cmdOpen == undefined) then
		(
			append cmdInfo false
			append cmdInfo [0,0]
			append cmdInfo [0,0]
		)else
		(
			append cmdInfo true
			cPos = windowOps.windowPosition (dotnetobject "System.IntPtr" cmdOpen[1])
			append cmdInfo [cPos.x, cPos.y]
			cSize = windowOps.windowSize (dotNetObject "System.IntPtr" cmdOpen[1])
			append cmdInfo [cSize.width, cSize.height]
		)
		
		cmdInfo
	)
	
	fn loadCommandPanelInfo cmdInfo =
	(
	
		if (cmdInfo[1] == false) then
		(
			if (windows.getchildhwnd 0 "Command Panel") != undefined then
			(
				ini = cui.getConfigFile()
				pos = getIniSetting ini "Command Panel" "CurPos"
				 
				pos = "8" + (trimleft pos "0123456789") -- 8 is attached, 16 is free
				setIniSetting ini "Command Panel" "CurPos" pos
				cui.loadConfig ini
			)
		)else
		(
			
			cPanel = windows.getchildhwnd 0 "Command Panel"
			if (cPanel) == undefined then
			(
				ini = cui.getConfigFile()
				pos = getIniSetting ini "Command Panel" "CurPos"
				 
				pos = "16" + (trimleft pos "0123456789") -- 8 is attached, 16 is free
				setIniSetting ini "Command Panel" "CurPos" pos
				cui.loadConfig ini
				
				cPanel = windows.getchildhwnd 0 "Command Panel"
			)
			
			
			if (cPanel != undefined) then
			(
				windowOps.MoveWindow (dotnetobject "System.IntPtr" cPanel[1]) cmdInfo[2][1] cmdInfo[2][2] cmdInfo[3][1] cmdInfo[3][2] true
			)
		)
		
	)
	
	fn getViewportSizeArr type name1= 
	(	
		
		
		isMaxed = isMaximized()
		
		if (isMaxed) then (max tool maximize)
		
		oldActive = viewport.activeviewport
		
					
		(dotnetclass "System.Windows.Forms.Application").DoEvents()
		
		layout = viewport.getlayout()
		arr = #()
		
		append arr type
		append arr name1
		append arr layout
		append arr viewport.activeviewport
		append arr (getmaxwindowpos())
		append arr (getmaxwindowsize())
		
		----
		
		tViewHwnd = windows.getChildHWND 0 "Track View - Curve Editor"
		
		if (tViewHwnd != undefined) then
		(
			append arr true
			pos = (WindowOps.WindowPosition (dotnetobject "System.IntPtr" tViewHwnd[1]))
			size = (WindowOps.WindowSize (dotnetobject "System.IntPtr" tViewHwnd[1]))
			append arr [pos.x, pos.y]
			append arr [size.width, size.height]
		)else
		(
			append arr false
			append arr [0,0]
			append arr [0,0]
		)
		
		-----
		
		pViewHwnd = windows.getChildHWND 0 "Particle View"
		
		if (pViewHwnd != undefined) then
		(
			append arr true
			pos = (WindowOps.WindowPosition (dotnetobject "System.IntPtr" pViewHwnd[1]))
			size = (WindowOps.WindowSize (dotnetobject "System.IntPtr" pViewHwnd[1]))
				
			append arr [pos.x, pos.y]
			append arr [size.width, size.height]
		)else
		(
			append arr false
			append arr [0,0]
			append arr [0,0]
		)

		append arr isMaxed
		
		append arr (getCommandPanelInfo())
		
		
		append arr "layoutStart"
			
		
		if (layout == #layout_1) then
		(
			append arr 0
		)else if (layout == #layout_2v) then
		(
			append arr 1
			append arr #(1, "v")
		)else if (layout == #layout_2h) then
		(
			append arr 1
			append arr #(1, "h")
		)
		else if (layout == #layout_2ht) then
		(
			append arr 1
			append arr #(1, "h")
		)
		else if (layout == #layout_2h) then
		(
			append arr 1
			append arr #(1, "h")
		)
		else if (layout == #layout_3vl) then
		(
			append arr 2
			append arr #(1, "v")
			append arr #(1, "h")
		)
		else if (layout == #layout_3v) then
		(
			append arr 2
			append arr #(1, "v")
			append arr #(2, "h")
		)
		else if (layout == #layout_3ht) then
		(
			append arr 2
			append arr #(1, "v")
			append arr #(1, "h")
		)
		else if (layout == #layout_3h) then
		(
			append arr 2
			append arr #(1, "h")
			append arr #(2, "v")
		)
		else if (layout == #layout_4vl) then
		(
			append arr 3
			append arr #(1, "v")
			append arr #(1, "h")
			append arr #(2, "h")
		)
		else if (layout == #layout_4v) then
		(
			append arr 3
			append arr #(1, "v")
			append arr #(2, "h")
			append arr #(3, "h")
		)
		else if (layout == #layout_4ht) then
		(
			append arr 3
			append arr #(1, "h")
			append arr #(1, "v")
			append arr #(2, "v")
		)
		else if (layout == #layout_4h) then
		(
			append arr 3
			append arr #(1, "h")
			append arr #(2, "v")
			append arr #(3, "v")
		)
		else if (layout == #layout_4) then
		(
			append arr 2
			append arr #(1, "v")
			append arr #(1, "h")
		)
		
		append arr viewport.numviews

		for q in 1 to viewport.numviews do
		(
			viewport.activeViewport = q
			append arr (viewport.getType())
			append arr (viewport.getTM())
			append arr (viewport.getFOV())
				
			cam = viewport.getcamera()
			if cam == undefined then
			(
				append arr ""
			)else
			(
				append arr cam.name
			)
			
			append arr (getOrthoZoomBounds())
			
		)
		
		
			
		arr
	)

	fn getViewportSizeInfo arr =
	(
		
		
		lStart = 0
		lEnd = 0
		for q in 1 to arr.count do
		(
			if arr[q] == "layoutStart" then
			(
				lStart = q + 2
				lEnd = lStart + arr[q + 1]
				exit
			)
		)
				
		for q in lStart to (lEnd - 1) do
		(
			viewport.activeViewport = arr[q][1]
			
			x = gw.getwinsizex()
			y = gw.getwinsizey()
			
			if (arr[q][2] == "v") then
			(
				append arr[q] x
			)else
			(
				append arr[q] y
			)
			
		)
		
		viewport.activeviewport = oldActive
		
		if (isMaxed) then
		(
			max tool maximize
		)
		
		
	)
	

	fn resizeViewport orientation val =
	(
		mPos = mouse.screenpos
		
		windowpos = mouse.screenpos - mouse.pos
		
		if orientation == 1 then
		(
			startX = windowPos[1] + (gw.getwinsizex()) + 2
			startY = windowPos[2] + 2
		)else
		(
			startX = windowPos[1] + 2
			startY = windowPos[2] + (gw.getwinsizey()) + 2
		)
				
		getOffendingWindows startX startY	
				
		if orientation == 1 then
		(
			WindowOps.dragmouse startX startY (startX + val)  startY	
		)else
		(
			WindowOps.dragmouse startX startY startX (startY + val)
		)
			
		WindowOps.setcursorpos mPos[1] mPos[2] 
		
	)

	fn loadViewportLayout arr =
	(
		if arr.count > 0 then 
		(
			
			if (ismaximized()) then max tool maximize
			
			startInx = 2
			viewport.setlayout arr[startInx+1]
			
			
			WindowOps.moveWindow intPtrLayerManagerHandle arr[startInx+3][1] arr[startInx+3][2] arr[startInx+4][1] arr[startInx+4][2]  true
			
			MT_windowArr = #()
			MT_windowPosArr = #()
			
			tViewHwnd = windows.getChildHWND 0 "Track View - Curve Editor"
			
			if arr[startInx+5] == true then
			(
				if (tViewHwnd == undefined) then
				(
					trackviews.open "Track View - Curve Editor"
					tViewHwnd = windows.getChildHWND 0 "Track View - Curve Editor"
				)				
				WindowOps.moveWindow  (dotnetobject "System.IntPtr" tViewHwnd[1] ) arr[startInx+6][1] arr[startInx+6][2] arr[startInx+7][1] arr[startInx+7][2]  true
						
			)else
			(
				if tViewHwnd != undefined then
				(
					uiaccessor.closedialog (tviewhwnd[1])
				)
			)
			
			pViewHwnd = windows.getChildHWND 0 "Particle View"
			
			if arr[startInx+8] == true then
			(
				if (pViewHwnd == undefined) then
				(
					particleflow.openparticleview()
					
					pViewHwnd = windows.getChildHWND 0 "Particle View"
				)				
				WindowOps.moveWindow  (dotnetobject "System.IntPtr" pViewHwnd[1] ) arr[startInx+9][1] arr[startInx+9][2] arr[startInx+10][1] arr[startInx+10][2]  true
						
			)else
			(
				if pViewHwnd != undefined then
				(
					uiaccessor.closedialog (pViewHwnd[1])
				)
			)
			
			isMaxed = arr[startInx+11]
			
			cmdInfo = arr[startInx+12]
			
			loadCommandPanelInfo cmdInfo
			
			
			lStart = 0
			lEnd = 0
			for q in 1 to arr.count do
			(
				if arr[q] == "layoutStart" then
				(
					lStart = q + 2
					lEnd = lStart + arr[q + 1]
					exit
				)
			)
		
			for q in lStart to (lEnd - 1) do
			(
				
				viewport.activeViewport = arr[q][1]
				if (arr[q][2] == "v") then
				(
					desiredWidth = arr[q][3]
					width = gw.getwinsizex()
					
					resizeViewport 1 (desiredWidth - width)
				)else
				(
					desiredHeight = arr[q][3]
					height = gw.getwinsizey()
					
					resizeViewport 2 (desiredHeight - height)
				)
			)
			
			(dotnetclass "System.Windows.Forms.Application").DoEvents()
				
			arrInx = (lEnd)
			viewcount = arr[arrInx]
						
			for q in 1 to viewcount do
			(
				viewport.activeViewport = q
				
				arrInx += 1
				vType = arr[arrInx]
				arrInx += 1
				vTM = arr[arrInx]
				arrInx += 1
				vFOV = arr[arrInx]
				arrInx += 1
				vCam = arr[arrInx]
				viewCam = getNodeByName (vCam as string)
				arrInx += 1
				zBounds = arr[arrInx]
				
				camSet = false
				
				
				if (vType == #view_camera) then
				(
					if (isValidNode viewCam) then
					(
						if (iskindof viewCam Camera) then
						(
							camSet = true
							viewport.setcamera viewCam
						)
					)
				)
				
				if (vType == #view_camera and not camSet) then
				(
					viewport.setType #view_persp_user
				)else
				(
					viewport.settype vType
				)
				
				if (vType != #view_camera or not camSet) then
				(
					viewport.setTM vTM
					viewport.setFOV
				)
				
				if (not viewport.isperspview()) then
				(
					viewport.zoomtobounds false zBounds[1] zBounds[2]
				)
				
				
			)
			
			
			
			(dotnetclass "System.Windows.Forms.Application").DoEvents()

			for q in 1 to MT_windowArr.count do
			(
				WindowOps.movewindow (dotnetobject "System.IntPtr" (MT_windowArr[q])) MT_windowPosArr[q][1] MT_windowPosArr[q][2]
			)
			
			
			
			viewport.activeviewport = arr[startInx + 2]
			
			if isMaxed then max tool maximize
		)
	)

	fn savetoscene pName=
	(
		sceneObj = getnodebyname sceneObjName
		if (isvalidnode sceneObj) then
		(

			dataArr = getViewportSizeArr "scene" pName
			getViewportSizeInfo dataArr
			
			q = 300
			
			for q in 300 to 400 do
			(
				d =  (getappdata sceneObj q )
				
				if d != undefined and d != "" then
				(
					dataArr2 = execute d
					if dataArr2[2] == dataArr[2] then
					(
						g = querybox ("Scene preset named: " + pName + " already found! Overwrite?")
						
						if g then
						(
							
							for h in 1 to layoutfiles.count do
							(
							
								if (layouttype[h] == "scene" and layoutfiles[h] == pName) then
								(
									
									setappdata sceneObj q (dataArr as string)

									layoutData[h] = dataArr
									isBeingUpdated[h] = false
									updateListItems()
									layoutDList.selection = h
									updateLayoutDListSelection()
								)
							)
							return false
						)else
						(
							return false
						)
						
						
					)
				)else
				(
					setappdata sceneObj q (dataArr as string)
					
					append layoutFiles dataArr[2]
					append layoutData dataArr
					append layoutType dataArr[1]
					append isBeingUpdated false
					updateListItems()
					layoutDList.selection = layoutDList.items.count
					updateLayoutDListSelection()
					return false
				)
			)
			
			
			
		)
		
	)
	
	fn deleteScenePreset =
	(
		
		a = querybox "Delete selected preset?"
		
		if a then
		(
			if layoutDlist.selection > 0 then
			(
				if activeFile == layoutFiles[layoutDList.selection] then 
				(
					activeFile = undefined
					activeType = undefined
					
				)
				
				gc light:true
				
				sceneObj = getnodebyname sceneObjName
				
				if (isvalidnode sceneObj) then
				(
					for q in 300 to 400 do
					(
					
						d = getappdata sceneObj q
						
						if d != undefined and d != "" then
						(
							dataArr = execute d
							
							if dataArr[1] == layouttype[layoutDlist.selection] and dataarr[2] == layoutfiles[layoutDlist.selection] then
							(
								oldSel = layoutDList.selection
								
								setappdata sceneObj q ""
								deleteItem layoutFiles layoutDlist.selection
								deleteItem layoutData layoutDlist.selection
								deleteItem isBeingUpdated layoutDlist.selection
								deleteitem layouttype layoutDlist.selection
								
								
																
								updateListItems()
								
								layoutDList.selection = aMax#(1, oldSel - 1)
								
								updatelayoutdlistselection()
								
								return false
							)
							
						)
					)
				)
			
			)
		)
	)
	
	fn deleteLocalPreset =
	(
		a = querybox "Delete selected preset?"
		
		if a then
		(
			if layoutDlist.selection > 0 then
			(
				if activeFile == layoutFiles[layoutDList.selection] then 
				(
					activeFile = undefined
					activeType = undefined
					
				)
				
				gc light:true
				
				deletefile layoutFiles[layoutDList.selection]
				
				oldSel = layoutDlist.selection
				
				deleteItem layoutFiles layoutDlist.selection
				deleteItem layoutData layoutDlist.selection
				deleteItem isBeingUpdated layoutDlist.selection
				deleteitem layouttype layoutDlist.selection
				
				layoutDList.selection = aMax#(1, oldSel - 1)
				
				updateListItems()
				
				updatelayoutdlistselection()
				
			
			)
		)
	)
	
	fn saveNewLayout pname=
	(
		
		presetfilePath = localDir + pname + ".mlp"
		
		g = true
		if doesfileexist presetfilepath then
		(
			g = querybox ("Local preset named: " + pName + " already found! Overwrite?")
		)else
		(
			newFile = createfile presetfilepath
			close newFile
		)
		
		if g then
		(
		
			presetfile = fopen presetFilePath "wb"
			if presetfile != undefined then
			(
				dataArr = getViewportSizeArr "local" ""
				getViewportSizeInfo dataArr
				writestring presetFile (dataArr as string)
				fclose presetFile
				
				farr = getFiles (localDir + "*.mlp")
		
				for q in 1 to farr.count do
				(
					loadfromfile filename:farr[q]
				)
			)
			
			fclose presetFile
		)
		updateListItems()
		
		layoutDList.selection = sceneStart - 1
		
		updateLayoutDListSelection()
		
	)
	
	fn saveLocal =
	(
		saveType = "local"
		try(destroydialog lp_presetName)catch()
			
		if layoutDList.selected != localSep and layoutDList.selected != sceneSep and layoutDList.selection > 0 then
		(
			nameText = layoutDList.selected
		)else
		(
			nameText = ""
		)
		lp_presetName_text = "Choose local preset name"
		createdialog lp_presetName 230 30 modal:True
	)
	
	fn saveScene =
	(
		saveType = "scene"
		
		try(destroydialog lp_presetName)catch()
			
		if layoutDList.selected != localSep and layoutDList.selected != sceneSep and layoutDList.selection > 0 then
		(
			nameText = layoutDList.selected
		)else
		(
			nameText = ""
		)
		lp_presetName_text = "Choose scene preset name"
		createdialog lp_presetName 230 30 modal:True
	)
	
	
	
)

AddSubRollout MakeToolbox.theSubrollout layoutPresetsModule


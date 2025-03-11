/*
#NAME:Channel Box
#VERSION:1.0
#INSTRUCTIONS:
Comprehensive channel box similar to the one 
found in Maya
#SOURCE:Tyson Ibele, tyson@tysonibele.com
*/

enableAccelerators=false

global nodeCallback = undefined
global transformBox = undefined
global channelBox
global channelBoxRC
global channelBoxVer = "0.05"

gc light:true

try(destroydialog channelBox)catch()

rcMenu channelBoxPropRC 
(	
	menuItem setSelected "Set Selected"
	seperator sep1
	menuItem keySelected "Key Selected"
	menuItem unkeySelected "UnKey Selected"
	menuItem deleteKeysSelected "Clear all Keys in Selected"
	seperator sep3
	menuItem wireSelected "Wire Selected..."

	on wireSelected picked do
	(
		for q in 1 to channelBox.activeRollout.selectionList.count do
		(
			if (channelBox.activeRollout.selectionList[q]) then
			(				
				paramWire.editParam  channelBox.activeRollout.controllerList[q]
			)
		)
		
	)
	
	on setSelected picked do
	(
		for q in 1 to channelBox.activeRollout.selectionList.count do
		(
			if (channelBox.activeRollout.selectionList[q]) then
			(
				channelBox.activeRollout.changeProperties channelBox.activeRollout.controlList[q] undefined
			)
		)		
	)
	
	on keySelected picked do
	(
		for q in 1 to channelBox.activeRollout.selectionList.count do
		(
			if (channelBox.activeRollout.selectionList[q]) then
			(
				channelBox.activeRollout.setKeys q 0
			)
		)	
	)
	
	on unKeySelected picked do
	(
		for q in 1 to channelBox.activeRollout.selectionList.count do
		(
			if (channelBox.activeRollout.selectionList[q]) then
			(
				channelBox.activeRollout.setKeys q 1
			)
		)	
	)
	
	on deleteKeysSelected picked do
	(
		for q in 1 to channelBox.activeRollout.selectionList.count do
		(
			if (channelBox.activeRollout.selectionList[q]) then
			(
				channelBox.activeRollout.setKeys q 2
			)
		)	
	)
		
)

rcMenu channelBoxRC 
(	
	menuItem setSelected "Set Selected"
	seperator sep1
	menuItem keySelected "Key Selected"
	menuItem unkeySelected "UnKey Selected"
	menuItem deleteKeysSelected "Clear all Keys in Selected"
	seperator sep2
	menuItem lockSelected "Lock Selected"
	menuItem unlockSelected "Unlock Selected"
	seperator sep3
	menuItem wireSelected "Wire Selected..."
	
	on wireSelected picked do
	(
		for q in 1 to transformBox.selectionlist.count do
		(
			if (transformBox.selectionList[q]) then
			(
				paramWire.editParam transformBox.subanimList[q]
			)
		)
		
	)
	
	on lockSelected picked do
	(
		for q in 1 to transformBox.selectionlist.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.lockTransforms transformBox.controlList[q] true
			)
		)
		
	)
	
	on unlockSelected picked do
	(
		for q in 1 to transformBox.selectionlist.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.lockTransforms transformBox.controlList[q] false
			)
		)
		
	)
	
	
	on setSelected picked do
	(
		for q in 1 to transformBox.selectionList.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.changeTransforms transformBox.controlList[q] undefined
			)
		)
		
	)
	
	on keySelected picked do
	(
		for q in 1 to transformBox.selectionList.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.setKeys transformBox.controlList[q] 0
			)
		)
		
	)
	
	on unKeySelected picked do
	(
		for q in 1 to transformBox.selectionList.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.setKeys transformBox.controlList[q] 1
			)
		)
	)
	
	on deleteKeysSelected picked do
	(
		for q in 1 to transformBox.selectionList.count do
		(
			if (transformBox.selectionList[q]) then
			(
				transformBox.setKeys transformBox.controlList[q] 2
			)
		)
	)	
)

function generateParameterRolls obj =
(
	subs = obj.baseobject
	subList = #()
	rollList = #()


	control_list = #()
	label_list = #()
	decimal_list = #()
	
	for q in 1 to obj.modifiers.count do
	(
		append subList obj.modifiers[q]
	)

	append subList subs


	
	for q in 1 to subList.count do
	(
		labelOffset = 0
		roll_name = "subRoll" + (q as string)
		--execute ("global " + roll_name)
		roll_title = (subList[q] as string)
		try(roll_title = subList[q].name)catch()
		roll_header = "rollout " + roll_name + " \"" + roll_title + "\"\n("
		
		roll_locals = "\nlocal lastMousePos"
		roll_locals += "\nlocal needsUpdate = false"
		roll_locals += "\nlocal controlList = #()"
		roll_locals += "\nlocal subClass = undefined"
		roll_locals += "\nlocal controllerList = #()"
		roll_locals += "\nlocal controllerListNames = #()"
		roll_locals += "\nlocal obj = undefined"
		roll_locals += "\nlocal labelList = #()"
		roll_locals += "\nlocal lastSelection = 0"
		roll_locals += "\nlocal selectionList = #()"
		roll_locals += "\n local subList = #()"
		roll_locals += "\nlocal currentSpinner = undefined"
		roll_locals += "\nlocal changeOnClick = false"
		roll_locals += "\nlocal labelUnselectedColor = (channelBox.dotnetcolor 220 220 220)"
		roll_locals += "\nlocal labelSelectedColor = (channelBox.dotnetcolor 120 200 250)"
		roll_locals += "\nlocal spinnerKeysColor = (channelBox.dotnetcolor 250 180 180)"
		roll_locals += "\nlocal spinnerNoKeysColor = (channelBox.dotnetcolor 255 255 255)"
		roll_locals += "\nlocal thisRoll = " + (roll_name)
		roll_locals += "\nlocal mDown = false "
		roll_functions = ""
				
		roll_functions += "\nfunction setKeyColor sender cont reset:false ="
		roll_functions += "\n("
		roll_functions += "\nif (reset) then"
		roll_functions += "\n("
		roll_functions += "\n	sender.backColor = spinnerNoKeysColor"
		roll_functions += "\n	return false"
		roll_functions += "\n)"
		roll_functions += "\nif cont.keys.count > 0 then"
		roll_functions += "\n("
		roll_functions += "\n	sender.backColor = spinnerKeysColor"
		roll_functions += "\n)else"
		roll_functions += "\n("
		roll_functions += "\n	sender.backColor =  spinnerNoKeysColor"
		roll_functions += "\n)"
		roll_functions += "\n)"
	
		roll_functions += "\nfunction returnValue dnControl type="
		roll_functions += "\n("
		roll_functions += "\nreturn ((dotNetClass \"System.Decimal\").ToSingle (getProperty dnControl type asDotNetObject:true))"
		roll_functions += "\n)"


		roll_functions += "\nfunction checkController sub ="
		roll_functions += "\n("
		roll_functions += "\n	if sub.controller == undefined then sub.controller = bezier_float()"
		roll_functions += "\n)"
		
		
		roll_functions += "\nfunction updateProperties needsUp:false="
		roll_functions += "\n("
		roll_functions += "\nneedsUpdate = needsUp"
		roll_functions += "\nfor q in 1 to controlList.count do"
		roll_functions += "\n("
		roll_functions += "\ntry("
		roll_functions += "\ncheckController controllerList[q]"
		roll_functions += "\nsetKeyColor controlList[q] controllerList[q];"
		roll_functions += "\ncontrolList[q].value = controllerList[q].value"
		roll_functions += "\n)catch(print (\"Error auto-updating properties: \" + GetCurrentException()))"
		roll_functions += "\n)"
		roll_functions += "\nneedsUpdate = true"
		roll_functions += "\n)"		
		
		roll_functions += "
		
		function changeProperties sender arg multiEdit:true val:undefined  =
		(
			if (not needsUpdate) then return false
			try
			(
			subInx = -1
				for q in 1 to controlList.count do
				(
					if sender == controlList[q] then
					(
						subInx = q
					)
				)				
				obj = channelBox.nodeList[1]
				
				if val == undefined then val = (returnValue sender #value)
				
				if val > sender.Maximum then val = sender.maximum
				if val < sender.Minimum then val = sender.minimum
			
				for q in channelBox.nodeList.count to 1 by -1 do
			(
					
					if (channelBox.relative) then
					(
						if q == 1 then
						(
							controllerList[subInx].value += (val - controllerList[subInx].value)
						)else
						(
							objModList = #()
							for h in 1 to channelBox.nodeList[q].modifiers.count do
							(
								append objModList channelBox.nodeList[q].modifiers[h]
						)
						append objModList channelBox.nodeList[q].baseObject						
							for x in 1 to objModList.count do
							(
								if subClass == classof objModList[x] then
								(
									for j in 1 to (getsubanimnames objModList[x]).count do
									(
										if (getsubanimname objModList[x] j == controllerListNames[subInx]) then
										(
											objModList[x][j].value += (val - controllerList[subInx].value)
										)
									)
								)
							)
						)				
					)else
					(
						if q == 1 then
						(
							controllerList[subInx].value = (val )
						)else
						(
							objModList = #()
							for h in 1 to channelBox.nodeList[q].modifiers.count do
							(
								append objModList channelBox.nodeList[q].modifiers[h]
						)
							append objModList channelBox.nodeList[q].baseObject							
							for x in 1 to objModList.count do
							(
							if subClass == classof objModList[x] then
								(
									for j in 1 to (getsubanimnames objModList[x]).count do
									(
									if (getsubanimname objModList[x] j == controllerListNames[subInx]) then
										(
											objModList[x][j].value = val 
										)
									)
								)
							)				
						)		
					)
				)
				if (multiEdit and channelBox.multiEdit) then					
				(
					mEControlList = #()
					for q in 1 to controlList.count do
					(
						if selectionList[q] then
						(
							append mEControlList controlList[q]
						)
						if controlList[q] == sender and not selectionList[q] then
						(
							mEControlList = #()
							exit
						)
					)
					for q in 1 to mEControlList.count do
					(
				
						changeProperties mEControlList[q] undefined multiEdit:false val:val
					)
					
				)
			redrawviews()
			)catch(print (\"Channel Box error: changing properties: \" + GetCurrentException()))
		)
		"
		
		roll_functions += "\nfunction setMouseDown sender arg ="
		roll_functions += "\n("
		roll_functions += "\ncase arg.button of"
		roll_functions += "\n("
		roll_functions += "\n(arg.button.left):"
		roll_functions += "\n("
		roll_functions += "\ncursor = dotnetclass \"System.Windows.Forms.Cursor\""
		roll_functions += "\n	p = cursor.Position"
		roll_functions += "\nlastMousePos=p.y"
		roll_functions += "\n)"
		roll_functions += "\n)"
		roll_functions += "\n)"
		
		roll_functions += "
		function setMouseMove sender arg =
		(
			case arg.button of
			(
				(arg.button.left):
				(
					cursor = dotnetclass \"System.Windows.Forms.Cursor\"
					p = cursor.Position
					mouseOffSetY=(lastMousePos-p.y)*.05
					val = (returnValue sender #value) 
					val += mouseOffsetY
					if (val < sender.minimum) then val = sender.minimum
					if (val > sender.maximum) then val = sender.maximum
					sender.value = val
					lastMousePos = p.y
					yVal = p.y
					if (p.y < 1) then
					(
						lastMousePos = (sysinfo.desktopsize[2] - 2)
						yVal = lastMousePos
						cursor.Position = dotnetobject \"System.Drawing.Point\" p.x (sysinfo.desktopsize[2] - 2)
					)else if (p.y > sysInfo.desktopSize[2] - 2) then
					(
						lastMousePos = 1
						yVal = lastMousePos
						cursor.Position = dotnetobject \"System.Drawing.Point\" p.x 1
					)
					; changeProperties sender arg
				)
			)
		)
		"

		roll_functions += "\nfunction selectSpinner sender arg="
		roll_functions += "\n("
		roll_functions += "\nsender.select 0 sender.text.count"
		roll_functions += "\n)"
		
		roll_functions += "
		function checkKey sender arg =
		(
			inx = 0
			for q in 1 to controlList.count do
			(
				if controlList[q] == sender then
				(
					inx = q
				)
			)
			if arg.KeyCode == (dotnetclass \"Keys\").enter then 
			(	
				theHold.Begin()
				sender.value = returnValue sender #value
				changeProperties sender arg
				theHold.Accept \"Channel Box\"
			)else if arg.KeyCode == (dotnetclass \"Keys\").tab then
			(	
				theHold.Begin()
				sender.value = returnValue sender #value
				if (inx + 1) > controlList.count then inx = 0
				controlList[inx + 1].focus()
				changeProperties sender arg
				theHold.Accept \"Channel Box\"
			)
		)
		"
		
		roll_functions += "\nfunction setControlColor val ctrl="
		roll_functions += "\n("
		roll_functions += "\nif val then"
		roll_functions += "\n("
		roll_functions += "\nctrl.backColor = labelSelectedColor "
		roll_functions += "\n)else "
		roll_functions += "\n("
		roll_functions += "\nctrl.backColor = labelUnselectedColor"
		roll_functions += "\n)"
		roll_functions += "\n)"		
		
		roll_functions += "
		function updateSelections arg inx = 
		(		
			if ((not keyboard.controlpressed and not keyboard.shiftPressed) or inx == 0) then
			(
				lastSelection = 0
				for j in 1 to labelList.count do (selectionList[j] = false)
			)	
			if (inx > 0) then
			(
				if (keyboard.shiftpressed) then
				(
					for j in 1 to labelList.count do (selectionList[j] = false)
					if lastSelection > 0 then
					(
						for q in amin #(lastSelection, inx) to amax #(lastSelection, inx) do
						(
							selectionlist[q] = true						
						)
					)else
					(
						selectionList[inx] = not selectionList[inx]
						lastSelection = inx
					)
					
				)else
				(
					selectionList[inx] = not selectionList[inx]
					lastSelection = inx
				)
			)
			for q in 1 to selectionList.count do
			(
				setControlColor selectionList[q] labelList[q]
			)
		)
		
		"
	
		
		
		roll_functions += "\nfunction rightClickMenu ="
		roll_functions += "\n("
		roll_functions += "\ncursor = dotnetclass \"System.Windows.Forms.Cursor\""
		roll_functions += "\np = cursor.Position"
		roll_functions += "\nchannelBox.activeRollout = thisRoll"		
		roll_functions += "\npopupmenu channelBoxPropRC pos:[p.x, p.y]"
		roll_functions += "\n)"
		
		roll_functions += "\nfunction keyIndex controller keyTime ="
		roll_functions += "\n("
		roll_functions += "\n	for q in 1 to controller.keys.count do"
		roll_functions += "\n	("
		roll_functions += "\n		if controller.keys[q].time == keyTime then"
		roll_functions += "\n		("
		roll_functions += "\n			return q"
		roll_functions += "\n		)"
		roll_functions += "\n	)"
		roll_functions += "\n	return -1"
		roll_functions += "\n)"
		

	
		roll_functions += "\nfunction setKeys controllerInx state="
		roll_functions += "\n("
		roll_functions += "\n	try"
		roll_functions += "\n	(			"	
		roll_functions += "\n		for q in channelBox.nodeList.count to 1 by -1 do"
		roll_functions += "\n		("
		roll_functions += "\n		obj = channelBox.nodeList[q]					"
		roll_functions += "\n			if (q == 1) then"
		roll_functions += "\n			("
		roll_functions += "\n				if state == 0 then"
		roll_functions += "\n				("
		roll_functions += "\n					addnewkey controllerList[controllerInx].controller slidertime"
		roll_functions += "\n				)else if state == 1 then"
		roll_functions += "\n				("
		roll_functions += "\n					(inx = (keyIndex controllerList[controllerInx].controller slidertime); if inx > 0 then (deletekey controllerList[controllerInx].controller inx))"
		roll_functions += "\n				)else if state == 2 then"
		roll_functions += "\n				("
		roll_functions += "\n					 deletekeys controllerList[controllerInx].controller #allkeys"
		roll_functions += "\n				)"
		roll_functions += "\n			)"
		roll_functions += "\n			else"
		roll_functions += "\n			("
		roll_functions += "\n				objModList = #()"
		roll_functions += "\n				for h in 1 to channelBox.nodeList[q].modifiers.count do"
		roll_functions += "\n				("
		roll_functions += "\n					append objModList channelBox.nodeList[q].modifiers[h]"
		roll_functions += "\n				)						"
		roll_functions += "\n				append objModList channelBox.nodeList[q].baseObject		"										
		roll_functions += "\n				for x in 1 to objModList.count do"
		roll_functions += "\n				("
		roll_functions += "\n					if subClass == classof objModList[x] then"
		roll_functions += "\n					("
		roll_functions += "\n						for j in 1 to (getsubanimnames objModList[x]).count do"
		roll_functions += "\n						("
		roll_functions += "\n							if (getsubanimname objModList[x] j == controllerListNames[controllerInx]) then"
		roll_functions += "\n							("
		roll_functions += "\n								if state == 0 then"
		roll_functions += "\n								("
		roll_functions += "\n									addnewkey objModList[x][j].controller slidertime"
		roll_functions += "\n								)else if state == 1 then"
		roll_functions += "\n								("
		roll_functions += "\n									(inx = (keyIndex objModList[x][j].controller slidertime); if inx > 0 then (deletekey objModList[x][j].controller inx))"
		roll_functions += "\n								)else if state == 2 then"
		roll_functions += "\n								("
		roll_functions += "\n									deletekeys objModList[x][j].controller #allkeys"
		roll_functions += "\n								)"
		roll_functions += "\n							)"
		roll_functions += "\n						)"
		roll_functions += "\n					)"
		roll_functions += "\n				)			"
		roll_functions += "\n			)						"
		roll_functions += "\n		)"
		roll_functions += "\n	)catch(print \"Error setting key(s)\"; print (getcurrentexception()))"
		roll_functions += "\n)"
		
	
		roll_footer = "\n)"
		
		roll_content = ""
		roll_clauses = ""
		controlCount = 0
		
		propList = #()
		propSubList = #()
		propNames = getsubanimnames subList[q]
		
		for g in 1 to propNames.count do
		(
			if (ispropertyanimatable subList[q] propNames[g]) then
			(
				append propList propNames[g]
				append propSubList subList[q][g]
			)
		)
		
		append control_list #()
		append label_list #()
		append decimal_list #()
		
		roll_open_clause = "\non " + roll_name + " open do("
		roll_open_clause += "\nsubClass = " + ((classof subList[q]) as string)
		
		for g in 1 to propList.count do
		(
			if (classof propSubList[g].value  == integer) then
			(
				decimalPlaces = 0

			)else if (classof propSubList[g].value  == float) then
			(
				decimalPlaces = 3
		
			)
			
			
			if (decimalPlaces != undefined) then
			(
				label_name = roll_name + "_label" + (controlCount as string) 
				control_name = roll_name + "_spinner" + (controlCount as string) 
				controlCount += 1
				roll_content += "\ndotnetcontrol " + label_name + " \"System.Windows.Forms.Label\" text:\""+ propSubList[g].name + "\" width:110 align:#right offset:[-80," + (labelOffset as string) + "] height:19"
				roll_content += "\ndotnetcontrol " + control_name + " \"System.Windows.Forms.NumericUpDown\" width:90 align:#right offset:[10,-25]"
				labelOffset = 2
				
				roll_clauses += "\non " + label_name + " MouseDown arg do (if (arg.button == (dotnetclass \"MouseButtons\").Left) then updateSelections arg " + (controlCount as string) + " else rightClickMenu())"
				
				roll_clauses += "\non " + control_name + " mousedown sender arg do (theHold.Begin(); currentSpinner = sender; setMouseDown sender arg; changeOnClick = false)"
				roll_clauses += "\non " + control_name + " mouseup sender arg do (if not changeOnClick then (changeProperties sender arg; theHold.Accept \"Channel Box\"); currentSpinner = undefined)"
				roll_clauses += "\non " + control_name + " mousemove sender arg do (if currentSpinner != sender then return false; setMouseMove sender arg)"
				
				--roll_clauses += "\non " + control_name + " valuechanged sender arg do ( theHold.Begin(); changeProperties sender arg; theHold.Accept \"Channel Box\")"		
				roll_clauses += "\non " + control_name + " click sender arg do (changeProperties sender arg; theHold.Accept \"Channel Box\"; changeOnClick = true)"
				roll_clauses += "\non " + control_name + " keyup sender arg do (checkKey sender arg)"
				roll_clauses += "\non " + control_name + " gotfocus sender arg do (selectSpinner sender arg)"
				
				roll_open_clause += "\nappend controlList " + control_name
				roll_open_clause += "\nobj = $'" + obj.name + "'" -------------name problem?
				
				
				if (q < subList.count) then
				(
					roll_open_clause += "\nappend controllerList $'" + (obj.name) + "'.modifiers[" + (q as string) + "][" + (g as string) + "]" 
					roll_open_clause += "\nappend controllerListNames (getsubanimname $'" + (obj.name) + "'.modifiers[" + (q as string) + "] " + (g as string) + ")" 
				)else
				(
					
					roll_open_clause += "\nappend controllerList $'" + (obj.name) + "'.baseObject[" + (g as string) + "]"
					roll_open_clause += "\nappend controllerListNames (getsubanimname $'" + (obj.name) + "'.baseObject " + (g as string) + ")"
				)
				
				roll_open_clause += "\nappend labelList " + label_name
				append control_list[control_list.count] (roll_name + "." + control_name)
				append label_list[label_list.count] label_name
				append decimal_list[decimal_list.count] decimalPlaces			
			)
		)
	
		roll_open_clause += "\nupdateSelections undefined 0)"
		
		labelOffset = 5
		
		roll_string = roll_header + roll_locals + roll_functions + roll_content + roll_clauses + roll_open_clause + roll_footer
		
		execute roll_string
		
		append rollList (execute roll_name)

	)

	for q in 1 to rollList.count do
	(		
		addsubrollout channelBox.nodePropSubrollout rollList[q] rolledUp:(true)
	)

	for q in 1 to control_list.count do
	(
		for g in 1 to control_list[q].count do
		(
			execute (control_list[q][g] + ".decimalPlaces = " + (decimal_list[q][g] as string))
			if (decimal_list[q][g] > 0) then
			(
				execute (control_list[q][g] + ".increment = .05")
			)else
			(
				execute (control_list[q][g] + ".increment = 1")
			)
			execute (control_list[q][g] + ".minimum = -10000000")
			execute (control_list[q][g] + ".maximum = 10000000")
			control_list[q][g] = execute control_list[q][g]
		)
	)

)

rollout channelBox ("Channel Box v" + channelBoxVer)
(
	local lastObj = undefined
	local lastModCount = 0
	local nodeList = #()
	local relative = false
	local multiEdit = true
	local activeRollout = undefined
	
	edittext nodeName "" text:" [No Objects Selected]" align:#left enabled:false width:220
	button nodeDropdown ">" width:15 height:15 align:#left offset:[210,-21] visible:false
	
	dotNetControl relativeLabel "System.Windows.Forms.Label" text:"Relative" width:88 align:#right offset:[-20,2] height:19
	dotNetControl multipleEditLabel "System.Windows.Forms.Label" text:"Multiple Edits" width:88 align:#right offset:[-110,-24] height:19 visible:false
	
	subrollout nodePropSubrollout height:650
	
	timer timer1 interval:30 active:true
	
	on multipleEditLabel MouseDown arg do transformBox.setControlColor (channelBox.multiEdit = not channelBox.multiEdit) multipleEditLabel green:true
	on relativeLabel MouseDown arg do transformBox.setControlColor (channelBox.relative = not channelBox.relative) relativeLabel green:true
	
		on timer1 tick do
		(
			thisRoll = channelBox
			for q in 1 to thisRoll.controls.count do
			(
				if classof thisRoll.controls[q] == subrollout then
				(
					for g in 1 to thisRoll.controls[q].rollouts.count do
					(
						subRoll = thisRoll.controls[q].rollouts[g]
						
						for x in 1 to subRoll.controls.count do
						(
							subRoll.controls[x].refresh()
						)
					)
				)
			)
		)
		
		on channelBox resized p do
		(
			channelBox.width = 250
			nodePropSubrollout.height = channelBox.height - 60
		)
		
	function dotnetcolor r g b = 
	(
		(dotNetClass "System.Drawing.Color").fromARGB r g b
	)
	
	function updateNodeSelection ev nd = 
	(
	
		if ev != #callbackend then return false
				
		if (channelBox.open) then
		(	
			nodeName.width = 220
			nodeDropdown.visible = false
			if selection.count > 0 then
			(
				
				nodeList = #()
				for q in 1 to selection.count do
				(
					nodeList[q] = selection[q]
				)
				
				updateSubs = false
				
				if (lastObj == nodeList[1]) then
				(
					if lastModCount != nodeList[1].modifiers.count then
					(
						updateSubs = true
					)
					
				)else
				(
					updateSubs = true
				)
				
				lastObj = nodeList[1]
				lastModCount = nodeList[1].modifiers.count
				
				nodeName.enabled = true
				if nodeName.text != nodelist[1].name then nodeName.text = nodelist[1].name
				
				if nodeList.count > 1 then
				(
					nodeName.enabled = false
					nodeName.text = " " + nodeName.text + " . . . "
				)

				if (updateSubs) then
				(
					nodePropSubrollout.visible = false
					while (nodePropSubrollout.rollouts.count > 0) do
					(
						removeSubrollout nodePropSubrollout nodePropSubrollout.rollouts[1]
					)
			
					addSubrollout nodePropSubrollout transformBox
					generateParameterRolls(nodeList[1])
					nodePropSubrollout.visible = true
				)
				
				transformBox.updateTransforms()
				
				for q in 2 to nodePropSubrollout.rollouts.count do
				(
					nodePropSubrollout.rollouts[q].updateProperties()					
				)
				
			)else
			(	
				lastObj = undefined
				lastModCount = -1
				nodeList = #()
				nodeName.enabled = false
				nodeName.text = " [No Objects Selected]"
				nodePropSubrollout.visible = false
				while (nodePropSubrollout.rollouts.count > 0) do
				(
					removeSubrollout nodePropSubrollout nodePropSubrollout.rollouts[1]
				)
			
				nodePropSubrollout.visible = true
			)
			
		)
		
	)
	
	on channelBox open do
	(
		updateNodeSelection #callbackend undefined
		transformBox.setControlColor (channelBox.relative = not channelBox.relative) relativeLabel green:true
		transformBox.setControlColor (channelBox.relative = not channelBox.relative) multipleEditLabel green:true
		relative = true
	
	)
	
	function updateNodeTransform ev nd =
	(
		transformBox.updateTransforms 
		
	)
	
	on nodeName changed val do
	(
		theHold.begin()
		(
			for q in 1 to nodeList.count do
			(
			
				nodeList[q].name = val
			)
		)
		theHold.accept "Channel Box"
	)
	
)

rollout transformBox "Transforms"
(
	local needsUpdate
	local updateTransforms
	local returnvalue
	local lastSelection
	local selectionList = #()
	local lockList = #(false, false, false, false, false, false, false, false, false )
	local labelUnselectedColor = (channelBox.dotnetcolor 220 220 220)
	local labelSelectedColor = (channelBox.dotnetcolor 120 200 250)
	local labelSelectedColor2 = (channelBox.dotnetcolor 120 230 140)
	
	local spinnerKeysColor = (channelBox.dotnetcolor 250 180 180)
	local spinnerNoKeysColor = (channelBox.dotnetcolor 255 255 255)
	
	local lockedColor = (channelBox.dotnetcolor 60 60 60)
	
	local lastMousePos = 0
	local currentSpinner = undefined
	local holdReady = false
	local mDown = false
	local changeOnClick = false
	
	local controlList = #()
	local controllerList = #()
	local subanimList = #()
		
	dotNetControl translateXLabel "System.Windows.Forms.Label" text:"Translate X " width:100 align:#right offset:[-90,0] height:19
	dotNetControl translateX "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl translateYLabel "System.Windows.Forms.Label" text:"Translate Y " width:100 align:#right offset:[-90,2] height:19
	dotNetControl translateY "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl translateZLabel "System.Windows.Forms.Label" text:"Translate Z " width:100 align:#right offset:[-90,2] height:19
	dotNetControl translateZ "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]

	dotNetControl rotateXLabel "System.Windows.Forms.Label" text:"Rotate X " width:100 align:#right offset:[-90, 5]  height:19
	dotNetControl rotateX "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl rotateYLabel "System.Windows.Forms.Label" text:"Rotate Y " width:100 align:#right offset:[-90, 2]  height:19
	dotNetControl rotateY "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl rotateZLabel "System.Windows.Forms.Label" text:"Rotate Z " width:100 align:#right offset:[-90, 2]  height:19
	dotNetControl rotateZ "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	
	dotNetControl scaleXLabel "System.Windows.Forms.Label" text:"Scale X " width:100 align:#right offset:[-90, 5]  height:19
	dotNetControl scaleX "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl scaleYLabel "System.Windows.Forms.Label" text:"Scale Y " width:100 align:#right offset:[-90, 2]  height:19
	dotNetControl scaleY "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	dotNetControl scaleZLabel "System.Windows.Forms.Label" text:"Scale Z " width:100 align:#right offset:[-90, 2]  height:19
	dotNetControl scaleZ "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]
	
	dotNetControl visibilityLabel "System.Windows.Forms.Label" text:"Visibility X " width:100 align:#right offset:[-90, 5]  height:19
	dotNetControl visibility "System.Windows.Forms.NumericUpDown" width:90 align:#right offset:[0,-25]

	
	function keyIndex controller keyTime =
	(
		for q in 1 to controller.keys.count do
		(
			if controller.keys[q].time == keyTime then
			(
				return q
			)
		)
		return -1
	)
	
	
	
	function getControllerVal obj trans axis returnString:false controller:false subanim:false=
	(
		str = undefined
		
		if axis == "x" then aInx = 1
		if axis == "y" then aInx = 2
		if axis == "z" then aInx = 3
		
		if trans == "position" then
		(
			
			if iskindof obj.position.controller position_xyz then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'." + trans + ".controller[" + aInx as string + "]"
				)else
				(
					str = "$'" + obj.name + "'." + trans + ".controller" + "." + axis + "_" + trans; if controller then str += ".controller"
				)
			)else if iskindof obj.position.controller tcb_position then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'[3][1]"
				)else
				(
					str = "$'" + obj.name + "'." + trans; if not controller then str += "." + axis else str += ".controller"
				)
			)else if iskindof obj.position.controller position_list then
			(
				if subanim then
				(
					if (iskindof obj.position.controller[obj.position.controller.active].controller position_xyz) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller[" + aInx as string + "]" 
					)else if (iskindof obj.position.controller[obj.position.controller.active].controller tcb_position) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]"
					)
				)else
				(
					if (iskindof obj.position.controller[obj.position.controller.active].controller position_xyz) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller" + "." + axis + "_" + trans; if controller then str += ".controller"
					)else if (iskindof obj.position.controller[obj.position.controller.active].controller tcb_position) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]." + trans; if not controller then str += "." + axis else str += ".controller"
					)
				)
			)
			
		)
		
		if trans == "rotation" then
		(
			if iskindof obj.rotation.controller euler_xyz then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'." + trans + ".controller[" + aInx as string + "]" 
				)else
				(
					str = "$'" + obj.name + "'." + trans + ".controller" + "." + axis + "_" + trans; if controller then str += ".controller"
				)
			)else if iskindof obj.rotation.controller rotation_list then
			(
				if subanim then
				(
					if (iskindof obj.rotation.controller[obj.rotation.controller.active].controller euler_xyz) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller[" + aInx as string + "]"
					)	
				)else
				(
					if (iskindof obj.rotation.controller[obj.rotation.controller.active].controller euler_xyz) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller" + "." + axis + "_" + trans; if controller then str += ".controller"
					)	
				)				
			)
			
		)
		
		if trans == "scale" then
		(
			if iskindof obj.scale.controller scalexyz then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'." + trans + ".controller[" + aInx as string + "]"
				)else
				(
					str = "$'" + obj.name + "'." + trans + ".controller" + "." + axis + "_" + trans; if controller then str += ".controller"
				)
			)else if iskindof obj.scale.controller tcb_scale then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'[3][3]"
				)else
				(
					str = "$'" + obj.name + "'." + trans; if not controller then str += "." + axis else str += ".controller"
				)
			)else if iskindof obj.scale.controller bezier_scale then
			(
				if subanim then
				(
					str = "$'" + obj.name + "'[3][3]"
						
				)else
				(
					str = "$'" + obj.name + "'." + trans; if not controller then str += "." + axis else str += ".controller"
				)
			)else if iskindof obj.scale.controller scale_list then
			(
				if subanim then
				(
					if (iskindof obj.scale.controller[obj.scale.controller.active].controller scalexyz) then
					(
					
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller[" + aInx as string + "]"
					)else if (iskindof obj.scale.controller[obj.scale.controller.active].controller tcb_scale) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]"
						
					)else if (iskindof obj.scale.controller[obj.scale.controller.active].controller bezier_scale) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]"
					)	

				)else
				(
					if (iskindof obj.scale.controller[obj.scale.controller.active].controller scalexyz) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active].controller" + "." + axis + "_" + trans; if controller then str += ".controller"
					)else if (iskindof obj.scale.controller[obj.scale.controller.active].controller tcb_scale) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]." + trans; if not controller then str += "." + axis else str += ".controller"
					)else if (iskindof obj.scale.controller[obj.scale.controller.active].controller bezier_scale) then
					(
						str = "$'" + obj.name + "'." + trans + ".controller[$'" + obj.name + "'." + trans + ".controller.active]." + trans; if not controller then str += "." + axis else str += ".controller"
					)	
				)				
			)
			
		)
		

		
		if (str != undefined) then
		(
			if returnString then
			(
				return str
			)else
			(
				return (execute str)
			)
		)else
		(
			return undefined
		)
		
	)
	
	function checkLocks obj =
	(
			
		for inx in 1 to 10 do
		(
			if subanimlist[inx] != undefined then
			(
				state = lockedTracksMan.getLocked subanimList[inx] subanimList[inx].parent subanimList[inx].index false
				
				if state then
				(
					lockList[inx] = true
				)else
				(
					lockList[inx] = false
				)			
			)else
			(
				lockList[inx] = false
			)
		)
		
				
	)
	
	function getControllerInx controller parentController = 
	(
		controllerArr = getsubanim
	)
	
	function lockTransforms sender state=
	(
		for q in  channelBox.nodeList.count to 1 by -1 do
		(
			obj = channelBox.nodeList[q]
			
			subanimList[1] = (getControllerVal obj "position" "x" subanim:true)
			subanimList[2] = (getControllerVal obj "position" "y" subanim:true)
			subanimList[3] = (getControllerVal obj "position" "z" subanim:true)
			
			subanimList[4] = (getControllerVal obj "rotation" "x" subanim:true)
			subanimList[5] = (getControllerVal obj "rotation" "y" subanim:true)
			subanimList[6] = (getControllerVal obj "rotation" "z" subanim:true)
			
			subanimList[7] = (getControllerVal obj "scale" "x" subanim:true)
			subanimList[8] = (getControllerVal obj "scale" "y" subanim:true)
			subanimList[9] = (getControllerVal obj "scale" "z" subanim:true)
			
			subanimList[10] = obj[1]
			

			for g in 1 to controlList.count do
			(
				if controlList[g] == sender then
				(	
					if subanimList[g] != undefined then
					(
						lockedTracksMan.setLocks state subanimList[g] subanimList[g].parent subanimList[g].index false				
					)
				)
			)

			if sender == visibility then
			(
				if subanimList[10] != undefined then
				(
					lockedTracksMan.setLocks state subanimList[10] subanimList[10].parent subanimList[10].index false		
				)
			)
		)
		
		updateTransforms()
		
	)
	
	function setKeys sender state=
	(
		try
		(
			
			for q in 1 to channelBox.nodeList.count do
			(
				obj = channelBox.nodeList[q]
				
				if sender == translateX then (cont =  (getcontrollerval obj "position" "x" controller:true))
				if sender == translateY then (cont =  (getcontrollerval obj "position" "y" controller:true))
				if sender == translateZ then (cont = (getcontrollerval obj "position" "z" controller:true))

				if sender == rotateX then (cont =  (getcontrollerval obj "rotation" "x" controller:true))
				if sender == rotateY then (cont = (getcontrollerval obj "rotation" "y" controller:true))
				if sender == rotateZ then (cont =  (getcontrollerval obj "rotation" "z" controller:true))

				if sender == scaleX then (cont = (getcontrollerval obj "scale" "x" controller:true))
				if sender == scaleY then (cont = (getcontrollerval obj "scale" "y" controller:true))
				if sender == scaleZ then (cont =  (getcontrollerval obj "scale" "z" controller:true))
					
				if sender == visibility then (cont = obj.visibility.controller)
				
				if cont == undefined then continue
					
				if state == 0 then
				(
					addnewkey cont slidertime				
					
				)else if state == 1 then
				(
					inx = (keyIndex cont slidertime); if inx > 0 then (deletekey cont inx)
					
					
				)else if state == 2 then
				(
					deletekeys cont #allkeys
				)
			)
		)catch(print "Error setting key(s)"; print (getcurrentexception()))
	)
	
	function changeTransforms sender arg multiEdit:true val:undefined =
	(
		if (not needsUpdate) then return false
		
		newHold = false

		try ----------------------------------------------------------------------------------------------------------------------------------------------------ADAPT TO CONTROLLER DIFFERENCES
		(

			obj = channelBox.nodeList[1]
			
			if val == undefined then val = (returnValue sender #value)
				
			if val > sender.Maximum then val = sender.maximum
			if val < sender.Minimum then val = sender.minimum
					
			
			for q in channelBox.nodeList.count to 1 by -1 do
			(
				
				
				cont = undefined
				if (channelBox.relative) then
				(	
					if sender == translateX then (firstCont = getControllerVal channelBox.nodeList[1] "position" "x" returnString:true; cont = getControllerVal channelBox.nodeList[q] "position" "x" returnString:true; )
					if sender == translateY then (firstCont = getControllerVal channelBox.nodeList[1] "position" "y" returnString:true;cont = getControllerVal channelBox.nodeList[q] "position" "y" returnString:true;)
					if sender == translateZ then (firstCont = getControllerVal channelBox.nodeList[1] "position" "z" returnString:true;cont = getControllerVal channelBox.nodeList[q] "position" "z" returnString:true; )
					
					if sender == rotateX then (firstCont = getControllerVal channelBox.nodeList[1] "rotation" "x" returnString:true; cont = getControllerVal channelBox.nodeList[q] "rotation" "x" returnString:true;)
					if sender == rotateY then (firstCont = getControllerVal channelBox.nodeList[1] "rotation" "y" returnString:true; cont = getControllerVal channelBox.nodeList[q] "rotation" "y" returnString:true; )
					if sender == rotateZ then (firstCont = getControllerVal channelBox.nodeList[1] "rotation" "z" returnString:true; cont = getControllerVal channelBox.nodeList[q] "rotation" "z" returnString:true; )
										
					if sender == scaleX then (firstCont = getControllerVal channelBox.nodeList[1] "scale" "x" returnString:true; cont = getControllerVal channelBox.nodeList[q] "scale" "x" returnString:true;)
					if sender == scaleY then (firstCont = getControllerVal channelBox.nodeList[1] "scale" "y" returnString:true; cont = getControllerVal channelBox.nodeList[q] "scale" "y" returnString:true;)
					if sender == scaleZ then (firstCont = getControllerVal channelBox.nodeList[1] "scale" "z" returnString:true; cont = getControllerVal channelBox.nodeList[q] "scale" "z" returnString:true; )	

					if cont != undefined then (str = (cont + " += (" + (val as string) + " - " + firstCont + ")"); execute str)
						
				)else
				(
					
					if sender == translateX then (cont = getControllerVal channelBox.nodeList[q] "position" "x" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) + ")"); execute str))
					if sender == translateY then (cont = getControllerVal channelBox.nodeList[q] "position" "y" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) +  ")"); execute str))
					if sender == translateZ then (cont = getControllerVal channelBox.nodeList[q] "position" "z" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) + ")"); execute str))
					
					if sender == rotateX then (cont = getControllerVal channelBox.nodeList[q] "rotation" "x" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) +  ")"); execute str))
					if sender == rotateY then (cont = getControllerVal channelBox.nodeList[q] "rotation" "y" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) + ")"); execute str))
					if sender == rotateZ then (cont = getControllerVal channelBox.nodeList[q] "rotation" "z" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) +  ")"); execute str))
					
					if sender == scaleX then (cont = getControllerVal channelBox.nodeList[q] "scale" "x" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) +  ")"); execute str))
					if sender == scaleY then (cont = getControllerVal channelBox.nodeList[q] "scale" "y" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) +  ")"); execute str))
					if sender == scaleZ then (cont = getControllerVal channelBox.nodeList[q] "scale" "z" returnString:true; if cont != undefined then (str = (cont + " = (" + (val as string) + ")"); execute str))	
				)
				
				if sender == visibility then channelBox.nodeList[q].visibility.controller.value = val
					
			)
			
				if (multiEdit and channelBox.multiEdit) then					
				(
					
					mEControlList = #()
					for q in 1 to controlList.count do
					(
						if selectionList[q] then
						(
							append mEControlList controlList[q]
						)
						if controlList[q] == sender and not selectionList[q] then
						(
							mEControlList = #()
							exit
						)
					)
					for q in 1 to mEControlList.count do
					(
				
						changeTransforms mEControlList[q] undefined multiEdit:false val:val
					)
					
				)
				
		)catch(print ("Channel Box error: changing transforms: " + GetCurrentException()))

		--updateTransforms()
	)
	
	function setKeyColor sender cont reset:false =
	(
		for q in 1 to controlList.count do
		(
			if controlList[q] == sender then
			(
				if not lockList[q] then
				(
					sender.enabled = true
					if (reset) then
					(
						sender.backColor = spinnerNoKeysColor
						sender.enabled = false
						return false
					)
					if cont.keys.count > 0 then
					(
						sender.backColor = spinnerKeysColor
						sender.enabled = true
					)else
					(
						sender.backColor =  spinnerNoKeysColor
						sender.enabled = true
					)
				)else
				(
					sender.enabled = false
					sender.backColor = lockedColor
				)
			)
		)
		
	)
	
	
	
	function updateTransforms needsUp:false= 
	(
	
		try(----------------------------------------------------------------------------------------------------------------------------------------------------ADAPT TO CONTROLLER DIFFERENCES
			
			obj = channelBox.nodeList[1]
			
			if obj == undefined then return false
			if not isvalidnode obj then return false
			
			needsUpdate = needsUp
			
			for q in 1 to channelBox.nodeList.Count do
			(
				if (getviscontroller channelBox.nodeList[q]) == undefined then
				(
					channelBox.nodeList[q].visibility = bezier_float()
					channelBox.nodeList[q].visibility.controller.value = 1
				)
			)
			
			subanimList[1] = (getControllerVal obj "position" "x" subanim:true)
			subanimList[2] = (getControllerVal obj "position" "y" subanim:true)
			subanimList[3] = (getControllerVal obj "position" "z" subanim:true)
			
			subanimList[4] = (getControllerVal obj "rotation" "x" subanim:true)
			subanimList[5] = (getControllerVal obj "rotation" "y" subanim:true)
			subanimList[6] = (getControllerVal obj "rotation" "z" subanim:true)
			
			subanimList[7] = (getControllerVal obj "scale" "x" subanim:true)
			subanimList[8] = (getControllerVal obj "scale" "y" subanim:true)
			subanimList[9] = (getControllerVal obj "scale" "z" subanim:true)
			
			subanimList[10] = obj[1]
			
			controllerList[1] = (getControllerVal obj "position" "x" controller:true)
			controllerList[2] = (getControllerVal obj "position" "y"  controller:true)
			controllerList[3] = (getControllerVal obj "position" "z"  controller:true)
			
			controllerList[4] = (getControllerVal obj "rotation" "x"  controller:true)
			controllerList[5] = (getControllerVal obj "rotation" "y"  controller:true)
			controllerList[6] = (getControllerVal obj "rotation" "z"  controller:true)
			
			controllerList[7] = (getControllerVal obj "scale" "x"  controller:true)
			controllerList[8] = (getControllerVal obj "scale" "y"  controller:true)
			controllerList[9] = (getControllerVal obj "scale" "z"  controller:true)
			
			
			
			checkLocks obj
			
			cVal = (getControllerVal obj "position" "x" ) ; if cVal != undefined then (setKeyColor translateX controllerList[1]; translateX.value = cVal) else (setKeyColor translateX undefined reset:true; translateX.value = 0)
			cVal = (getControllerVal obj "position" "y" ) ; if cVal != undefined then (setKeyColor translateY controllerList[2]; translateY.value = cVal) else (setKeyColor translateY undefined reset:true;translateY.value = 0)
			cVal = (getControllerVal obj "position" "z" ) ; if cVal != undefined then (setKeyColor translateZ controllerList[3]; translateZ.value = cVal) else (setKeyColor translateZ undefined reset:true;translateZ.value = 0)
			
			cVal = (getControllerVal obj "rotation" "x" ) ; if cVal != undefined then (setKeyColor rotateX controllerList[4]; rotateX.value = cVal) else (setKeyColor rotateX undefined reset:true; rotateX.value = 0)
			cVal = (getControllerVal obj "rotation" "y" ); if cVal != undefined then (setKeyColor rotateY controllerList[5]; rotateY.value = cVal) else (setKeyColor rotateY undefined reset:true; rotateY.value = 0)
			cVal = (getControllerVal obj "rotation" "z" ); if cVal != undefined then (setKeyColor rotateZ controllerList[6]; rotateZ.value = cVal) else (setKeyColor rotateZ undefined reset:true; rotateZ.value = 0)
			
			cVal = (getControllerVal obj "scale" "x" ) ; if cVal != undefined then (setKeyColor scaleX controllerList[7]; scaleX.value = cVal) else (setKeyColor scaleX undefined reset:true; scaleX.value = 0)
			cVal = (getControllerVal obj "scale" "y" ); if cVal != undefined then (setKeyColor scaleY controllerList[8]; scaleY.value = cVal) else (setKeyColor scaleY undefined reset:true; scaleY.value = 0)
			cVal = (getControllerVal obj "scale" "z" ) ; if cVal != undefined then (setKeyColor scaleZ controllerList[9]; scaleZ.value = cVal) else (setKeyColor scaleZ undefined reset:true; scaleZ.value = 0)

			
			visibility.value = obj.visibility.controller.value	; setKeyColor visibility obj.visibility.controller
			
			needsUpdate = true
			
		)catch(print ("Error auto-updating transforms: " + GetCurrentException()))
	)
	
	function setControlColor val ctrl green:false= 
	(
		
		if val then 
		(
			if (green) then
			(
				ctrl.backColor = labelSelectedColor2
				ctrl.text = "Relative"
			)else
			(
				ctrl.backColor = labelSelectedColor 
			)
		)else 
		(
			ctrl.backColor = labelUnselectedColor
			if (green) then
			(
				ctrl.text = "Absolute"
			)
		)
	)
	
	function updateSelections arg inx = 
	(		
		
		if ((not keyboard.controlpressed and not keyboard.shiftpressed) or inx == 0) then
		(
			lastSelection = 0
			for j in 1 to 10 do (selectionList[j] = false)
		)	
		
		if (inx > 0) then
		(
			if (keyboard.shiftpressed) then
			(
				for j in 1 to 10 do (selectionList[j] = false)
				if lastSelection > 0 then
				(
					for q in amin #(lastSelection, inx) to amax #(lastSelection, inx) do
					(
						selectionlist[q] = true						
					)
				)else
				(
					selectionList[inx] = not selectionList[inx]
					lastSelection = inx
				)
				
			)else
			(
				selectionList[inx] = not selectionList[inx]
				lastSelection = inx
			)
			
		)	
		
		
		
	
		setControlColor selectionList[1] translateXLabel
		setControlColor selectionList[2] translateYLabel
		setControlColor selectionList[3] translateZLabel
		
		setControlColor selectionList[4] rotateXLabel
		setControlColor selectionList[5] rotateYLabel
		setControlColor selectionList[6] rotateZLabel
		
		setControlColor selectionList[7] scaleXLabel
		setControlColor selectionList[8] scaleYLabel
		setControlColor selectionList[9] scaleZLabel
		
		setControlColor selectionList[10] visibilityLabel
		

	)
	
	function setMouseDown sender arg =
	(
		case arg.button of
		(
			
			(arg.button.left):
			(
				currentSpinner = sender
				cursor = dotnetclass "System.Windows.Forms.Cursor"
				p = cursor.Position
				lastMousePos=p.y
			)	
		
		)
	)
	
	function setMouseMove sender arg =
	(
		if sender != currentSpinner then return false
			
		case arg.button of
		(
			
			(arg.button.left):
			(
				cursor = dotnetclass "System.Windows.Forms.Cursor"
				p = cursor.Position
				
				mouseOffSetY=(lastMousePos-p.y)*(returnValue sender #increment)
		
				val = (returnValue sender #value) 
				val += mouseOffsetY
				
				if (val < sender.minimum) then val = sender.minimum
				if (val > sender.maximum) then val = sender.maximum
				
				sender.value = val
				
				lastMousePos = p.y
				yVal = p.y
				
				if (p.y < 1) then
				(
					lastMousePos = (sysinfo.desktopsize[2] - 2)
					yVal = lastMousePos
					cursor.Position = dotnetobject "System.Drawing.Point" p.x (sysinfo.desktopsize[2] - 2)
					
				)else if (p.y > sysInfo.desktopSize[2] - 2) then
				(
					lastMousePos = 1
					yVal = lastMousePos
					cursor.Position = dotnetobject "System.Drawing.Point" p.x 1
					
				)
		
				changeTransforms sender arg
			)
		)
	)
	
	on transformBox open do
	(
		append controlList translateX
		append controlList translateY
		append controlList translateZ
		
		append controlList rotateX
		append controlList rotateY
		append controlList rotateZ
		
		append controlList scaleX
		append controlList scaleY
		append controlList scaleZ
		
		append lockList false
		append lockList false
		append lockList false
		
		append lockList false
		append lockList false
		append lockList false
		
		append lockList false
		append lockList false
		append lockList false
		
		
		append controlList visibility
		
		for q in 1 to 6 do --controlList.count do
		(
			controlList[q].DecimalPlaces = 4
			controlList[q].Increment = .1
			controlList[q].Maximum = 10000000
			controlList[q].Minimum = -10000000
			controlList[q].value = 0
			controlList[q].tabIndex = q
		)
		
		for q in 7 to 10 do --controlList.count do
		(
			controlList[q].DecimalPlaces = 4
			controlList[q].Increment = .01
			controlList[q].Maximum = 10000000
			controlList[q].Minimum = -10000000
			controlList[q].value = 0
			controlList[q].tabIndex = q
		)
		
		
		visibility.Maximum = 1
		visibility.Minimum = 0
		updateSelections undefined 0
	)
	
	function returnValue dnControl type= 
	(
		return ((dotNetClass "System.Decimal").ToSingle (getProperty dnControl type asDotNetObject:true))
	)
	
	function checkKey sender arg =
	(
		inx = 0
		for q in 1 to controlList.count do
		(
			if controlList[q] == sender then
			(
				inx = q
			)
		)
		
		if arg.KeyCode == (dotnetclass "Keys").enter then 
		(	
			theHold.Begin()
			sender.value = returnValue sender #value
			changeTransforms sender arg
			theHold.Accept "Channel Box"
			return true
		)else if arg.KeyCode == (dotnetclass "Keys").tab then
		(	
			theHold.Begin()
			sender.value = returnValue sender #value
			if (inx + 1) > controlList.count then inx = 0
			controlList[inx + 1].focus()
			changeTransforms sender arg
			theHold.Accept "Channel Box"
			return true
		)
		return false
	)
	
	function selectSpinner sender arg=
	(
		sender.select 0 sender.text.count
	)
	
	function rightClickMenu =
	(
		cursor = dotnetclass "System.Windows.Forms.Cursor"
		p = cursor.Position
		
		popupmenu channelBoxRC pos:[p.x, p.y]
	)
	
	on translateXLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 1 else rightClickMenu())
	on translateYLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 2 else rightClickMenu())
	on translateZLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 3 else rightClickMenu())
		
	on rotateXLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 4 else rightClickMenu())
	on rotateYLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 5 else rightClickMenu())
	on rotateZLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 6 else rightClickMenu())
		
	on scaleXLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 7 else rightClickMenu())
	on scaleYLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 8 else rightClickMenu())
	on scaleZLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 9 else rightClickMenu())
		
	on visibilityLabel MouseDown arg do	(if (arg.button == (dotnetclass "MouseButtons").Left) then updateSelections arg 10 else rightClickMenu())
		
	-------------------------------------

	function md sender arg = (theHold.Begin(); setMouseDown sender arg; changeOnClick = false)
	function mu sender arg = ( if not changeOnClick then (changeTransforms sender arg; theHold.Accept "Channel Box"))
	function mm sender arg = (setMouseMove sender arg)
	function cl sender arg = (changeTransforms sender arg; theHold.Accept "Channel Box"; changeOnClick = true)
	function vc sender arg = ()
	function ku sender arg = (checkKey sender arg) 
	function gf sender arg =  (selectSpinner sender arg)
				

	on translateX mousedown sender arg do md sender arg
	on translateX mouseup sender arg do mu sender arg
	on translateX mousemove sender arg do mm sender arg	
	on translateX valuechanged sender arg do vc sender arg
	on translateX click sender arg do cl sender arg
	on translateX keyup sender arg do ku sender arg
	on translateX gotfocus sender arg do gf sender arg
	
	on translateY mousedown sender arg do md sender arg
	on translateY mouseup sender arg do mu sender arg
	on translateY mousemove sender arg do mm sender arg
	on translateY valuechanged sender arg do vc sender arg
	on translateY click sender arg do cl sender arg
	on translateY keyup sender arg do ku sender arg
	on translateY gotfocus sender arg do gf sender arg
	
	on translateZ mousedown sender arg do md sender arg
	on translateZ mouseup sender arg do mu sender arg
	on translateZ mousemove sender arg do mm sender arg
	on translateZ valuechanged sender arg do vc sender arg
	on translateZ click sender arg do cl sender arg
	on translateZ keyup sender arg do ku sender arg
	on translateZ gotfocus sender arg do gf sender arg

	-------
	
	on rotateX mousedown sender arg do md sender arg
	on rotateX mouseup sender arg do mu sender arg
	on rotateX mousemove sender arg do mm sender arg
	on rotateX valuechanged sender arg do vc sender arg
	on rotateX click sender arg do cl sender arg
	on rotateX keyup sender arg do ku sender arg
	on rotateX gotfocus sender arg do gf sender arg
	
	on rotateY mousedown sender arg do md sender arg
	on rotateY mouseup sender arg do mu sender arg
	on rotateY mousemove sender arg do mm sender arg
	on rotateY valuechanged sender arg do vc sender arg
	on rotateY click sender arg do cl sender arg
	on rotateY keyup sender arg do ku sender arg
	on rotateY gotfocus sender arg do gf sender arg
	
	on rotateZ mousedown sender arg do md sender arg
	on rotateZ mouseup sender arg do mu sender arg
	on rotateZ mousemove sender arg do mm sender arg
	on rotateZ valuechanged sender arg do vc sender arg
	on rotateZ click sender arg do cl sender arg
	on rotateZ keyup sender arg do ku sender arg
	on rotateZ gotfocus sender arg do gf sender arg
	
	-------

	on scaleX mousedown sender arg do md sender arg
	on scaleX mouseup sender arg do mu sender arg
	on scaleX mousemove sender arg do mm sender arg
	on scaleX valuechanged sender arg do vc sender arg
	on scaleX click sender arg do cl sender arg
	on scaleX keyup sender arg do ku sender arg
	on scaleX gotfocus sender arg do gf sender arg
	
	on scaleY mousedown sender arg do md sender arg
	on scaleY mouseup sender arg do mu sender arg
	on scaleY mousemove sender arg do mm sender arg
	on scaleY valuechanged sender arg do vc sender arg
	on scaleY click sender arg do cl sender arg
	on scaleY keyup sender arg do ku sender arg
	on scaleY gotfocus sender arg do gf sender arg
	
	on scaleZ mousedown sender arg do md sender arg
	on scaleZ mouseup sender arg do mu sender arg
	on scaleZ mousemove sender arg do mm sender arg
	on scaleZ valuechanged sender arg do vc sender arg
	on scaleZ click sender arg do cl sender arg
	on scaleZ keyup sender arg do ku sender arg
	on scaleZ gotfocus sender arg do gf sender arg
	
	-----
	
	on visibility mousedown sender arg do md sender arg
	on visibility mouseup sender arg do mu sender arg
	on visibility mousemove sender arg do mm sender arg
	on visibility valuechanged sender arg do vc sender arg
	on visibility click sender arg do cl sender arg
	on visibility keyup sender arg do ku sender arg
	on visibility gotfocus sender arg do gf sender arg
	
)

createdialog channelBox 250 710 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_minimizebox)
channelBox.updateNodeSelection 0 0

nodeCallback = NodeEventCallback mouseUp: false all:(channelBox.updateNodeSelection)

regTime = false
	
unregisterTimeCallback timeCall
fn timeCall = channelBox.updateNodeSelection #callbackend undefined
registerTimeCallback timeCall




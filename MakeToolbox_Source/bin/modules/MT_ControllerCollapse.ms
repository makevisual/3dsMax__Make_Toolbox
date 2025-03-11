/*
#NAME:Controller Collapse
#VERSION:1.1
#INSTRUCTIONS:
Controller Collapse caches the keyframes
of attribute controllers in an object.
http://www.makevisual.com/learning/MT_ControllerCollapse.htm
#SOURCE:Tyson Ibele, tyson@tysonibele.com
#HISTORY:03.12.2012 >> Integrated to MakeToolbox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.12.2012 >> Integrated to MakeToolbox
--*****************************************************
ControllerCollapseModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout ControllerCollapseModule)catch()

global framesStart
global framesEnd

rollout ControllerCollapseModule ("Controller Collapse")
(
	local setSubKeys

	groupBox RangegrpBox "Frame Range" width:160 height:59 offset:[-10,-5]
	spinner tStart width:60 range:[-10000,10000,0] type:#integer offset:[-77,-49]
	label SpinnerToLabel "To" offset:[1 ,-20]
	spinner tEnd width:60 range:[-10000,10000,100] type:#integer offset:[10,-19]
	button fScene "Snap To Timeline" width:153 height:20 offset:[1,-1]
	--label l1 "" 
	

	groupBox KeyedControllersgrpBox "Keyed Controllers" width:160 height:63 offset:[-10,0]
	button collSel "Collapse in Selected" height:20 width:153 offset:[1,-51]
	button collAll "Collapse in All" height:20 width:153 offset:[0,-3]
	checkbox collTrans "Collapse Transforms" checked:true offset:[0,1]
	checkbox collAttrib "Collapse Attributes" checked:true offset:[0,-3]
		
	on fScene pressed do
	(
		tStart.value = animationrange.start
		tend.value = animationrange.end
	)
	
	function doScr obj =
	(

		for g in 1 to 7 do
		(
			if not collattrib.checked and g != 3 then
			(
				continue
			)
			if not collTrans.checked and g == 3 then
			(
				continue
			)
			if g == 5 then continue
				
			setSubKeys obj[g] tStart.value tEnd.value collTrans.checked			
		)
		
	)
	
	
	on collSel pressed do
	(
		max create mode
		undo on
		(
			for q in 1 to selection.count do
			(
				obj = selection[q]
				
				try(doScr obj)catch(print ("Error collapsing controllers in " + obj.name))
				
			)
		)
	)
	
	
	
	on collAll pressed do
	(
		max create mode
		undo on
		(
			
			for q in 1 to objects.count do
			(
				obj = objects[q]
				
				try(doScr obj)catch(print ("Error collapsing controllers in " + obj.name))
				
			)
		)
	)
	
	
	fn setSubKeys sub start end setTransforms =
	(
		for i = 1 to sub.numsubs do 
		(
			subSub = sub[i]
						
			if ((subSub.keys != undefined) and (subSub.keys.count > 0)) then
			(
				keylist = #()
				for k = start to end  do 
				(
					at time k
					(
						append keylist subsub.value
					)
					
				)
				
				if keylist.count > 0 then
				(
					inx = 1
					try(
						subsub.controller = bezier_float()
					)catch
					(
						try
						(
							subsub.controller = bezier_scale()
						)catch
						(
							
						)
					)
					for k = start to end  do 
					(
						at time k
						(
							with animate on
							(
								subsub.value = keylist[inx]
								inx += 1
							)
							
						)
						
					)
				)
			)
			setSubKeys subSub start end setTransforms
		)
   )
   
)
AddSubRollout MakeToolbox.theSubrollout ControllerCollapseModule
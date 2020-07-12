/*
#NAME:Align and Copy
#VERSION:1.0
#INSTRUCTIONS:
Use align and copy to align one
object to a set of target objects.
http://www.makevisual.com/learning/MT_AlignAnCopy.htm
#SOURCE:Tyson Ibele, tyson@tysonibele.com
#HISTORY:03.12.2012  >> Integrated to MakeToolbox	

*/


--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Integrated to MakeToolbox						  
--*****************************************************
AlignAndCopyModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout AlignAndCopyModule)catch()

fn AlignPivotTo Obj Trgt =
(
	-- Get matrix from object
	if classOf Trgt != matrix3 then Trgt = Trgt.transform
	
	-- Store child transforms
	local ChldTms = in coordSys Trgt ( for Chld in Obj.children collect Chld.transform )
	
	-- Current offset transform matrix
	local TmScale = scaleMatrix Obj.objectOffsetScale
	local TmRot = Obj.objectOffsetRot as matrix3
	local TmPos = transMatrix Obj.objectOffsetPos
	local TmOffset = TmScale * TmRot * TmPos
	
	-- New offset transform matrix
	TmOffset *= obj.transform * inverse Trgt
	
	-- Apply matrix
	Obj.transform = Trgt
	
	-- Restore offsets
	Obj.objectOffsetPos = TmOffset.translation
	Obj.objectOffsetRot = TmOffset.rotation
	Obj.objectOffsetScale = TmOffset.scale
	
	-- Restore child transforms
	for i = 1 to Obj.children.count do Obj.children[i].transform = ChldTms[i] * inverse Trgt * Obj.transform
)
	
rollout AlignAndCopyModule ("Align And Copy")
(
	local baseObj
	local sourceObj
	
	pickbutton source "Pick Source Object" width:160 height:20 offset:[0,-3] tooltip:"Pick the object you'd like to distribute"

	pickbutton base "Pick Base" width:160 height:20 offset:[0,-3] enabled: false tooltip:"Pick the object whose pivot information you'd like to use instead of the source object's pivot"
	
	button targetObjs "Apply to Selected Targets" width:160 height:20 offset:[-1,-3] tooltip:"Align and copy the source object to the selected targets" align:#center
	
	groupBox OptionsGB "Options" width:158 height:85 offset:[-10,-4]
	checkbox customBase "Pick Base" offset:[0,-75]
	checkbox instanceObjectCheck "Instance object" checked:true offset:[0,-3]
	checkbox copyChildren "Copy Children" checked:true offset:[0,-3]
	checkbox parent "Parent to target" checked:true offset:[0,-3]
	button help "?" width:20 height:20 align:#right offset:[2,-57]
	
	on help pressed do
	(
		str = "This script allows you to distribute a source object
over a set of selected targets. \n\nIf you choose a base object,
the source object will be distributed using that base object's
pivot instead of its own."
		
		messagebox str title:"Help"
	)
	on base picked obj do
	(
		baseObj = obj
		base.text = obj.name
	)
	
	on source picked obj do
	(
		sourceObj = obj
		source.text = obj.name
	)
	
	on customBase changed val do
	(
		base.enabled = val
	)
	
	on targetObjs pressed do
	(
		if isvalidnode sourceObj then
		(
			if instanceObjectCheck.checked == true then (cloneType = #instance) else (cloneType = #copy)
			
			for q in 1 to selection.count do
			(
				if (isvalidnode baseObj and customBase.checked) then
				(
					p = point()
					p.transform = sourceObj.transform
					alignPivotTo p baseObj
				
								
					
					if (copyChildren.checked) then
					(
						newNodes = #()
						
						if instanceObjectCheck.checked == true then
							(
							maxops.clonenodes sourceObj expandhierarchy:true cloneType:#instance newnodes:&newNodes
							)
							else
							(
							maxops.clonenodes sourceObj expandhierarchy:true cloneType:#copy newnodes:&newNodes
							)
						
						copyObj = newnodes[1]
						
					)else
					(
						if instanceObjectCheck.checked == true then (copyObj = instance  sourceObj) else (copyObj = copy sourceObj)
					)
					
					copyObj.parent = p
					p.transform = selection[q].transform
					delete p
					
				)else
				(
					if (copyChildren.checked) then
					(
						newNodes = #()
						
						if instanceObjectCheck.checked == true then
							(
							maxops.clonenodes sourceObj expandhierarchy:true cloneType:#instance newnodes:&newNodes
							)
							else
							(
							maxops.clonenodes sourceObj expandhierarchy:true cloneType:#copy newnodes:&newNodes
							)
							
						copyObj = newnodes[1]
						
					)else
					(
						if instanceObjectCheck.checked == true then (copyObj = instance  sourceObj) else (copyObj = copy sourceObj)
					)
					
					copyObj.transform = selection[q].transform
					
				)
				
				if (parent.checked) then
				(
					copyObj.parent = selection[q]
				)
					
			)
			
			
		)
	)
	
	
	
)

AddSubRollout MakeToolbox.theSubrollout AlignAndCopyModule
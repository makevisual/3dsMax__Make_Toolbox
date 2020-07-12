/*
#NAME:Remove Winged Vertices
#VERSION:1.0
#INSTRUCTIONS:
Removes winged vertices from an object
http://www.makevisual.com/learning/MT_RemoveWingedVerts.htm
#SOURCE:jos_balcaen@hotmail.com, rf.romainfaure@gmail.com
#HISTORY:12.03.2012 -- Integration to MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Script by jos_balcaen@hotmail.com
-- Modified by rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 12.03.2012 -- Integration to MakeToolBox
--*****************************************************
RemoveVerticesModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout RemoveVerticesModule)catch()

rollout RemoveVerticesModule ("Remove Winged Vertices") /* + (RemoveVerticesModuleVer as string))*/
(
	pickbutton PkObjectBtn "Pick Object" width: 160 height:20 offset:[0,-5]
	--spinner spnEdges "Number of edges :" range:[0,100,2] type:#integer fieldWidth:30
	button RemoveBtn "Remove Vertices" width: 160 height:20 offset:[0,-3]
	on PkObjectBtn picked obj do
	(
		PkObjectBtn.text = obj.name
	)
	on RemoveBtn pressed do
	(
		MyObj = PkObjectBtn.object
		Converttopoly MyObj
		edgecount = 2 --spnEdges.value
		--clearUndoBuffer()
		undo on
		(
			local theVerts=#()
			index = 1
			for i = 0 to MyObj.GetNumVertices() do
			(
				if (MyObj.GetVertexEdgeCount i == edgecount ) do 
				(
					theVerts[index] = i
					index += 1
				)
			)
			polyop.setVertSelection MyObj theVerts
			MyObj.EditablePoly.Remove selLevel:#Vertex
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout RemoveVerticesModule
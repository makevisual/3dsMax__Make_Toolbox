/*
--**********************************************************************************--
--                                                                                  --
--                            REMOVE WINGED VERTICES                              --
--                                                                                  --
--**********************************************************************************--

#NAME: Remove Winged Vertices
#VERSION: 1.1
#LAST UPDATED: 2025.09.29

#DESCRIPTION:
A utility to remove "winged" vertices (vertices connected to only two edges) 
from a polygonal object. This is useful for cleaning up geometry after certain 
modeling operations.

#INSTRUCTIONS:
Select a target object using the "Pick Object" button, then click "Remove Vertices" 
to delete any vertices that are connected to exactly two edges.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Remove_Winged_Verts

#CREDITS:
    #Author: jos_balcaen@hotmail.com
    #Contributors:
        - Romain Faure (rf.romainfaure@gmail.com): Modifications and integration.
        - David Almeida (david.almeida@makevisual.com): Undo stack improvements.

#HISTORY:
    - v1.1 (2025.09.29): Added a custom name to the Undo stack for better visibility.
    - v1.0 (2012.12.03): Initial integration into MakeToolBox.

--**********************************************************************************--
*/
RemoveVerticesModuleVer = 1.1
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
		undo "Remove Winged Verts" on
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
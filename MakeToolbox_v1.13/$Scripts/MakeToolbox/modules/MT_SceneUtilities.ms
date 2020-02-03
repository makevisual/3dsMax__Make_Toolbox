/*
#NAME:Scene Utilities
#VERSION:1.0
#INSTRUCTIONS:
Remove note tracks from scene file
http://www.makevisual.com/learning/MT_SceneUtilities.htm
#SOURCE:rf.romainfaure@gmail.com
#HISTORY:03.13.2011 >> Add to MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.13.2011 >> Add to MakeToolBox
--*****************************************************
SceneUtilitiesModuleVer = ""
try(removeSubRollout MakeToolbox.theSubrollout SceneUtilitiesModule)catch()

rollout SceneUtilitiesModule ("Scene Utilities" + (SceneUtilitiesModuleVer as string))
(
	
button RemoveNoteTrackBtn "Remove NoteTrack" width:160 height:20 offset:[0,-3]
	on RemoveNoteTrackBtn pressed do
	(
		trackIndex = 1

		m = trackViewNodes[trackIndex]
		while (m != undefined) do
		(
			print trackIndex
			ct = numNoteTracks m
			id = ct
			for i = 1 to ct do
			(
				tr = getNoteTrack m id		
				deleteNoteTrack m tr
				id = id - 1
				ith = mod i 200
				if  ith  < 1 then Print id
			)
			trackIndex = trackIndex + 1
			m = trackViewNodes[trackIndex]
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout SceneUtilitiesModule
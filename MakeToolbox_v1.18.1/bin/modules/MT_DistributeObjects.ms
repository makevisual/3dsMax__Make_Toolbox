/*
#NAME: Distribute Objects
#VERSION:1.0
#SOURCE:neil.barck@makevisual.com
#HISTORY:03.13.2011 >> Add to MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by neil.barck@makevisual.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.13.2011 >> Add to MakeToolBox
--*****************************************************
DistributeObjectsModuleVer = ""
try(removeSubRollout MakeToolbox.theSubrollout DistributeObjectsModule)catch()

rollout DistributeObjectsModule ("Distribute Object" + (DistributeObjectsModuleVer as string))
(
	
button Btn_SpaceObjects "Distribute Objects" width:160 height:20 offset:[0,-3]
spinner Spn_SpaceOffest "Offset:" range:[0,10000,10] width: 90 offset:[0,0]
	on Btn_SpaceObjects pressed do
	(
		curObjs = selection as array 
		curVal = 0
		mult = Spn_SpaceOffest.value

		for curObj in curObjs do
		(
			curObj.position = [(curVal * mult ),0,0]
			curVal += 1
		)
	)

)
AddSubRollout MakeToolbox.theSubrollout DistributeObjectsModule
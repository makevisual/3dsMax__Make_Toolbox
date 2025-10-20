
/*
--**********************************************************************************--
--                                                                                  --
--                              SELECT BY PERCENT                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Select by Percent
#VERSION: 1.2
#LAST UPDATED: 2025.09.30

#DESCRIPTION:
A utility to select a specified percentage of objects from the current selection. 
The sub-selection can be made randomly or distributed evenly throughout the 
selection order.

#INSTRUCTIONS:
Select the objects to process, set the desired percentage, choose either "Random" 
or "Even" selection method, and click the "Select" button.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Select_by_Percent

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Reworked logic and added "Even Selection" method.

#HISTORY:
    - v1.2 (2025.09.30): Reworked selection logic, added "Even Selection" method, and improved UI.
    - v1.1 (2012.03.05): Initial integration into MakeToolbox.
    - v1.0 (2011.05.25): Initial release.

--**********************************************************************************--
*/
SelectByPercentModuleVer = 1.2
try(removeSubRollout MakeToolbox.theSubrollout SelectByPercentModule)catch()

rollout SelectByPercentModule ("Select By Percent v" + (SelectByPercentModuleVer as string))
(
	spinner spinnerSelectPercent "" range:[0,100,50] align:#left pos:[5,5] width:50 tooltip:"Sets the percent of objects to select"
	label labelSelectPerecent "Percent to select" pos:[60,7]
	checkbox checkboxRandom "Random Selection" pos:[7,25] checked:true tooltip:"Sets selection method to random"
	checkbox checkboxEveryOther "Even Selection" pos:[7,40] tooltip:"Sets selection method to even according to the selection order"
	Button buttonSelect "Select" width:160 height:20 offset:[0,-2]
		
	function FN_Select arg = 
	(
		allArr = selection as array
		allArrIndexes = (for ind = 1 to allArr.count collect ind)
		selCount = (int (allArr.count * (spinnerSelectPercent.value *.01)))
		selArr = #()
		if checkboxRandom.checked == true then
		(
			for i in 1 to selCount do
			(
				randIndex = (random 1 allArrIndexes.count)
				ObjIndex = allArrIndexes[randIndex]
				join selArr #(allArr[ObjIndex])
				deleteItem allArrIndexes randIndex
			)
		)
		else
		(
			StepIndex = int (100.0/spinnerSelectPercent.value)
			for i in 1 to allArr.count by StepIndex do
			(
				print i
				join selArr #(allArr[i])
			)
		)
		select selArr
	)
	on checkboxRandom changed state do
	(
		if checkboxRandom.checked == true then
		(
			checkboxEveryOther.checked = false
		)
		else
		(
			checkboxEveryOther.checked = true
		)
	)
	on checkboxEveryOther changed state do
	(
		if checkboxEveryOther.checked == true then
		(
			checkboxRandom.checked = false
		)
		else
		(
			checkboxRandom.checked = true
		)
	)
	on buttonSelect pressed do
	(
		FN_Select 1
	)
)
AddSubRollout MakeToolbox.theSubrollout SelectByPercentModule
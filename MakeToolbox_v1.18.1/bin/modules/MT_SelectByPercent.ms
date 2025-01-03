
--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.25.2011 >> Release -ad
--- version 1.1 : 03.05.2012  >> Integrated to MakeToolbox
--								  and additional colors added -ad
--*****************************************************
SelectByPercentModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout SelectByPercentModule)catch()


rollout SelectByPercentModule ("Select By Percent v" + (SelectByPercentModuleVer as string))
(
spinner spinnerSelectPercent "" range:[0,100,50] align:#left pos:[5,5] width:50
label labelSelectPerecent "Percent to select" pos:[60,7]
checkbox checkboxRandom "Random Selection" pos:[7,25] checked:true
checkbox checkboxEveryOther "Even Selection" pos:[7,40]
Button buttonSelect "Select" width:160 height:20 offset:[0,-2]
	
function FN_Select arg = 
(
allArr = selection as array
selCount = (int (allArr.count * (spinnerSelectPercent.value *.01)))
selArr = #()

print selCount
for i in 1 to selCount do
(
randIndex = (random 0 allArr.count)
join selArr #(allArr[randIndex])
)

select selArr

)
	
on checkboxRandom changed state do ( if checkboxRandom.checked == true then (checkboxEveryOther.checked = false) else (checkboxEveryOther.checked = true))
on checkboxEveryOther changed state do ( if checkboxEveryOther.checked == true then (checkboxRandom.checked = false) else (checkboxRandom.checked = true))

on buttonSelect pressed do (FN_Select 1)

	
)
AddSubRollout MakeToolbox.theSubrollout SelectByPercentModule
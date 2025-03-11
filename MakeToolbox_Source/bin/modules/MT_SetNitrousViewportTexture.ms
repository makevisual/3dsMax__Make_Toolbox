/*
#NAME: Nitrous Viewport Texture
#VERSION:1.0
#INSTRUCTIONS:
Nitrous Viewport Texture For MAKE
#SOURCE:Romain Faure rf.romainfaure@gmail.com
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Romain Faure rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 10.03.2013 >> Release
--*****************************************************
-- INFOS :
--****************************************************
-- TUTORIAL :
--****************************************************
MT_SetNitrousViewportTexture = 01.0
try(removeSubRollout MakeToolbox.theSubrollout MT_SetNitrousViewportTexture)catch()


fn FnSetTextureSize SetValue = 
(
	NitrousGraphicsManager.SetTextureSizeLimit SetValue true
	
)

fn FnShowInViewport =
(
	for m in sceneMaterials do
	( try(
		m.showInViewport = false
		m.showInViewport = true
	)catch()
	)
)

rollout MT_SetNitrousViewportTexture "MT_NitrousTextures" width:275 height:230
(
	groupBox grpSetNitrousViewportTextureSize "Viewport Map Size"  width:135 height:50 pos:[10,5]
	button btn1024 "512" width:35 height:20 pos:[15,25]
	button btn2048 "2048" width:35 height:20 pos:[60,25]
	button btn4096 "4096" width:35 height:20 pos:[105,25]
	
		on btn1024 pressed do
    (
    FnSetTextureSize(512)
	FnShowInViewport()
	)
	
		on btn2048 pressed do
    (
    FnSetTextureSize(2048)
	FnShowInViewport()
	)
	
		on btn4096 pressed do
    (
    FnSetTextureSize(4096)
	FnShowInViewport()
	)
	
)
AddSubRollout MakeToolbox.theSubrollout MT_SetNitrousViewportTexture 


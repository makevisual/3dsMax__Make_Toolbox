/*
--**********************************************************************************--
--                                                                                  --
--                         NITROUS VIEWPORT TEXTURE                               	--
--                                                                                  --
--**********************************************************************************--

#NAME: Nitrous Viewport Texture
#VERSION: 1.1
#LAST UPDATED: 2025.09.29

#DESCRIPTION:
A utility to quickly set the maximum texture size limit for the Nitrous viewport 
and refresh scene materials to apply the change.

#INSTRUCTIONS:
Click one of the resolution buttons (512, 2048, or 4096) to change the maximum 
texture resolution displayed in the viewport.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Set_Nitrous_Viewport_Texture

#CREDITS:
    #Author: Romain Faure (rf.romainfaure@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): UI and tooltip updates.

#HISTORY:
    - v1.1 (2025.09.29): Added and updated tooltips.
    - v1.0 (2013.10.03): Initial release.

--**********************************************************************************--
*/
MT_SetNitrousViewportTextureVersion = 1.1
try(removeSubRollout MakeToolbox.theSubrollout MT_SetNitrousViewportTexture)catch()


fn FnSetTextureSize SetValue = 
(
	NitrousGraphicsManager.SetTextureSizeLimit SetValue true
)

fn FnShowInViewport =
(
	for m in sceneMaterials do
	(
		try
		(
			m.showInViewport = false
			m.showInViewport = true
		)
		catch()
	)
)

rollout MT_SetNitrousViewportTexture ("MT_NitrousTextures v" + (MT_SetNitrousViewportTextureVersion as string)) width:275 height:230
(
	groupBox grpSetNitrousViewportTextureSize "Viewport Map Size"  width:135 height:50 pos:[10,5]
	button btn1024 "512" width:35 height:20 pos:[15,25] tooltip:"Sets viewport texture size to 512 pixels"
	button btn2048 "2048" width:35 height:20 pos:[60,25] tooltip:"Sets viewport texture size to 2048 pixels"
	button btn4096 "4096" width:35 height:20 pos:[105,25] tooltip:"Sets viewport texture size to 4096 pixels"
	
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


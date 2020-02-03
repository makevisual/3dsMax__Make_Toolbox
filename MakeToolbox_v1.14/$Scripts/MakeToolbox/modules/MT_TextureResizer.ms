/*
#NAME:Texture Resizer
#VERSION:1.1
#INSTRUCTIONS:
Use Texture Resizer to resize the maps in a shader.
Supports:
-- StandardMaterial()
-- VrayMtl()
-- VrayMtlBlend() + VrayMtl()
-- Multi-SubObject
-- CompositeTextureMap
http://www.makevisual.com/learning/MT_TextureResizer.htm
#SOURCE: Romain Faure, rf.romainfaure@gmail.com
#HISTORY:03.14.2012 >> Add shaders compatibilities		
03.05.2012  >> Integrated to MakeToolbox
05.25.2011 >> Release
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Author : Romain Faure, rf.romainfaure@gmail.com
-- Website: www.romainfaure.net
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.25.2011 >> Release
--- version 1.1 : 03.05.2012  >> Integrated to MakeToolbox
--	version 1.1  : 03.14.2012 >> Add shaders compatibilities							 
--*****************************************************
-- INFOS
-- Allow you to resize maps in a shader.
-- Work with :
-- StandardMaterial()
-- VrayMtl()
-- VrayMtlBlend() + VrayMtl()
-- Multi-SubObject
-- CompositeTextureMap
--*****************************************************
try(removeSubRollout MakeToolbox.theSubrollout TextureResizerModule)catch()

--- Globals
-- << Functions >> --
global FnResize
global FnVrayMapsSlot
global FnVrayMapsSlot
global FnVrayMtl
global FnVrayShader
global FnVRayBlendMtlCoat
global FnSdtShader
global FnMultiSubStd
global FnMultiSubVrayMtl
global FnMultiSubVrayBlend

--- Variables
-- << Bitmap  >> --
NewMapSize = undefined
NewMapSizeHeight = undefined
NewMapSizeWidth = undefined
CurrentMapSizeHeight = undefined
CurrentMapSizeWidth = undefined

-- << Shader  >> --
ActiveMaterialType = undefined
ActiveMaterialTypeValue = undefined
StandardMapIndex = i 
VrayMapIndex = i
VrayBlendMtlCoatVariable = i
MultiSubVariable = i
MultiSubMaterialVariable = i
VrayMaterialMaps = #()
VrayMaterialMapsIndex = #()
VrayBlendCoatMtlArray = # ()

-- << MapPath  >> --
FolderName = undefined
CurrentMapPath = undefined
CurrentMapDirPath = undefined
CurrentMapFileName = undefined
NumberOfCharInDirPath = undefined
FolderNameInAnArray = undefined
NumberOfFolderInPath  = undefined
FolderAt = undefined
CharIndex = undefined
CharAt = undefined
Mappath = undefined
MapPathExist = undefined
EditTextPathValue = ""

fn FnResize =
(
	
	makeDir(CurrentMapDirPath + "\\" + FolderName )
												
	-- Create A New Material
	meditMaterials[24] = Standardmaterial ()
	meditMaterials[24].name = "_resizemap"
												
	-- Save Gamma Scene Settings
	GammaArray = #()
	append GammaArray IDisplayGamma.colorCorrectionMode
	append GammaArray IDisplayGamma.gamma
												
	-- Change Gamma Scene Settings
	IDisplayGamma.colorCorrectionMode = #none
	IDisplayGamma.gamma = 2.2																
	MapPath = CurrentMapDirPath +  "\\" + FolderName + "\\" + CurrentMapFileName
												
	copyFile CurrentMapPath MapPath
												
	CurrentBitmap = meditMaterials[24].diffuseMap = Bitmaptexture FileName: CurrentMapPath --- put all the maps in one shader map slot for resize them all
												
	CurrentMapSizeHeight = CurrentBitmap.bitmap.height -- Return select bitmap height size
	CurrentMapSizeWidth = CurrentBitmap.bitmap.width -- Return select bitmap width size
	NewMapSizeHeight = CurrentMapSizeHeight*(NewMapSize/100.0) -- Scale height map size
	NewMapSizeWidth =  CurrentMapSizeWidth*(NewMapSize/100.0) -- Scale width map size
												
	if NewMapSize  == 100 -- I don't want to resize a full size map to a full size, i just want to duplicate them
	then ()
	else 
		(
			RMap = rendermap CurrentBitmap size:[NewMapSizeHeight,NewMapSizeWidth] fileName:MapPath filter:false
			save RMap
		)
		
		-- Restore Element
		IDisplayGamma.colorCorrectionMode = GammaArray[1]
		IDisplayGamma.gamma = GammaArray[2]
		meditMaterials[24] = Standardmaterial ()  -- Clean Edit Material Editor
)
			
fn FnStdMtl =
(
	if classof meditMaterials[activeMeditSlot] == Standardmaterial
	then 
	(
		ActiveMaterialType = meditMaterials[activeMeditSlot]
		ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot]"
		FnSdtShader()
	)
)
		
fn FnMultiSub =
(
	if classof meditMaterials[activeMeditSlot] == Multimaterial
	then 
	(
		for i = 1 to meditMaterials[activeMeditSlot].count do 
		(
			MultiSubMaterialVariable = i
			if classof meditMaterials[activeMeditSlot].materialList[i] == Standardmaterial
			then(FnMultiSubStd())
			if  classof meditMaterials[activeMeditSlot].materialList[i] == VRayMtl
			then(FnMultiSubVrayMtl())
			if classof meditMaterials[activeMeditSlot].materialList[i] == VRayBlendMtl
			then(FnMultiSubVrayBlend())
		)
	)
)
		
fn FnMultiSubStd = 
(
	ActiveMaterialType = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable]
	ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].material[" + (MultiSubMaterialVariable as string) + "]" 
	FnSdtShader()
)

fn FnMultiSubVrayMtl =
(
	ActiveMaterialType = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable]
	ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].material[" + (MultiSubMaterialVariable as string) + "]" 
	FnVrayMapsSlot()
)
		
fn FnMultiSubVrayBlend =
(
	ActiveMaterialType = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable]
	ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].material[" + (MultiSubMaterialVariable as string) + "]" 
	if classof meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable] == VRayBlendMtl 
	then
	(
		if classof meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].baseMtl == VRayMtl
		then 
		(
			ActiveMaterialType = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].baseMtl
			ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].material[" + (MultiSubMaterialVariable as string) + "].baseMtl"
			FnVrayMapsSlot()
		)
		
		VrayBlendCoatMtlArray = #()
		for i = 1 to meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].coatMtl.count do
		(
			if meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].coatMtl[i] != undefined
			then		
			(
				VrayBlendCoatMtl = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].coatMtl[i]
				append VrayBlendCoatMtlArray VrayBlendCoatMtl
				
				if classof meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].coatMtl[i] == VrayMtl
				then
				(
					for i = 1 to VrayBlendCoatMtlArray.count do 
					(
						VrayBlendMtlCoatVariable = i
						ActiveMaterialType = meditMaterials[activeMeditSlot].material[MultiSubMaterialVariable].coatMtl[i]
						ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].material[" + (MultiSubMaterialVariable as string) + "].coatMtl[" + (i as string) + "]"
						FnVrayMapsSlot()	
					)
				)
			)
		)	
	)
)
		
fn FnSdtShader = 
(
	MaterialMaps = ActiveMaterialType.maps
	for i = 1 to MaterialMaps.count do
	(
		StandardMapIndex = i -- Store "i" as new variable
		CurrentMapPath = undefined
		CurrentMapDirPath = undefined
		CurrentMapFileName = undefined
		NumberOfCharInDirPath = undefined
		FolderNameInAnArray = undefined
		NumberOfFolderInPath  = undefined
		FolderAt = undefined
		CharIndex = undefined
		CharAt = undefined
		Mappath = undefined
		MapPathExist = undefined
				
		if classof MaterialMaps[i] == Bitmaptexture
		then
			(		
				CurrentMapPath = MaterialMaps[i].filename --  "U:\FolderName\Map.jpg"
				CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
				NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
				CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
				CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
				FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
				NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
				FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last folder
				MapPath = CurrentMapDirPath + "\\" +  FolderName + "\\" + CurrentMapFileName
				MapPathExist = doesFileExist MapPath
						
				-- Folder Exist
				if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
				then 
				(
					for i = 1 to CurrentMapDirPath.count do 
					(
						CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
						CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
						if CharAt == "\\" 
						then exit
					)
			
					CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
					MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName
					MapPathExist = doesFileExist MapPath
						
					if  MapPathExist == true
					then(execute ((ActiveMaterialTypeValue as string) + ".maps[" + (i as string) + "]   =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
					else 
					(
						CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
						FnResize()
						MapPathExist = doesFileExist MapPath
						
						if  MapPathExist == true
						then(execute ((ActiveMaterialTypeValue as string) + ".maps[" + (i as string) + "]   =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
					)
				)
				-- Folder Not Exist
				else 	
				(	
					FnResize()
					MapPathExist = doesFileExist MapPath
					if  MapPathExist == true
					then(execute ((ActiveMaterialTypeValue as string) + ".maps[" + (i as string) + "]   =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
					else ()
				)
			)
				
		if classof MaterialMaps[i] == CompositeTexturemap
		then
		(
			for i  = 1 to MaterialMaps[StandardMapIndex].mapList.count do
			(
				if classof MaterialMaps[StandardMapIndex].mapList[i] == Bitmaptexture
				then
				(		
								
					CurrentMapPath = MaterialMaps[StandardMapIndex].mapList[i].filename --  "U:\FolderName\Map.jpg"
					CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
					NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
					CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
					CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
					FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
					NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
					FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last fold

					if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
					then 
					(
						for i = 1 to CurrentMapDirPath.count do 
						(
							CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
							CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
							if CharAt == "\\" 
							then exit				
						)
							
						CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
						MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName
						MapPathExist = doesFileExist MapPath
								
						if  MapPathExist == true
						then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) + "] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else 
						(
							CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
							FnResize()
							MapPathExist = doesFileExist MapPath	
								
							if  MapPathExist == true
							then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) +"] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						)
						)				
						else 	
						(		
							FnResize()
							MapPathExist = doesFileExist MapPath
							if  MapPathExist == true
							then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) + "] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						)					
				)
				
				if classof MaterialMaps[StandardMapIndex].mapList[i] == Color_Correction
				then
				(		
						
					CurrentMapPath = MaterialMaps[StandardMapIndex].mapList[i].map.filename --  "U:\FolderName\Map.jpg"
					CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
					NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
					CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
					CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
					FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
					NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
					FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last folde
					
					if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
					then 
					(
						for i = 1 to CurrentMapDirPath.count do 
						(
							CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
							CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
							if CharAt == "\\" 
							then exit		
						)
								
						CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
						MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName	
						MapPathExist = doesFileExist MapPath
									
						if  MapPathExist == true
						then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) + "].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else 
						(
							CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
							FnResize()	
							MapPathExist = doesFileExist MapPath	
							
							if  MapPathExist == true
							then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) + "].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
							else ()
							)
					)				
					else 	
					(		
						FnResize()
						MapPathExist = doesFileExist MapPath
						if  MapPathExist == true
						then(execute ((ActiveMaterialTypeValue as string)  + ".maps[" + (StandardMapIndex as string) + "].mapList[" + (i as string) + "].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else ()
					)					
				)	
			)	
		)
	)
)
			
fn FnVrayMtl =
(
	if classof meditMaterials[activeMeditSlot] == VRayMtl
	then 
	(
		ActiveMaterialType = meditMaterials[activeMeditSlot]
		ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot]"
		FnVrayMapsSlot()
	)
	else()
)
		
fn FnVrayBlendMtl =
(
	if classof meditMaterials[activeMeditSlot] == VRayBlendMtl 
	then
	(
		if classof meditMaterials[activeMeditSlot].baseMtl == VRayMtl
		then (FnVRayBlendMtlBase())
		
		VrayBlendCoatMtlArray = #()
			
		for i = 1 to meditMaterials[activeMeditSlot].coatMtl.count do
		(
			if meditMaterials[activeMeditSlot].coatMtl[i] != undefined
			then
			(
				VrayBlendCoatMtl = meditMaterials[activeMeditSlot].coatMtl[i]
				append VrayBlendCoatMtlArray VrayBlendCoatMtl
				
				if classof meditMaterials[activeMeditSlot].coatMtl[i] == VrayMtl
				then(FnVRayBlendMtlCoat())
			)
		)		
	)
)
		
fn FnVRayBlendMtlBase =
(
	ActiveMaterialType = meditMaterials[activeMeditSlot].baseMtl
	ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].baseMtl"
	FnVrayMapsSlot()
)

fn FnVRayBlendMtlCoat =
(
	for i = 1 to VrayBlendCoatMtlArray.count do 
	(
		VrayBlendMtlCoatVariable = i
		ActiveMaterialType = meditMaterials[activeMeditSlot].coatMtl[i]
		ActiveMaterialTypeValue = "meditMaterials[activeMeditSlot].coatMtl[" + (i as string) + "]"
		FnVrayMapsSlot()	
	)
)
		
fn FnVrayMapsSlot =
(
	-- Create an array with all VrayMtl textures
	VrayMaterialMaps = #()
	append VrayMaterialMaps ActiveMaterialType.texmap_diffuse -- 1 
	append VrayMaterialMaps ActiveMaterialType.texmap_roughness -- 2
	append VrayMaterialMaps ActiveMaterialType.texmap_reflection -- 3
	append VrayMaterialMaps ActiveMaterialType.texmap_hilightGlossiness -- 4 
	append VrayMaterialMaps ActiveMaterialType.texmap_reflectionGlossiness -- 5 
	append VrayMaterialMaps ActiveMaterialType.texmap_reflectionIOR --6
	append VrayMaterialMaps ActiveMaterialType.texmap_anisotropy -- 7
	append VrayMaterialMaps ActiveMaterialType.texmap_anisotropy_rotation	-- 8	
	append VrayMaterialMaps ActiveMaterialType.texmap_refraction -- 9
	append VrayMaterialMaps ActiveMaterialType.texmap_refractionGlossiness -- 10
	append VrayMaterialMaps ActiveMaterialType.texmap_refractionIOR -- 11
	append VrayMaterialMaps ActiveMaterialType.texmap_translucent -- 12
	append VrayMaterialMaps ActiveMaterialType.texmap_bump -- 13
	append VrayMaterialMaps ActiveMaterialType.texmap_displacement -- 14
	append VrayMaterialMaps ActiveMaterialType.texmap_opacity -- 15
	append VrayMaterialMaps ActiveMaterialType.texmap_environment --16
				
	-- Create an array with all VrayMtl textures slot name
	VrayMaterialMapsIndex = #()
	append VrayMaterialMapsIndex "texmap_diffuse"
	append VrayMaterialMapsIndex "texmap_roughness"
	append VrayMaterialMapsIndex "texmap_reflection"
	append VrayMaterialMapsIndex "texmap_hilightGlossiness"
	append VrayMaterialMapsIndex "texmap_reflectionGlossiness"
	append VrayMaterialMapsIndex "texmap_reflectionIOR"
	append VrayMaterialMapsIndex "texmap_anisotropy"
	append VrayMaterialMapsIndex "texmap_anisotropy_rotation"
	append VrayMaterialMapsIndex "texmap_refraction"
	append VrayMaterialMapsIndex "texmap_refractionGlossiness"
	append VrayMaterialMapsIndex "texmap_refractionIOR"
	append VrayMaterialMapsIndex "texmap_translucent"
	append VrayMaterialMapsIndex "texmap_bump"
	append VrayMaterialMapsIndex "texmap_displacement"
	append VrayMaterialMapsIndex "texmap_opacity"
	append VrayMaterialMapsIndex "texmap_environment"
	
	FnVrayShader()
)
		
fn FnVrayShader =
(
	for i = 1 to VrayMaterialMaps.count do
	(
		-- Variables
		VrayMapIndex = i -- Store "i" as new variable
		CurrentMapPath = undefined
		CurrentMapDirPath = undefined
		CurrentMapFileName = undefined
		NumberOfCharInDirPath = undefined
		FolderNameInAnArray = undefined
		NumberOfFolderInPath  = undefined
		FolderAt = undefined
		CharIndex = undefined
		CharAt = undefined
		Mappath = undefined
		MapPathExist = undefined
								
		if classof VrayMaterialMaps[VrayMapIndex] == Bitmaptexture
		then
			(
				CurrentMapPath = VrayMaterialMaps[i].filename --  "U:\FolderName\Map.jpg"
				CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
				NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
				CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
				CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
				FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
				NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
				FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last folder
				
				if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
				then 
				(
					for i = 1 to CurrentMapDirPath.count do 
					(
						CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
						CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
						if CharAt == "\\" 
						then exit				
					)
							
					CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
					MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName
					MapPathExist = doesFileExist MapPath
									
					if  MapPathExist == true
					then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[i] +" =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
					else 
						(
							CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
							FnResize()
							MapPathExist = doesFileExist MapPath
							
							if  MapPathExist == true
							then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[i] + " =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
							else ()
						)
				)				
				else 	
				(		
					FnResize()
					MapPathExist = doesFileExist MapPath
					if  MapPathExist == true
					then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[i] + " =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
					else ()
				)					
			)	
				
		if classof VrayMaterialMaps[VrayMapIndex] == CompositeTexturemap
		then
		(
			for i  = 1 to VrayMaterialMaps[VrayMapIndex].mapList.count do
			(
				if classof VrayMaterialMaps[VrayMapIndex].mapList[i] == Bitmaptexture
				then
				(		
					CurrentMapPath = VrayMaterialMaps[VrayMapIndex].mapList[i].filename --  "U:\FolderName\Map.jpg"
					CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
					NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
					CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
					CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
					FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
					NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
					FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last fold

					if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
					then 
					(
						for i = 1 to CurrentMapDirPath.count do 
						(
							CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
							CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
							if CharAt == "\\" 
							then exit				
						)
						
						CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
						MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName			
						MapPathExist = doesFileExist MapPath
							
						if  MapPathExist == true
						then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) + "] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else 
						(
							CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
							FnResize()
								
							MapPathExist = doesFileExist MapPath	
								
							if  MapPathExist == true
							then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) +"] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
							else ()
						)
					)				
					else 	
					(		
						FnResize()
						MapPathExist = doesFileExist MapPath
						if  MapPathExist == true
						then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) + "] =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else ()
					)					
				)
					
				if classof VrayMaterialMaps[VrayMapIndex].mapList[i] == Color_Correction
				then
				(		
					CurrentMapPath = VrayMaterialMaps[VrayMapIndex].mapList[i].map.filename --  "U:\FolderName\Map.jpg"
					CurrentMapDirPath = getFilenamePath CurrentMapPath  --  "U:\FolderName\"
					NumberOfCharInDirPath = CurrentMapDirPath.count -- Number of characters in the path
					CurrentMapDirPath = substring CurrentMapDirPath 1 (NumberOfCharInDirPath - 1) -- Remove the last "\" in the past	
					CurrentMapFileName = filenameFromPath CurrentMapPath --  "Map.extension"
					FolderNameInAnArray = filterString CurrentMapDirPath "\\" -- Remove all "\" in the path and put all items in an array
					NumberOfFolderInPath = FolderNameInAnArray.count -- Return the number of items in an array
					FolderAt = FolderNameInAnArray[NumberOfFolderInPath] -- Return the name of the last folde
						
					if FolderAt == "FUL" or FolderAt == "MED" or FolderAt == "SMA" 
					then 
					(
						for i = 1 to CurrentMapDirPath.count do 
						(
							CharIndex = (NumberOfCharInDirPath + 1) - i -- Reverse Loop + Return a Number
							CharAt = CurrentMapDirPath[CharIndex] -- Return a Character
							if CharAt == "\\" 
							then exit		
						)
						
						CurrentMapDirPath = substring CurrentMapDirPath 1 CharIndex -- Remove the last 3 digits
						MapPath = CurrentMapDirPath + FolderName + "\\" + CurrentMapFileName
						MapPathExist = doesFileExist MapPath
							
						if  MapPathExist == true
						then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) + "].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else 
							(
								CurrentMapPath = CurrentMapDirPath + CurrentMapFileName
								FnResize()
								MapPathExist = doesFileExist MapPath	
								
								if  MapPathExist == true
								then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) +"].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
								else ()
							)
					)				
					else 	
					(		
						FnResize()
						MapPathExist = doesFileExist MapPath
						if  MapPathExist == true
						then(execute (ActiveMaterialTypeValue + "." + VrayMaterialMapsIndex[VrayMapIndex] + ".mapList[" + (i as string) + "].map =  Bitmaptexture fileName:"+ "\"" + MapPath + "\""))
						else ()
					)					
				)	
			)	
		)
	)
)

rollout TextureResizerModule ("Texture Resizer")
(
	groupBox PickAShaderGrpBox "Pick A Shader" width:160 height:40 offset:[-10,-5]
	materialbutton ByShaderSelectionButton "- None -" width:130 height:20 offset:[-12,-30]  tooltip:"Select a shader for resize his bitmap(s)."
	 on ByShaderSelectionButton picked MtlSelection do
	(	
		ByShaderSelectionButton.text = ((ByShaderSelectionButton.material) as string)
		MatEditor.Close()
		MatEditor.Open()
		medit.PutMtlToMtlEditor MtlSelection 1
		medit.SetActiveMtlSlot 1 true
	)
	
	button ByShaderSelectionButtonClear "X" width:20 height:20 offset:[66,-25] tooltip:"Clear node selection."
	on ByShaderSelectionButtonClear pressed do 
	(
		ByShaderSelectionButton.text = "- None -"
		clearNodeSelection()
	)

	groupBox PickAnObjectGrpBox "Pick An Object" width:160 height:40 offset:[-10,1]
	pickbutton ByObjectSelectionButton "- None -" width:130 height:20 offset:[-12,-30] tooltip:"Select an object for resize his shader bitmap(s)."
	 on ByObjectSelectionButton picked ObjectSelection do
	(
		ByObjectSelectionButton.text = ((ObjectSelection.name) as string)
		SelectMaterial = ObjectSelection.material

		if SelectMaterial != undefined 
		then 
		(	
			MatEditor.Close()
			MatEditor.Open()
			medit.PutMtlToMtlEditor SelectMaterial 1
			medit.SetActiveMtlSlot 1 true
		)			
		else (messageBox(  "No material assigned to " + ((ObjectSelection.name) as string) +".") title:"Texture Resizer"
		SelectMaterial = undefined 
		ByObjectSelectionButton.text = "- None -"
		)
	)
			
	button ByObjectSelectionButtonClear "X" width:20 height:20 align:#center offset:[66,-25] tooltip:"Clear node selection."
	on ByObjectSelectionButtonClear pressed do 
	(
		ByObjectSelectionButton.text = "- None -"
		clearNodeSelection()
	)
	
	groupBox SelectMapSizeGrpBox "Select Map(s) Size" width:160 height:85 offset:[-10,1]
	button MakeItFull "Full" width:151 height:20 tooltip:"Set/Copy selected shader bitmap(s) to their original size." offset:[0,-74]
	button MakeItMedium "Medium" width:151 height:20 tooltip:"Set/Resize selected shader bitmap(s) to half of their original size." offset:[0,-3]
	button MakeItSmall "Small" width:151 height:20 tooltip:"Set/Resize selected shader bitmap(s) to quarter of their original size." offset:[0,-3]
	

	on MakeItFull pressed do 
	(
		FolderName = "FUL"
		NewMapSize = 100
		if classof meditMaterials[activeMeditSlot] ==  VRayMtl or classof meditMaterials[activeMeditSlot] == VRayBlendMtl \
			or classof meditMaterials[activeMeditSlot] == Standardmaterial or classof meditMaterials[activeMeditSlot] == Multimaterial
		then 
		(
			FnStdMtl()
			FnVrayMtl()
			FnVrayBlendMtl()
			FnMultiSub()
		)
		else (messageBox("Incompatible shader.\nWorks only with VrayMtl, VrayMtlBlend, MultiSubObject, StandardMaterial and a CompositeTextureMap.")title:"Texture Resizer")
	)
	
	on MakeItMedium pressed do 
	(
		FolderName = "MED"
		NewMapSize = 50
		if classof meditMaterials[activeMeditSlot] ==  VRayMtl or classof meditMaterials[activeMeditSlot] == VRayBlendMtl \
			or classof meditMaterials[activeMeditSlot] == Standardmaterial or classof meditMaterials[activeMeditSlot] == Multimaterial
		then 
			(
				FnStdMtl()
				FnVrayMtl()
				FnVrayBlendMtl()
				FnMultiSub()
			)
		else (messageBox("Incompatible shader.\nWorks only with VrayMtl, VrayMtlBlend, MultiSubObject, StandardMaterial and a CompositeTextureMap.")title:"Texture Resizer")
	)
	
	on MakeItSmall pressed do 
	(
		FolderName = "SMA"
		NewMapSize = 25
		if classof meditMaterials[activeMeditSlot] ==  VRayMtl or classof meditMaterials[activeMeditSlot] == VRayBlendMtl \
			or classof meditMaterials[activeMeditSlot] == Standardmaterial or classof meditMaterials[activeMeditSlot] == Multimaterial
		then 
			(
				FnStdMtl()
				FnVrayMtl()
				FnVrayBlendMtl()
				FnMultiSub()
			)
		else (messageBox("Incompatible shader.\nWorks only with VrayMtl, VrayMtlBlend, MultiSubObject, StandardMaterial and a CompositeTextureMap.")title:"Texture Resizer") 
	)

	on EditTextPath changed text do EditTextPathValue = EditTextPath.text
		
	on GetPathButton pressed do 
	(
		CurrentMapDirPath = getOpenFileName()
		if CurrentMapDirPath == undefined 
		then
		(
			EditTextPath.text= ""
			EditTextPathValue = ""
		)
		else 
		(
			EditTextPath.text = CurrentMapDirPath
			ditTextPathValue = CurrentMapDirPath
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout TextureResizerModule
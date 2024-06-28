/*
#NAME:Substance Material Maker
#VERSION:1.0
#INSTRUCTIONS:Pick an object, select a folder path and click "Create Material"
#SOURCE:Aaron Dabelow, Felix Eyal
#HISTORY:06.27.2024 >> Been Born
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Created by Felix Eyal with the help of Aaron Dabelow
--*****************************************************
SubstanceMaterialModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout SubstanceMaterialModule)catch()

-- creates the UI

rollout SubstanceMaterialModule ("Substance Material " + (SubstanceMaterialModuleVer as string))
	

(
	
-- UI Button List
button filebtn "Pick a Folder" width:160 height:30
label dscTxt "Or enter a file path:" align:#center
edittext filepath width:150 align:#center offset:[0,0] 
checkbox chkDis "Displacement Map" align:#center
checkbox modDis "Displacement as Modifier" align:#center enabled:false
button makeMat "Create Substance Material" width:160 height:30 offset:[-10,2]
label gapTxt " " offset:[0,-10]
		
							-- Function List --
	
-- Function to choose a folder and attach the files to a Material Location. --

fn LinkFileToBitmap = 
(
    -- Get a list of files in the selected directory
    files = getFiles (dirPath + "\\*.*")
    
	for file in files do
	(
		fileName = getFileNameFile file -- Extracts just the file name without path

		-- Check different patterns and assign textures accordingly
		
		if matchPattern fileName pattern:"*Diffuse*" then
		(
			vrayMat.diffuseMap = vraybitmap filename:file name:"Diffuse_MAP"
			print ("Attached Diffuse map: " + file)
		)
		if matchPattern fileName pattern:"*Reflection*" then
		(
			vrayMat.reflectionMap = vraybitmap filename:file name:"Reflection_MAP"
			print ("Attached Reflection map: " + file)
		)
		if matchPattern fileName pattern:"*Normal*" then
		(
			vrayMat.bumpMap = VRayNormalMap name:"Bump_MAP"
			vrayMat.bumpMap.normalMap = vraybitmap filename:file name:"Normal_MAP"
			vrayMat.texmap_bump_multiplier = 100
			print ("Attached Normal map: " + file)
		)
		if matchPattern fileName pattern:"*Height*" then
		(
			if chkDis.state then
			(
				if modDis.state == true then
				(
					if ( superClassOf $ ) == GeometryClass then
					(
						addModifier $ (VRayDisplacementMod())
						$.modifiers[#VrayDisplacementMod].texmap = vraybitmap filename:file name:"Modifier_Height_MAP"
					)
					else
					(
						messageBox "No Selected Objects"
					)
				)
				else
				(
					vrayMat.displacementMap = vraybitmap filename:file name:"Height_MAP"
					print ("Attached Displacement map: " + file)
				)
			)
		)
		if matchPattern fileName pattern:"*Glossiness*" then
		(
			vrayMat.Reflectionglossinessmap = vraybitmap filename:file name:"Reflection_MAP"
			print ("Attached Glossiness map: " + file)
		)
		if matchPattern fileName pattern:"*IOR*" then
		(
			vrayMat.fresnelIORMap = vraybitmap filename:file name:"IOR_MAP"
			vrayMat.reflection_lockIOR = off
			print ("Attached Glossiness map: " + file)
		)
		else
		(
			print "No matching file name found"
		)
	)
)

-- Create a new Vray Material for the Object Selected --

fn CreateVrayMAT =
(
	if ( superClassOf $ ) == GeometryClass then
	(
		selObj = $ 
		objName = selObj.name
		global vrayMat = vrayMtl name:(objName + "_MAT")

		selObj.material = vrayMat
		meditMaterials[1] = vrayMat
	)
	else
	(
		global vrayMat = vrayMtl name:"Sub_MAT"
		meditMaterials[1] = vrayMat
	)
)
	
-- Button Actions List --

-- Get File Path Button

on filebtn pressed do
(
	dirPath = getSavePath caption:"Choose a directory folder"
	if dirPath != undefined then
	filepath.text = dirPath
)

-- Create Substance Material Button

on makeMat pressed do
(
	CreateVrayMAT()
	if classof vrayMat == vrayMtl then
	(
		LinkFileToBitmap()
	)
	else
	(
		print "Error with Linking Maps"
	)
)

on chkDis changed state do
	(
		modDis.enabled = if state then True else False
	)
)
AddSubRollout MakeToolbox.theSubrollout SubstanceMaterialModule
/*
#NAME: MultiSub Material Creator
#VERSION:1.0
#SOURCE:David Almeida, david.almeida@makevisual.com
#HISTORY:03.03.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by David Almeida
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.03.2025 >> Start Development
--*****************************************************
MultiSubCreatorToolModule = "0.1"
try(removeSubRollout MakeToolbox.theSubrollout MultiSubCreator)catch()

-- creates the UI
rollout MultiSubCreator ("MultiSub Mat Creator " + (MultiSubCreatorToolModule as string))
(
	local
	SelectedObjs = #(),
	TempMultiSubMaterial = undefined,
	TheMultiSubMaterial = undefined,
	MatCounter = 0,
	ModSwitcher = false,
	MaterialList = #(),
	MaterialIDList = #(),
	DCMatIDArray = #()
	edittext MltSubMatNameText "Material Name:" text:("Mat_" + (substring maxFileName 1 (maxFileName.count - 4))) height:20 fieldWidth:160 labelOnTop:true pos:[2,5] multiLine:true enabled:true
	radiobuttons MltSubMatRadioButtons labels:#("Create new MultiSub","Use selected MultiSub") offsets:#([0,0], [0,5])
	button MltSubMatGetMatButton "Get selected MultiSub" width:140 enabled:false pos:[2,88] tooltip:"On Slate Material Editor, select a MultiSub\nmaterial and click this button." across:2
	button MltSubMatClearMatButton "X" width:21 height:21 enabled:false pos:[141,88] tooltip:"Reset selected material"
	button MltSubMatCreatorButton "Combine MultiSub Material" pos:[2,115] width:160
	Label MltSubMatObjectLabel "--"
	label MltSubMatMatsLabel "--"
	function MaterialListUpdater mtl =
	(
		if (appendIfUnique MaterialList mtl) then
		(
			MatCounter += 1
			append MaterialIDList MatCounter
			TheMultiSubMaterial.MaterialList[MatCounter] = undefined
			TheMultiSubMaterial[MatCounter] = mtl
		)
	)
	function ConfigDataChannel Nd Mod Indx =
	(
		DCMatIDArray = #()
		Max Modify Mode
		select Nd
		modPanel.setCurrentObject Nd.datachannel
		Mod.addOperator 38019502L 0L -1
		Mod[1].input = 1
		Mod.addOperator 3180516783L 0L -1
		Mod[2].outputElementType = 2
		Mod[2].outputDataType  = 4
		Mod.addOperator 52689454L 0L -1
		Mod[3].output = 1
		Mod.operator_enabled = #(true, false, true)
		for j = 1 to (getNumFaces Nd) do
		(
			CurrentMatID = polyop.getFaceMatID Nd j
			if Nd.material[CurrentMatID] != undefined then
			(
				MaterialListUpdater Nd.material[CurrentMatID]
				append DCMatIDArray (findItem MaterialList Nd.material[CurrentMatID])
			)
			else
			(
				append DCMatIDArray 1
			)
		)
		DCScript = "on Process theNode theMesh inputElementType inputIndexChannel inputDataType inputData outputElementType outputIndexChannel outputDataType outputArray theTime do
		(
		    if theMesh == undefined then return 0
		    nf = polyop.getNumFaces theMesh
		    if inputElementType == 3 do
		    (		    
		    	TempArray = 
		        for i = 1 to nf do (outputArray[i] = TempArray[i] - 1)
		        return 1
		    )
		    return 0
		)
		"
		DCScript = (substring DCScript 1 314) + (with printAllElements on (DCMatIDArray as string)) + (substring DCScript 315 392)
		Mod[2].script = DCScript
		Mod.operator_enabled = #(true, true, true)
	)
	function SmoothModsSwitcher Nd =
	(
		for o in Nd.modifiers do
		(
			ClassofMod = (classof o)
			if (ClassofMod == TurboSmooth) OR (ClassofMod == subdivide) OR (ClassofMod == meshsmooth) OR (ClassofMod == OpenSubdiv) do
			(
				ModSwitcher = NOT ModSwitcher
				o.enabled = NOT o.enabled
			)
		)
	)
	function PrimMeshMatID Nd =
	(
		MatIDDataChannel = (DataChannelModifier())
		MatIDDataChannel.display = false
		if Nd.modifiers.count == 0 then
		(
			addModifier Nd MatIDDataChannel
			ConfigDataChannel Nd MatIDDataChannel 1
		)
		else
		(
			ModSwitcher = false
			SmoothModsSwitcher Nd
			LastModIndex = 0
			for k = Nd.modifiers.count to 1 by -1 do
			(
				ClassofMod = (classof Nd.modifiers[k])
				if (ClassofMod == TurboSmooth) OR (ClassofMod == subdivide) OR (ClassofMod == meshsmooth) OR (ClassofMod == OpenSubdiv) do
				(
					LastModIndex = k
				)
			)
			addModifier Nd MatIDDataChannel before:LastModIndex
			ConfigDataChannel Nd MatIDDataChannel (LastModIndex + 1)
			SmoothModsSwitcher Nd
		)
	)
	function PolyMeshMatID Nd =
	(
		for j = 1 to (getNumFaces Nd) do
		(
			CurrentMatID = polyop.getFaceMatID Nd j
			MaterialListUpdater Nd.material[CurrentMatID]
			polyop.setFaceMatID Nd j (findItem MaterialList Nd.material[CurrentMatID])
		)
	)
	function MeshMatID Nd =
	(
		for j = 1 to (getNumFaces Nd) do
		(
			CurrentMatID = meshop.getFaceMatID Nd j
			MaterialListUpdater Nd.material[CurrentMatID]
			meshop.setFaceMatID Nd j (findItem MaterialList Nd.material[CurrentMatID])
		)
	)
	function SingleMatObjects Nd NdMat =
	(
		MaterialListUpdater NdMat

		if Nd.modifiers.count == 0 then
		(
			addModifier Nd (Materialmodifier name:"MultiMatIDSet" Material_ID:(findItem MaterialList Nd.material))
		)
		else
		(
			LastModIndex = 0
			for k = Nd.modifiers.count to 1 by -1 do
			(
				ClassofMod = (classof Nd.modifiers[k])
				if (ClassofMod == TurboSmooth) OR (ClassofMod == subdivide) OR (ClassofMod == meshsmooth) OR (ClassofMod == OpenSubdiv) do
				(
					LastModIndex = k
				)
			)
			addModifier Nd (Materialmodifier name:"MultiMatIDSet" Material_ID:(findItem MaterialList Nd.material)) before:LastModIndex
		)
	)
	function MultiSubCreatorFunction =
	(
		t0 = timestamp()
		--try
		(
			if MltSubMatRadioButtons.state == 1 then
			(
				TheMultiSubMaterial = multimaterial numsubs:0 name:MltSubMatNameText.text
				MatCounter = 0
				MaterialList = #()
				MaterialIDList = #()
			)
			else
			(
				MatCounter = TheMultiSubMaterial.materiallist.count
				MaterialList = TheMultiSubMaterial.MaterialList
			)
			if selection.count > 0 then
			(
				SelectedObjs = selection as array
				for i in SelectedObjs do
				(
					if i.material != undefined do
					(
						if (classof i.material) == multimaterial then
						(
							if i.material != TheMultiSubMaterial then
							(
								if ((classof i.baseobject) == Editable_Poly) OR ((classof i.baseobject) == Editable_mesh) then
								(
									if i.modifiers.count > 0 do
									(
										ModSwitcher = false
										SmoothModsSwitcher i
									)
									case (classof i) of
									(
										(Editable_Poly):
										(
											PolyMeshMatID i
										)
										(PolyMeshObject):
										(
											PolyMeshMatID i
										)
										(Editable_mesh):
										(
											MeshMatID i
										)
										default:
										(
											print "The following object material cannot be automatically combined"
											print i.name
										)
									)
									if ModSwitcher do
									(
										SmoothModsSwitcher i
									)
									i.material = TheMultiSubMaterial
								)
								else
								(	
									PrimMeshMatID i
									i.material = TheMultiSubMaterial
								)
							)
							else
							(
								print "The Same Material was already added"
							)
						)
						else
						(
							SingleMatObjects i i.material
							i.material = TheMultiSubMaterial
						)
					)
				)
				if SME.activeView == 0 do
				(
					sme.Open()
				)
				node_view = SME.getView SME.activeView
				node_view.CreateNode TheMultiSubMaterial [0, 0]
			)
			else
			(
				messagebox "Select 1 or more objects"
			)
		)
		--catch
		(
			--catches any errors
		--	messagebox "Unexpected error, please try again."
		)
		t1 = timestamp()
		print (t1 - t0)
	)
	on MltSubMatCreatorButton pressed do
	(
		undo "MultiSub Material Creator" on
		(
			MultiSubCreatorFunction()
		)
	)
	on MltSubMatRadioButtons changed state do
	(
		if state == 1 then
		(
			MltSubMatNameText.enabled = true
			MltSubMatGetMatButton.enabled = false
			MltSubMatClearMatButton.enabled = false
			MltSubMatCreatorButton.enabled = true
			TheMultiSubMaterial = undefined
		)
		else
		(
			MltSubMatNameText.enabled = false
			MltSubMatGetMatButton.enabled = true
			MltSubMatClearMatButton.enabled = true
			TheMultiSubMaterial = TempMultiSubMaterial
			if TempMultiSubMaterial == undefined then
			(
				MltSubMatCreatorButton.enabled = false
			)
		)
	)
	on MltSubMatGetMatButton pressed do
	(
		if ((sme.GetView (sme.activeView)) == undefined) OR (sme.IsOpen() == false) then
		(
			messageBox "Open Slate Material Editor and select a MultiSub Material"
		)
		else
		(
			if ((sme.GetView (sme.activeView)).getSelectedNodes()).count == 1 AND (classof ((sme.GetView (sme.activeView)).getSelectedNodes())[1].reference) == Multimaterial then
			(
				TempMultiSubMaterial = TheMultiSubMaterial = ((sme.GetView (sme.activeView)).getSelectedNodes())[1].reference
				MltSubMatGetMatButton.text = TheMultiSubMaterial.name
				MltSubMatCreatorButton.enabled = true
			)
			else
			(
				messageBox "Select 1 MultiSub Material"
			)
		)
	)
	on MltSubMatClearMatButton pressed do
	(
		TempMultiSubMaterial = TheMultiSubMaterial = undefined
		MltSubMatCreatorButton.enabled = false
		MltSubMatGetMatButton.text = "Get selected MultiSub"
	)
)

AddSubRollout MakeToolbox.theSubrollout MultiSubCreator
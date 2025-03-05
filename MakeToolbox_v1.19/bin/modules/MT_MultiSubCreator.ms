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
	TempMultiSubMaterial = undefined,
	TheMultiSubMaterial = undefined,
	MatCounter = 0,
	ModSwitcher = false,
	MaterialList = #(),
	MaterialIDList = #()
	edittext MltSubMatNameText "Material Name:" text:("Mat_" + (substring maxFileName 1 (maxFileName.count - 4))) height:20 fieldWidth:160 labelOnTop:true pos:[2,5] multiLine:true enabled:true
	radiobuttons MltSubMatRadioButtons labels:#("Create new MultiSub","Use selected MultiSub") offsets:#([0,0], [0,5])
	button MltSubMatGetMatButton "Get selected MultiSub" width:160 enabled:false tooltip:"On Slate Material Editor, select a MultiSub\nmaterial and click this button.\nRight-click to reset."
	button MltSubMatCreatorButton "Combine MultiSub Material" pos:[2,115] width:160
	Label MltSubMatObjectLabel "--"
	label MltSubMatMatsLabel "--"
	function PolyMeshMatID Nd =
	(
		for j = 1 to (getNumFaces Nd) do
		(
			CurrentMatID = polyop.getFaceMatID  Nd j
			if (appendIfUnique MaterialList Nd.material[CurrentMatID]) then
			(
				MatCounter += 1
				append MaterialIDList MatCounter
				TheMultiSubMaterial.MaterialList[MatCounter] = undefined
				TheMultiSubMaterial[MatCounter] = Nd.material[CurrentMatID]
			)
			polyop.setFaceMatID Nd j (findItem MaterialList Nd.material[CurrentMatID])
		)
	)
	function MeshMatID Nd =
	(
		for j = 1 to (getNumFaces Nd) do
		(
			CurrentMatID = meshop.getFaceMatID Nd j
			if (appendIfUnique MaterialList Nd.material[CurrentMatID]) then
			(
				MatCounter += 1
				append MaterialIDList MatCounter
				TheMultiSubMaterial.MaterialList[MatCounter] = undefined
				TheMultiSubMaterial[MatCounter] = Nd.material[CurrentMatID]
			)
			meshop.setFaceMatID Nd j (findItem MaterialList Nd.material[CurrentMatID])
		)
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
	function SingleMatObjects Nd NdMat =
	(
		if (appendIfUnique MaterialList NdMat) do
		(
			MatCounter += 1
			append MaterialIDList MatCounter
			TheMultiSubMaterial.MaterialList[MatCounter] = undefined
			TheMultiSubMaterial[MatCounter] = NdMat
		)
		if Nd.modifiers.count == 0 then
		(
			addModifier Nd (Materialmodifier name:"MultiMatIDSet" Material_ID:MatCounter)
		)
		else
		(
			LastModIndex = 0
			for k = Nd.modifiers.count to 1 by -1 do
			(
				ClassofMod = (classof Nd.modifiers[k])
				NameofMod = Nd.modifiers[k].name
				if (ClassofMod == Materialmodifier) AND (NameofMod == "MultiMatIDSet") do
				(
					deleteModifier Nd k
				)
				if (ClassofMod == TurboSmooth) OR (ClassofMod == subdivide) OR (ClassofMod == meshsmooth) OR (ClassofMod == OpenSubdiv) do
				(
					LastModIndex = k
				)
			)
			addModifier Nd (Materialmodifier name:"MultiMatIDSet" Material_ID:MatCounter) before:LastModIndex
		)
		Nd.material = TheMultiSubMaterial
	)
	function MultiSubCreatorFunction =
	(
		t0 = timestamp()
		undo "MultiSub Material Creator" on
		(
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
					for i in selection do
					(
						if i.material != undefined do
						(
							if (classof i.material) == multimaterial then
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
									if i.modifiers.count > 0 then
									(
										MatIndex = 1
										for n = i.modifiers.count to 1 by -1 do
										(
											ClassofMod = (classof i.modifiers[n])
											if (ClassofMod == Materialmodifier) do
											(
												MatIndex = i.modifiers[n].Material_ID
												print MatIndex
											)
										)
										SingleMatObjects i i.material[MatIndex]
									)
									else
									(
										SingleMatObjects i i.material.MaterialList[1]
									)
								)
							)
							else
							(
								SingleMatObjects i i.material
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
		)
		t1 = timestamp()
		print (t1 - t0)
	)
	on MltSubMatCreatorButton pressed do
	(
		MultiSubCreatorFunction()
	)
	on MltSubMatRadioButtons changed state do
	(
		if state == 1 then
		(
			MltSubMatNameText.enabled = true
			MltSubMatGetMatButton.enabled = false
			MltSubMatCreatorButton.enabled = true
			TheMultiSubMaterial = undefined
		)
		else
		(
			MltSubMatNameText.enabled = false
			MltSubMatGetMatButton.enabled = true
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
				print TheMultiSubMaterial.materiallist.count
			)
			else
			(
				messageBox "Select 1 MultiSub Material"
			)
		)
	)
	on MltSubMatGetMatButton rightclick do
	(
		TempMultiSubMaterial = TheMultiSubMaterial = undefined
		MltSubMatCreatorButton.enabled = false
		MltSubMatGetMatButton.text = "Get selected MultiSub"
	)
)

AddSubRollout MakeToolbox.theSubrollout MultiSubCreator
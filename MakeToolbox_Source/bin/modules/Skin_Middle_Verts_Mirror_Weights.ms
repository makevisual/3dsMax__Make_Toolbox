(
	local
	BonePairsArray = #(),
	SkinModifier = $.modifiers[1]
	SkinModifier.filter_vertices = true
	VertsArray = skinOps.getSelectedVertices SkinModifier node:$
	for i in VertsArray do
	(
		skinOps.unNormalizeVertex SkinModifier i true
		BoneCount = (skinOps.GetVertexWeightCount SkinModifier i)
		for j = 1 to BoneCount do
		(
			CurrentBoneID = skinOps.GetVertexWeightBoneID SkinModifier i j
			CurrentBone = getNodeByName (skinOps.GetBoneName SkinModifier CurrentBoneID 0)
			at time 0
			(
				CurrentBonePosX = CurrentBone.transform.position.x
			)
			for k = 1 to BoneCount do
			(
				TargetBoneID = skinOps.GetVertexWeightBoneID SkinModifier i k
				if CurrentBoneID != TargetBoneID do
				(
					TargetBone = getNodeByName (skinOps.GetBoneName SkinModifier TargetBoneID 0)
					at time 0
					(
						TargetBonePosX = TargetBone.transform.position.x
					)
					if (close_enough CurrentBonePosX -TargetBonePosX 10000) AND ((CurrentBonePosX > 0.01) OR (CurrentBonePosX < -0.01))do
					(
						NewWeight = (skinOps.GetVertexWeight SkinModifier i k)
						skinOps.SetVertexWeights SkinModifier i CurrentBoneID NewWeight node:$
					)
				)
			)
		)
		skinOps.unNormalizeVertex SkinModifier i false
	)
)
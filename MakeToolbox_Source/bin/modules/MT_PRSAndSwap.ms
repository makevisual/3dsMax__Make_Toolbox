/*
--**********************************************************************************--
--                                                                                  --
--                                   PRS SWAP                                     	--
--                                                                                  --
--**********************************************************************************--

#NAME: PRS Swap
#VERSION: 0.1
#LAST UPDATED: 2025.02.20

#DESCRIPTION:
A utility to swap the Position, Rotation, and Scale transforms between two 
selected objects. The user can choose which specific axes to swap for each 
transform type.

#INSTRUCTIONS:
Select exactly two objects. Use the checkboxes to specify which transform axes 
(Position, Rotation, Scale) you want to swap. Click the "Transform and Swap" 
button to apply the changes.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_PRS_and_Swap

#CREDITS:
    #Author: David Almeida (davidcalmeida@gmail.com)

#HISTORY:
    - v0.1 (2025.02.20): Initial release and integration into MakeToolbox.

--**********************************************************************************--
*/
prsswapToolModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout prsswapToolModule)catch()

-- creates the UI
rollout prsswapToolModule ("PRS_Swap Tool " + (prsswapToolModuleVer as string))
(
	group "Position"
	(
		checkbox xPos "X" checked:true across:3
		checkbox yPos "Y" checked:true
		checkbox zPos "Z" checked:true
	)
	group "Rotation"
	(
		checkbox xRot "X" checked:true across:3
		checkbox yRot "Y" checked:true
		checkbox zRot "Z" checked:true
	)
	group "Scale"
	(
		checkbox xScl "X" checked:true across:3
		checkbox yScl "Y" checked:true
		checkbox zScl "Z" checked:true
	)
	button PRSSwapButton "Transform and Swap" pos:[2,145] width:160 tooltip:"Swaps the transforms between 2 objects" align:#left
-- function for PRS Abstraction Layer Matrix (PALM)
	function PRS_Mtrx val =
	(
		if val then
		(
			1
		)
		else
		(
			0
		)
	)

-- function for Swapping objects transforms
	function PRSSwapFunction = 
	(
		undo on
		(
			try
			(
				if selection.count == 2 then 
				(
					-- Stores the original transforms of the two objects
					Obj1Trns = $[1].transform
					Obj2Trns = $[2].transform
					-- Creates the PRS Abstraction Matrix, which stores which PRS axis were selected by the user to be swapped between objects
					PRSAbstractionMatrix = #([(PRS_Mtrx xPos.checked), (PRS_Mtrx yPos.checked), (PRS_Mtrx zPos.checked)],
					[(PRS_Mtrx xRot.checked), (PRS_Mtrx yRot.checked), (PRS_Mtrx zRot.checked)],
					[(PRS_Mtrx xScl.checked), (PRS_Mtrx yScl.checked), (PRS_Mtrx zScl.checked)])
					-- Calculates the new Translation Matrix for each object using the PALM translation vector as weighting
					Obj1NewPos = transMatrix (Obj2Trns[4]*PRSAbstractionMatrix[1] + Obj1Trns[4]*([1, 1, 1] - PRSAbstractionMatrix[1]))
					Obj2NewPos = transMatrix (Obj1Trns[4]*PRSAbstractionMatrix[1] + Obj2Trns[4]*([1, 1, 1] - PRSAbstractionMatrix[1]))
					-- Calculates the new Rotation Matrix for each object using the PALM rotation vector length to determine which axis were selected and
					-- perform the appropriate transformations
					-- If the length of the PALM rotation vector is greater than 1, it means at least rotation axis were selected. If this is the case
					-- then all the rotations must be exchanged between the objects since it would follow the last axis would inevitably need to be aligned
					-- to keep the transform matrix orthogonal
					if length PRSAbstractionMatrix[2] > 1 then
					(
						Obj1NewRot = (matrix3 (normalize Obj2Trns[1]) (normalize Obj2Trns[2]) (normalize Obj2Trns[3]) [0,0,0])
						Obj2NewRot = (matrix3 (normalize Obj1Trns[1]) (normalize Obj1Trns[2]) (normalize Obj1Trns[3]) [0,0,0])
					)
					else
					(
						-- If the length of the PALM rotation vector is 0, it means not axis are selected, and the objects must retain their original
						-- rotation matrices
						if length PRSAbstractionMatrix[2] == 0 then
						(
							Obj1NewRot = (matrix3 (normalize Obj1Trns[1]) (normalize Obj1Trns[2]) (normalize Obj1Trns[3]) [0,0,0])
							Obj2NewRot = (matrix3 (normalize Obj2Trns[1]) (normalize Obj2Trns[2]) (normalize Obj2Trns[3]) [0,0,0])
						)
						else
						(
							case of
							(
								-- If rotation vector X component is selected, it follows we must exchange the objects' X vector alignment
								-- this is the same routine used in Max's native align object (ALT+A) tool
								(PRSAbstractionMatrix[2][1] == 1):
								(
									-- Swaps and aligns the X Vector of the objects and recalculates the other vectors (Y and Z) to ensure orthogonal matrices
									Obj1NewXVec = normalize Obj2Trns[1]
									Obj1NewZVec = normalize (cross Obj1NewXVec Obj1Trns[2])
									Obj1NewYVec = normalize (cross Obj1NewZVec Obj1NewXVec)
									Obj2NewXVec = normalize Obj1Trns[1]
									Obj2NewZVec = normalize (cross Obj2NewXVec Obj2Trns[2])
									Obj2NewYVec = normalize (cross Obj2NewZVec Obj2NewXVec)
									Obj1NewRot = (matrix3 Obj1NewXVec Obj1NewYVec Obj1NewZVec [0,0,0])
									Obj2NewRot = (matrix3 Obj2NewXVec Obj2NewYVec Obj2NewZVec [0,0,0])
								)
								-- If rotation vector Y component is selected, it follows we must exchange the objects' Y vector alignment
								(PRSAbstractionMatrix[2][2] == 1):
								(
									-- Swaps and aligns the Y Vector of the objects and recalculates the other vectors (X and Z) to ensure orthogonal matrices
									Obj1NewYVec = normalize Obj2Trns[2]
									Obj1NewXVec = normalize (cross Obj1NewYVec Obj1Trns[3])
									Obj1NewZVec = normalize (cross Obj1NewXVec Obj1NewYVec)
									Obj2NewYVec = normalize Obj1Trns[2]
									Obj2NewXVec = normalize (cross Obj2NewYVec Obj2Trns[3])
									Obj2NewZVec = normalize (cross Obj2NewXVec Obj2NewYVec)
									Obj1NewRot = (matrix3 Obj1NewXVec Obj1NewYVec Obj1NewZVec [0,0,0])
									Obj2NewRot = (matrix3 Obj2NewXVec Obj2NewYVec Obj2NewZVec [0,0,0])
								)
								-- If rotation vector Z component is selected, it follows we must exchange the objects' Z vector alignment
								(PRSAbstractionMatrix[2][3] == 1):
								(
									-- Swaps and aligns the Z Vector of the objects and recalculates the other vectors (X and Y) to ensure orthogonal matrices
									Obj1NewZVec = normalize Obj2Trns[3]
									Obj1NewYVec = normalize (cross Obj1NewZVec Obj1Trns[1])
									Obj1NewXVec = normalize (cross Obj1NewYVec Obj1NewZVec)
									Obj2NewZVec = normalize Obj1Trns[3]
									Obj2NewYVec = normalize (cross Obj2NewZVec Obj2Trns[1])
									Obj2NewXVec = normalize (cross Obj2NewYVec Obj2NewZVec)
									Obj1NewRot = (matrix3 Obj1NewXVec Obj1NewYVec Obj1NewZVec [0,0,0])
									Obj2NewRot = (matrix3 Obj2NewXVec Obj2NewYVec Obj2NewZVec [0,0,0])
								)
							)
						)
					)
					-- Calculates the new Scale Matrix for each object using the PALM translation vector as weighting
					Obj1NewScl = scaleMatrix (Obj2Trns.scale*PRSAbstractionMatrix[3] + Obj1Trns.scale*([1, 1, 1] - PRSAbstractionMatrix[3]))
					Obj2NewScl = scaleMatrix (Obj1Trns.scale*PRSAbstractionMatrix[3] + Obj2Trns.scale*([1, 1, 1] - PRSAbstractionMatrix[3]))
					-- Creates the new Transform Matrices by multiplying the ScaleTM*RotationTM*TranslationTM
					Obj1NewTrns = Obj1NewScl*Obj1NewRot*Obj1NewPos
					Obj2NewTrns = Obj2NewScl*Obj2NewRot*Obj2NewPos
					-- Apply the transformations to the selected objects
					$[1].transform = Obj1NewTrns
					$[2].transform = Obj2NewTrns
				)

				else
				(
					messagebox ("You must select exactly two objects")
				)
			)
			catch
			(
				catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)
	
-- the button
on PRSSwapButton pressed do
	(
		PRSSwapFunction()
	)
)
AddSubRollout MakeToolbox.theSubrollout prsswapToolModule
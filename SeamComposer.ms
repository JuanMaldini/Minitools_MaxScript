macroScript SeamComposer category:"0_Minitools"
(
	global sc_selectedShape = undefined

	rollout SeamComposerRollout "Seam Composer" width:240 height:190
	(
		button btnPick "Pick Line/Shape" width:200 height:28
		label lblPicked "None selected" pos:[10,35] width:220

		label lblVar "Variation:" pos:[10,60] width:80
		radioButtons rbVariation labels:#("Variacion 1") columns:1 pos:[90,60] width:140 height:60 default:1

		button btnExec "Execute" pos:[10,130] width:220 height:32

		on btnPick pressed do
		(
			local obj = pickObject message:"Select a line/shape" filter:(fn f o = isKindOf o Shape)
			if obj != undefined then
			(
				sc_selectedShape = obj
				lblPicked.text = obj.name
			)
		)

		on btnExec pressed do
		(
			if sc_selectedShape == undefined do
			(
				messageBox "No line/shape selected."
				return()
			)

			-- Ensure the picked shape is the current selection
			select sc_selectedShape

				-- Flow from listener (with vertex break)
                modPanel.addModToSelection (Normalize_Spline2 ()) ui:on
                $.modifiers[#Normalize_Spline].length = 0.2
                $.modifiers[#Normalize_Spline].MaxKnots = 50000
                modPanel.addModToSelection (Edit_Spline ()) ui:on
                macros.run "Modifier Stack" "SubObject_1"
                actionMan.executeAction 0 "40021"  -- Selection: Select All
                macros.run "Editable Spline Object" "ESpline_Break"
                subobjectLevel = 0
                modPanel.setCurrentObject $.modifiers[#Edit_Spline]
                actionMan.executeAction 0 "50001"  -- Tools: Select and Move
                modPanel.addModToSelection (sweep ()) ui:on
                $.modifiers[#Sweep].CurrentBuiltInShape = 4
                $.modifiers[#Sweep][#Cylinder_Section].radius = 0.05
                $.modifiers[#Sweep].PivotAlignment = -1
                modPanel.addModToSelection (tessellate ()) ui:on
                $.modifiers[#Tessellate].faceType = 1
                $.modifiers[#Tessellate].tension = 0
                modPanel.addModToSelection (TurboSmooth ()) ui:on
		)
	)

	createDialog SeamComposerRollout
)
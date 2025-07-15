macroScript CeilingGenerator
category:"Minitools"
buttonText:"Ceiling Gen"
toolTip:"C Gen"
(
	rollout ceilingGenDialog "Ceiling gen"
	(
		local theSpline
		
		label lbl_params "Parameters:"
		checkBox chk_border "Border:" checked:false
		spinner spn_size "Size:" range:[0.0, 1000.0, 50.0] type:#worldUnits
		
		label lbl_sep "" -- Separador visual
		
		button btn_generate "Generate" width:180 align:#center
		
		on btn_generate pressed do
		(
			if selection.count == 1 and isKindOf selection[1] Shape then
			(
				-- Captura los valores de la interfaz al presionar el botón
				theSpline = selection[1]
				local border_value = chk_border.checked
				local size_value = spn_size.value
				
				-- Code and structure here actions
				modPanel.addModToSelection (Edit_Spline ()) ui:on
				modPanel.addModToSelection (Edit_Poly ()) ui:on
				modPanel.addModToSelection (Normalmodifier ()) ui:on
				modPanel.addModToSelection (FloorGenerator ()) ui:on

				actionMan.executeAction 0 "272"  -- Views: Wireframe / Smooth+Highlights Toggle

				$.modifiers[#FloorGenerator].length = size_value
				$.modifiers[#FloorGenerator].width = size_value
				$.modifiers[#FloorGenerator].GroutLength = 0
				$.modifiers[#FloorGenerator].MinRowOffset = 0
				$.modifiers[#FloorGenerator].DoExtrude = off
				$.modifiers[#FloorGenerator].DoBevel = off

				modPanel.addModToSelection (smooth ()) ui:on
				$.modifiers[#Smooth].autosmooth = off

				modPanel.addModToSelection (Uvwmap ()) ui:on
				$.modifiers[#UVW_Map].maptype = 4
				$.modifiers[#UVW_Map].realWorldMapSize = on
				$.modifiers[#UVW_Map].utile = 1
				$.modifiers[#UVW_Map].vtile = 1
				$.modifiers[#UVW_Map].length = 1
				$.modifiers[#UVW_Map].width = 1
				$.modifiers[#UVW_Map].height = 1


				------------------


				-- Clone the current selection and capture the new object(s)
				maxOps.cloneNodes $ cloneType:#copy newNodes:&theNewObject

				-- Rename the new object and select it
				theNewObject[1].name = theSpline.name + "_Grid"
				select theNewObject[1]

				-- Add Edit Poly modifier to the "_Grid" object
				modPanel.addModToSelection (Edit_Poly()) ui:on

				-- Go to Edge sub-object level and select all edges
				subobjectLevel = 2
				actionMan.executeAction 0 "40021"  -- Acción: Select All
					
				-- Create a new shape from the edges, name it with the "_mold" suffix,
				-- and store it in a variable for later use.
				local moldShape = $.modifiers[#Edit_Poly].createShapeFromName (theSpline.name + "_mold")

				-- Exit sub-object mode
				subobjectLevel = 0

				-- Delete the temporary "_Grid" object (which is still the current selection)
				delete $

				-- Select the new "moldShape" to work on it
				select moldShape

				-- To weld vertices, first convert the shape to an Editable Spline
				convertToSplineShape moldShape
				subobjectLevel = 1 -- Go to Vertex level
				actionMan.executeAction 0 "40021"  -- Action: Select All (vertices)
				splineOps.weld $ -- Weld the selected vertices
				subobjectLevel = 0 -- Exit sub-object mode

				-- Add and configure the Sweep modifier
				modPanel.addModToSelection (Sweep()) ui:on
				local sweepMod = $.modifiers[#Sweep]
				sweepMod.CurrentBuiltInShape = 8 -- T-Shape
				sweepMod.tee_length = 0.0787402
				sweepMod.tee_width = 0.393701
				sweepMod.tee_thickness = 0.019685
				sweepMod.tee_radius = 0
				sweepMod.MirrorXYPlane = on

				-- Set the view to Smooth+Highlights
				actionMan.executeAction 0 "272"

				-- Add and configure the Chamfer modifier
				modPanel.addModToSelection (Chamfer()) ui:on
				local chamferMod = $.modifiers[#Chamfer]
				chamferMod.amount = 0.00393701
				chamferMod.segments = 1
				chamferMod.miteringType = 0
				chamferMod.chamfertype = 0

				-- Add and configure the Smooth modifier
				modPanel.addModToSelection (smooth()) ui:on
				$.modifiers[#Smooth].autosmooth = off

				-- Add and configure the UVW Map modifier
				modPanel.addModToSelection (Uvwmap()) ui:on
				local uvwMod = $.modifiers[#UVW_Map]
				uvwMod.maptype = 4
				uvwMod.realWorldMapSize = on


				------------------


			)
			else
			(
				messageBox "Please select just one spline." title:"Error"
			)
		)
	)
	
	createDialog ceilingGenDialog 200 160
)
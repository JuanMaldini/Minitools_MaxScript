macroScript Ceiling Generator
category:"Minitools"
buttonText:"Ceiling Gen"
toolTip:"Ceiling Generator based on perimeters"
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
				
				-- Mensaje de prueba que muestra los valores capturados
				messageBox ("Spline: '" + theSpline.name + "'\nBorder: " + border_value as string + "\nSize: " + size_value as string) title:"Valores Capturados"
				
				-- Aquí irá el código que use 'theSpline', 'border_value' y 'size_value'
			)
			else
			(
				messageBox "Por favor, selecciona una única spline." title:"Error"
			)
		)
	)
	
	createDialog ceilingGenDialog 200 160
)
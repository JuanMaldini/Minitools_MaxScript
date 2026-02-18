macroScript Unwrapper category:"Minitools"
(
	objs = selection as array
	
	for obj in objs where (superClassOf obj == GeometryClass) do
	(
		try
		(
			clearSelection()
			select obj
			
			modPanel.addModToSelection (Unwrap_UVW()) ui:on
			
			u = obj.modifiers[#unwrap_uvw]
			modPanel.setCurrentObject u
			
			u.unwrap.setMapChannel 2
			
			subobjectLevel = 3
			u.unwrap2.selectFaces #{1..(polyop.getNumFaces obj)}
			u.unwrap2.flattenMap 45 [0,0,1] 0.02 true true true false
			
			subobjectLevel = 0
			clearSelection()
		)
		catch()
	)
)

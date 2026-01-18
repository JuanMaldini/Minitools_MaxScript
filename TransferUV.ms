	macroScript TransferUV category:"0_Minitools" buttonText:"TransferUV" toolTip:"Transfer UV (Unwrap: setMapChannel 0)"
	(
		fn tu_isVisibleGeometryNode n =
		(
			if n == undefined then return false
			if not isValidNode n then return false
			if (superClassOf n) != GeometryClass then return false
			if n.isHidden then return false
			true
		)

		fn tu_getLastModifier n =
		(
			if n == undefined then return undefined
			if n.modifiers.count < 1 then return undefined
			n.modifiers[n.modifiers.count]
		)

		fn tu_processNode n =
		(
			local lastMod = tu_getLastModifier n
			if lastMod == undefined then return false
			if (classOf lastMod) != Unwrap_UVW then return false

			select n
			subobjectLevel = 0
			try(modPanel.setCurrentObject lastMod) catch()
			try(lastMod.unwrap.setMapChannel 0) catch(return false)
			true
		)

		fn tu_run =
		(
			local prevSelection = selection as array
			local prevSubObjLevel = subobjectLevel
			local total = 0
			local okCount = 0
			local failCount = 0

			with redraw off
			(
				undo "TransferUV" on
				(
					for n in objects do
					(
						if tu_isVisibleGeometryNode n do
						(
							total += 1
							if tu_processNode n then okCount += 1 else failCount += 1
						)
					)
				)
			)

			subobjectLevel = prevSubObjLevel
			select prevSelection

			local status = if failCount == 0 then "OK" else "WITH FAILURES"
			messageBox ("TransferUV finished.\n\nTotal visible geometries: " + (total as string) + "\nSuccessful: " + (okCount as string) + "\nFailed: " + (failCount as string) + "\n\nStatus: " + status) title:"TransferUV"
		)

		tu_run()
	)


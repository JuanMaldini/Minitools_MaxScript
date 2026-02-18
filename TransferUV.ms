macroScript TransferUV category:"Minitools"
(
	for obj in selection do
		(
			obj.modifiers[#SteamRoller_Ch2].unwrap.setMapChannel 0
		)
)
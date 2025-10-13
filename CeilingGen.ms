global Size = 50.0
global Border = false

rollout myDialog "Configuraci?n"
(
    spinner sSize "Tama?o:" range: [0, 1000, 50] type:#float
    checkbox chkBorder "Borde:" checked:false
    button btnRun "Iniciar C?digo"

    on myDialog open do
    (
        sSize.value = Size
        chkBorder.checked = Border
    )

    on btnRun pressed do
    (
        Size = sSize.value
        Border = chkBorder.checked

        if selection.count == 1 and isKindOf selection[1] Shape then
        (
            OrigSpline = $
            modPanel.addModToSelection (Edit_Spline()) ui:on
            modPanel.addModToSelection (Edit_Poly()) ui:on
            modPanel.addModToSelection (Normalmodifier()) ui:on
            modPanel.addModToSelection (FloorGenerator()) ui:on

            actionMan.executeAction 0 "272"

            $.modifiers[#FloorGenerator].length = 50.0
            $.modifiers[#FloorGenerator].width = 50.0
            $.modifiers[#FloorGenerator].GroutLength = 0
            $.modifiers[#FloorGenerator].MinRowOffset = 0
            $.modifiers[#FloorGenerator].DoExtrude = off
            $.modifiers[#FloorGenerator].DoBevel = off

            modPanel.addModToSelection (smooth()) ui:on
            $.modifiers[#Smooth].autosmooth = off

            modPanel.addModToSelection (Uvwmap()) ui:on
            $.modifiers[#UVW_Map].maptype = 4
            $.modifiers[#UVW_Map].realWorldMapSize = on

            maxOps.cloneNodes $ cloneType:#copy newNodes:&gridObject
            gridObject[1].name = $.name + "_Grid"
            select gridObject[1]
            
            modPanel.addModToSelection (Edit_Poly()) ui:on
            subobjectLevel = 2
            actionMan.executeAction 0 "40021"
            
			local gridShape = (OrigSpline.name + "_Grid_Ceiling")
            $.modifiers[#Edit_Poly].CreateShape gridShape
            subObjectLevel = 0
            delete $
                
            select OrigSpline
            modPanel.addModToSelection (Shell ()) ui:on
            $.modifiers[#Shell].innerAmount = 0.015
            $.modifiers[#Shell].outerAmount = 0
            
            select $gridShape
            macros.run "Modifier Stack" "SubObject_1"
            actionMan.executeAction 0 "40021"
            macros.run "Editable Spline Object" "ESpline_Weld"
            subobjectLevel = 0
                
            modPanel.addModToSelection (sweep ()) ui:on
            $.modifiers[#Sweep].CurrentBuiltInShape = 8
            $.modifiers[#Sweep].MirrorXYPlane = on
            $.modifiers[#Sweep][#Tee_Section].tee_thickness = 0.05
            $.modifiers[#Sweep][#Tee_Section].tee_radius = 0
            $.modifiers[#Sweep][#Tee_Section].tee_width = 0.9
            $.modifiers[#Sweep][#Tee_Section].tee_length = 0.15
            actionMan.executeAction 0 "272"
            $.modifiers[#Sweep].PivotAlignment = 4
            $.modifiers[#Sweep].GenerateMappingCoords = on
                
            modPanel.addModToSelection (Chamfer ()) ui:on
            $.modifiers[#Chamfer].miteringType = 0
            $.modifiers[#Chamfer].chamfertype = 0
            $.modifiers[#Chamfer].quadIntersectionMode = off
            $.modifiers[#Chamfer].segments = 0
            $.modifiers[#Chamfer].amount = 0.01
                
            modPanel.addModToSelection (Uvwmap ()) ui:on
            $.modifiers[#UVW_Map].maptype = 4
                
            modPanel.addModToSelection (smooth ()) ui:on
            $.modifiers[#Smooth].autosmooth = off
        )
        else
        (
            messageBox "Please select one spline." title:"Error"
        )
        destroyDialog myDialog
    )
)

macroScript CeilingGenerator
category:"Minitools"
buttonText:"Ceiling Gen"
toolTip:"C Gen"
(
    createDialog myDialog width:200 height:130 #modal
)
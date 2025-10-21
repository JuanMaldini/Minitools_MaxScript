macroScript Areador category:"0_Minitools"
(
    rollout AreadorRollout "Areador" width:200 height:120
    (
        button btnPick "Pick Object" width:150 height:30
        editText edtResult "" pos:[10,40] width:180 height:60 readOnly:true

        fn calculateArea obj =
        (
            local result = "Selected: " + obj.name
            if classOf obj == Shape then
            (
                local perimeter = obj.length
                result += "\nPerimeter: " + (perimeter as string)
                if obj.closed do
                (
                    -- Nueva estrategia: calcular área manualmente con shoelace formula
                    local area = 0.0
                    for s = 1 to obj.numSplines do
                    (
                        local spline = obj.spline s
                        if spline.closed do
                        (
                            local knots = for k = 1 to spline.numKnots collect spline.knot k
                            for i = 1 to knots.count do
                            (
                                local j = mod i knots.count + 1
                                local p1 = knots[i]
                                local p2 = knots[j]
                                area += p1.x * p2.y - p2.x * p1.y
                            )
                        )
                    )
                    area = abs(area) / 2.0
                    result += "\nArea: " + (area as string)
                )
            )
            else
            (
                local tempObj = copy obj
                convertToPoly tempObj
                local surfaceArea = 0.0
                for f = 1 to tempObj.numFaces do
                (
                    surfaceArea += polyop.getFaceArea tempObj f
                )
                result += "\nSurface Area: " + (surfaceArea as string)
                delete tempObj
            )
            edtResult.text = result
        )

        on AreadorRollout open do
        (
            if selection.count == 1 do
            (
                calculateArea selection[1]
            )
        )

        on btnPick pressed do
        (
            local obj = pickObject message:"Select an object"
            if obj == undefined do return()
            select obj
            calculateArea obj
        )
    )

    createDialog AreadorRollout
)
macroScript Areador category:"0_Minitools"
(
    fn formatNumber value decimals:1 =
    (
        local stream = stringStream ""
        local fmt = "%"
        if decimals > 0 then fmt += "." + (decimals as string)
        fmt += "f"
        format fmt value to:stream
        local result = stream as string
        close stream
        result
    )

    fn convertToUnit value unitSuffix =
    (
        local unitValue = units.decodeValue ("1" + unitSuffix)
        if unitValue == 0 then 0 else value / unitValue
    )

    fn convertAreaToUnit value unitSuffix =
    (
        local unitValue = units.decodeValue ("1" + unitSuffix)
        if unitValue == 0 then 0 else value / (unitValue * unitValue)
    )

    fn buildLengthText value label =
    (
        local primaryValue = value
        local secondaryValue = convertToUnit value "m"
        local primaryLabel = "WU"
        local secondaryLabel = "m"

        if units.DisplayType == #metric then
        (
            local metricType = units.MetricType
            if metricType == #meters then
            (
                primaryValue = convertToUnit value "m"
                secondaryValue = convertToUnit value "cm"
                primaryLabel = "m"
                secondaryLabel = "cm"
            )
            else if metricType == #centimeters then
            (
                primaryValue = convertToUnit value "cm"
                secondaryValue = convertToUnit value "m"
                primaryLabel = "cm"
                secondaryLabel = "m"
            )
        )
        else if units.DisplayType == #us then
        (
            local usTypeStr = units.USType as string
            if findString usTypeStr "inch" != undefined then
            (
                primaryValue = convertToUnit value "in"
                secondaryValue = convertToUnit value "ft"
                primaryLabel = "in"
                secondaryLabel = "ft"
            )
            else
            (
                primaryValue = convertToUnit value "ft"
                secondaryValue = convertToUnit value "in"
                primaryLabel = "ft"
                secondaryLabel = "in"
            )
        )

        label + ": " + formatNumber primaryValue + " " + primaryLabel + " | " + formatNumber secondaryValue + " " + secondaryLabel
    )

    fn buildAreaText value label =
    (
        local primaryValue = value
        local secondaryValue = convertAreaToUnit value "m"
        local primaryLabel = "WU"
        local secondaryLabel = "m"

        if units.DisplayType == #metric then
        (
            local metricType = units.MetricType
            if metricType == #meters then
            (
                primaryValue = convertAreaToUnit value "m"
                secondaryValue = convertAreaToUnit value "cm"
                primaryLabel = "m"
                secondaryLabel = "cm"
            )
            else if metricType == #centimeters then
            (
                primaryValue = convertAreaToUnit value "cm"
                secondaryValue = convertAreaToUnit value "m"
                primaryLabel = "cm"
                secondaryLabel = "m"
            )
        )
        else if units.DisplayType == #us then
        (
            local usTypeStr = units.USType as string
            if findString usTypeStr "inch" != undefined then
            (
                primaryValue = convertAreaToUnit value "in"
                secondaryValue = convertAreaToUnit value "ft"
                primaryLabel = "in"
                secondaryLabel = "ft"
            )
            else
            (
                primaryValue = convertAreaToUnit value "ft"
                secondaryValue = convertAreaToUnit value "in"
                primaryLabel = "ft"
                secondaryLabel = "in"
            )
        )

        label + ": " + formatNumber primaryValue + " " + primaryLabel + " | " + formatNumber secondaryValue + " " + secondaryLabel
    )

    rollout AreadorRollout "Areador" width:300 height:140
    (
        button btnPick "Pick Object" width:225 height:30
        editText edtResult "" pos:[10,40] width:270 height:80 readOnly:true

        fn calculateArea obj =
        (
            local result = "Selected: " + obj.name
            if classOf obj == Shape then
            (
                local perimeter = obj.length
                result += "\n" + buildLengthText perimeter "Perimeter"
                if obj.closed do
                (
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
                    result += "\n" + buildAreaText area "Area"
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
                result += "\n" + buildAreaText surfaceArea "Surface Area"
                delete tempObj
            )
            edtResult.text = result
        )

        on AreadorRollout open do
        (
            if selection.count == 1 then
                calculateArea selection[1]
            else
                edtResult.text = "Select an object to analyze."
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
macroScript Measurer category:"0_Minitools"
(
    fn formatNumber value decimals:1 =
    (
        local sign = if value < 0 then "-" else ""
        local absValue = abs value
        local scale = 1
        for i = 1 to decimals do scale *= 10
        local total = floor (absValue * scale + 0.5)
        local integerPart = (total / scale) as integer
        local fractionPart = total - integerPart * scale
        local intStr = integerPart as string
        local fracStr = ""
        if decimals > 0 do
        (
            fracStr = (fractionPart as integer) as string
            while fracStr.count < decimals do fracStr = "0" + fracStr
            fracStr = "." + fracStr
        )
        sign + intStr + fracStr
    )

    fn convertToUnit value unitSuffix =
    (
        local unitValue = units.decodeValue ("1" + unitSuffix)
        if unitValue == 0 then 0 else value / unitValue
    )

    fn buildDistanceText value =
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

        "Distance: " + formatNumber primaryValue + " " + primaryLabel + " | " + formatNumber secondaryValue + " " + secondaryLabel
    )

    fn measureObject obj =
    (
        if obj == undefined do return "Select an object to measure."
        local result = "Selected: " + obj.name
        local startTime = animationRange.start
        local endTime = animationRange.end
        local step = 1f -- frames
        local totalDistance = 0.0
        local prevPos = at time startTime obj.position
        for t = (startTime + step) to endTime by step do
        (
            local currentPos = at time t obj.position
            totalDistance += distance prevPos currentPos
            prevPos = currentPos
        )
        result + "\n" + buildDistanceText totalDistance
    )

    rollout MeasurerRollout "Measurer" width:300 height:140
    (
        button btnPick "Pick Object" width:225 height:30
        editText edtResult "" pos:[10,40] width:270 height:80 readOnly:true

        on MeasurerRollout open do
        (
            if selection.count == 1 then
                edtResult.text = measureObject selection[1]
            else
                edtResult.text = "Select an object to measure."
        )

        on btnPick pressed do
        (
            local obj = pickObject message:"Select an object"
            if obj == undefined do return()
            select obj
            edtResult.text = measureObject obj
        )
    )

    createDialog MeasurerRollout
)

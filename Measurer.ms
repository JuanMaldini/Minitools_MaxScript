macroScript Measurer category:"0_Minitools"
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

macroScript Measurer category:"Minitools"
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

    -- Decode unit strings robustly across locales and 3ds Max variants
    fn decodeUnitValue unitSuffix =
    (
        local u = toLower unitSuffix
        local candidates = case u of
        (
            "ft": #("1ft", "1'", "1 feet", "1 foot")
            "feet": #("1ft", "1'", "1 feet", "1 foot")
            "foot": #("1ft", "1'", "1 feet", "1 foot")
            "in": #("1in", "1\"", "1 inch", "1 inches")
            "inch": #("1in", "1\"", "1 inch", "1 inches")
            "inches": #("1in", "1\"", "1 inch", "1 inches")
            "m": #("1m", "1 meter", "1 metre")
            "meter": #("1m", "1 meter", "1 metre")
            "metre": #("1m", "1 meter", "1 metre")
            "cm": #("1cm", "1 centimeter", "1 centimetre")
            "centimeter": #("1cm", "1 centimeter", "1 centimetre")
            "centimetre": #("1cm", "1 centimeter", "1 centimetre")
            default: #(("1" + unitSuffix))
        )
        for c in candidates do
        (
            local v = try(units.decodeValue c) catch 0.0
            if v != 0.0 do return v
        )
        0.0
    )

    fn convertToUnit value unitSuffix =
    (
        local unitValue = decodeUnitValue unitSuffix
        if unitValue == 0 then 0 else value / unitValue
    )

    -- Robustly determine US display pair (feet/inches or inches/feet)
    fn getUSUnitPair =
    (
        local usTypeStr = toLower (units.USType as string)
        -- Default to feet primary
        local primarySuffix = "ft"
        local secondarySuffix = "in"
        local primaryLabel = "ft"
        local secondaryLabel = "in"

        -- If it's explicitly an inches-only mode (decimal or fractional inches), make inches primary
        if (matchPattern usTypeStr pattern:"*inch*") and not (matchPattern usTypeStr pattern:"*feet*" or matchPattern usTypeStr pattern:"*foot*") do
        (
            primarySuffix = "in"; secondarySuffix = "ft"
            primaryLabel = "in"; secondaryLabel = "ft"
        )

        #(primarySuffix, secondarySuffix, primaryLabel, secondaryLabel)
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
            local pair = getUSUnitPair()
            local pSuf = pair[1]; local sSuf = pair[2]
            primaryValue = convertToUnit value pSuf
            secondaryValue = convertToUnit value sSuf
            primaryLabel = pair[3]
            secondaryLabel = pair[4]
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

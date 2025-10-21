macroScript Measurer category:"0_Minitools"
(
    fn measureObject obj =
    (
        local totalDistance = 0.0
        local startTime = animationRange.start
        local endTime = animationRange.end
        local step = 1 -- frames
        for t = startTime to (endTime - step) by step do
        (
            local pos1 = at time t obj.position
            local pos2 = at time (t + step) obj.position
            totalDistance += distance pos1 pos2
        )
        messageBox ("Selected: " + obj.name + "\nTotal Distance Traveled: " + (totalDistance as string))
    )

    rollout MeasurerRollout "Measurer" width:200 height:100
    (
        button btnPick "Pick Object" width:150 height:30

        on MeasurerRollout open do
        (
            if selection.count == 1 do
            (
                measureObject selection[1]
            )
        )

        on btnPick pressed do
        (
            local obj = pickObject message:"Select an object"
            if obj == undefined do return()
            select obj
            measureObject obj
        )
    )

    createDialog MeasurerRollout
)

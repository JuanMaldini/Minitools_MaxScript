macroscript BakerTex category:"Minitools"
(
    -- capture selected objects selection and filter for geometry only
    SelectedObjectsAll = deepcopy (selection as array)
    SelectedObjects = #()
    for a in SelectedObjectsAll do
    (
        if (superclassof a == GeometryClass) then append SelectedObjects a
    )

    -- clear up the BTT list
    BakeToTexture.deleteAllMaps()

    BakeMaps = #()

    -- get the project folder and set the destination folder for the Maps
    BakeToTexture.outputPath = pathConfig.getCurrentProjectFolder() + "\\sceneassets\\images"

    -- Adds a complete map in 2048x2048 for all my selected objects and set it to map channel 2
    for a in SelectedObjects do
    (
        -- if there is no UV channel 2, create one
        if (meshop.getMapSupport a.mesh 2) != true then
        (
            select a
            max modify mode
            NewModifier = Unwrap_UVW()
            addmodifier a NewModifier
            a.modifiers[1].setMapChannel 2
            a.modifiers[1].setApplyToWholeObject true
            a.modifiers[1].flattenMapNoParams()
            a.modifiers[1].pack 2 0.001 true true true
            subObjectLevel = 0
            deselect a
        )

        TheNewMap = BakeToTexture.addMap a #CompleteMap
        TheNewMap.imageWidth = 1024
        TheNewMap.imageHeight = 1024
        TheNewMap.uvChannel = 2
        append BakeMaps TheNewMap
    )

    -- Bakes the maps
    BakeToTexture.bake()

    -- moves the UVs from channel 2 to channel 1 so that the objects can use the complete map on channel 1
    for a in BakeMaps do
    (
        ChannelInfo.CopyChannel a.sceneObject 3 2
        ChannelInfo.PasteChannel a.sceneObject 3 1

        a.sceneObject.material = Physical_Material()
        a.sceneObject.material.base_color_map = bitmaptexture()
        a.sceneObject.material.base_color_map.filename = (BakeToTexture.outputPath + "\\" + a.fileName + "." + a.fileType)
        -- Put the rendered images in the diffuse slot of all my materials
    )
)
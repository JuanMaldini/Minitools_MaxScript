/*
    CommentMaterial - Minitools
    Replica minima del "Comment Box" de Unreal Engine dentro del Slate Material Editor.

    INSTALACION: arrastrar este archivo al viewport de 3ds Max (una sola vez).
    USO: en el Slate Material Editor, seleccionar uno o mas nodos y ejecutar
    "CommentMaterial" desde Customize > Hotkey Editor (3ds Max 2024+) o el
    menu de Customize UI, categoria "Minitools", grupo "Main UI" (los
    macroScript no pueden quedar scopeados solo al Material Editor sin un
    plugin compilado - ver cm_hotkeyInstructions()). Atajo recomendado:
    Shift+C.

    Volver a ejecutar con el marcador + nodos seleccionados = reajusta que
    nodos quedan "adentro" (equivalente aproximado a un resize).
*/

global CommentMaterial_Data
global CommentMaterial_Timer
global CommentMaterial_Prefix = "[C] "

if CommentMaterial_Data == undefined do CommentMaterial_Data = #()

fn cm_err step msg =
(
    messageBox ("CommentMaterial - error en: " + step + "\n\n" + (msg as string)) title:"CommentMaterial"
)

fn cm_activeView =
(
    -- sme.activeView es un INDICE (no la view en si) - hay que resolverlo
    -- con sme.GetView. Si no hay indice activo, se usa la primera view.
    local v = undefined
    try
    (
        if not sme.IsOpen() do sme.Open()
        local idx = sme.activeView
        if idx != undefined and idx != 0 do (try (v = sme.GetView idx) catch())
        if v == undefined and sme.GetNumViews() > 0 do (try (v = sme.GetView 1) catch())
    )
    catch (cm_err "abrir Slate Material Editor" (getCurrentException()))
    v
)

fn cm_underlyingObj n =
(
    local o = undefined
    try (o = n.reference) catch()
    if o == undefined do try (o = n.object) catch()
    if o == undefined do try (o = n.mtl) catch()
    if o == undefined do try (o = n.map) catch()
    if o == undefined do o = n
    o
)

fn cm_isMarkerClass c =
(
    c == Color or c == RGB_Tint or c == ColorCorrection or c == Checker
)

fn cm_isMarker obj =
(
    obj != undefined and cm_isMarkerClass (classOf obj) and \
    (try (matchPattern obj.name pattern:(CommentMaterial_Prefix + "*")) catch false)
)

fn cm_createMarkerMap =
(
    local candidates = #(Color, RGB_Tint, ColorCorrection, Checker)
    local m = undefined
    for c in candidates while m == undefined do
    (
        try (m = c()) catch()
    )
    m
)

fn cm_setMarkerColor obj col =
(
    try (obj.color = col) catch (try (obj.color1 = col) catch())
)

fn cm_boundingBox positions =
(
    local minX = positions[1].x
    local minY = positions[1].y
    local maxX = positions[1].x
    local maxY = positions[1].y
    for p in positions do
    (
        if p.x < minX do minX = p.x
        if p.y < minY do minY = p.y
        if p.x > maxX do maxX = p.x
        if p.y > maxY do maxY = p.y
    )
    #(minX, minY, maxX, maxY)
)

-- El rollout se define UNA SOLA VEZ a nivel de archivo (no dentro de la
-- funcion) y se comunica solo por globales. Definirlo dentro de una funcion
-- y que sus controles referencien parametros de esa funcion directamente
-- (text:defaultText) rompe en la segunda ejecucion con "bad free thunk"
-- porque el rollout queda con una referencia a un frame de pila ya liberado.
global CommentMaterial_AskResult
global CommentMaterial_AskDefaultText
global CommentMaterial_AskDefaultColor

rollout cm_dlg "Comentario"
(
    edittext cm_txt "Texto:" width:220
    colorPicker cm_col "Color:" width:60
    button cm_ok "Crear / Aplicar" width:140 across:2
    button cm_cancel "Cancelar" width:80

    on cm_dlg open do
    (
        cm_txt.text = CommentMaterial_AskDefaultText
        cm_col.color = CommentMaterial_AskDefaultColor
    )
    on cm_ok pressed do
    (
        CommentMaterial_AskResult = #(cm_txt.text, cm_col.color)
        destroyDialog cm_dlg
    )
    on cm_cancel pressed do
    (
        destroyDialog cm_dlg
    )
)

fn cm_askComment defaultText:"" defaultColor:(color 255 220 130) =
(
    CommentMaterial_AskResult = undefined
    CommentMaterial_AskDefaultText = defaultText
    CommentMaterial_AskDefaultColor = defaultColor
    createDialog cm_dlg modal:true
    CommentMaterial_AskResult
)

fn cm_onTick s e =
(
    -- La posicion de un nodo es la propiedad ".position" del propio nodo
    -- (no un metodo del view). No hace falta la view activa para esto.
    for entry in CommentMaterial_Data do
    (
        local markerNode = entry[1]
        local contained = entry[2]
        local lastPos = entry[3]
        try
        (
            local curPos = markerNode.position
            if curPos.x != lastPos.x or curPos.y != lastPos.y do
            (
                local dx = curPos.x - lastPos.x
                local dy = curPos.y - lastPos.y
                for cNode in contained do
                (
                    try
                    (
                        local cp = cNode.position
                        cNode.position = point2 (cp.x + dx) (cp.y + dy)
                    )
                    catch()
                )
                entry[3] = curPos
            )
        )
        catch()
    )
    ok
)

fn cm_startTracker =
(
    if CommentMaterial_Timer != undefined do return ok
    CommentMaterial_Timer = dotNetObject "System.Windows.Forms.Timer"
    CommentMaterial_Timer.Interval = 250
    dotNet.addEventHandler CommentMaterial_Timer "Tick" cm_onTick
    CommentMaterial_Timer.Start()
)

-- Investigado a fondo (doc oficial de actionMan, Autodesk):
-- 1) Un macroScript NO puede quedar scopeado a un contexto propio tipo
--    "Material Editor"/"SME" (que solo dispare con foco en el Slate). Eso
--    requiere un ActionItem registrado por SDK compilado (C++/C#) - es
--    literalmente como lo resuelve "SME SearchBar" (un plugin .dll, no un .ms).
--    Cualquier macroScript, incluido este, se registra en el grupo generico
--    "Main UI".
-- 2) NO existe API de MAXScript para asignar (ni siquiera consultar) atajos
--    de teclado por script: actionMan solo expone getKeyboardFile() /
--    loadKeyboardFile() / saveKeyboardFile() (archivos completos, no bindings
--    individuales). La unica forma "programática" seria editar a mano el
--    archivo de keyboard scheme activo del usuario - riesgoso (formato no
--    verificado en 2024, y ese archivo guarda TODOS sus atajos, no solo este)
--    asi que se descarta: queda como paso manual de un click, mas seguro.
-- Ctrl+C ya esta en uso (Copy/Clone) - si lo probas y no responde, es porque
-- esta pisado; Shift+C es la opcion sin conflicto conocido.
fn cm_hotkeyInstructions =
(
    "Atajo (3ds Max 2024 renombro 'Customize User Interface > Keyboard' a 'Hotkey Editor'):\n" + \
    "1) Customize > Hotkey Editor\n" + \
    "2) Buscá 'CommentMaterial' (Group: Main UI, Category: Minitools)\n" + \
    "3) Click en el campo 'Press keys' y toca Shift+C (recomendado) o Ctrl+C (probable choque con Copy/Clone)\n" + \
    "4) Assign > Done\n\n" + \
    "Nota: va a disparar mientras 3ds Max tenga el foco general. No hay forma de limitarlo a 'solo cuando el Slate esta activo' sin un plugin compilado."
)

macroScript CommentMaterial category:"Minitools"
(
    local view = cm_activeView()
    if view == undefined do
    (
        cm_err "obtener view activa" "No se pudo acceder al Slate Material Editor."
        return()
    )

    local selNodes = #()
    try (selNodes = view.GetSelectedNodes()) catch (cm_err "leer seleccion" (getCurrentException()))

    local existingMarker = undefined
    local realSelNodes = #()
    for n in selNodes do
    (
        local obj = cm_underlyingObj n
        if cm_isMarker obj then existingMarker = n
        else append realSelNodes n
    )

    if realSelNodes.count == 0 and existingMarker == undefined do
    (
        cm_err "crear comentario" "Selecciona al menos un nodo antes de ejecutar CommentMaterial (o selecciona el marcador + nodos para reajustar)."
        return()
    )

    local input = cm_askComment defaultText:""
    if input == undefined do return()

    local commentText = input[1]
    local commentColor = input[2]

    if existingMarker != undefined then
    (
        local obj = cm_underlyingObj existingMarker
        try (obj.name = CommentMaterial_Prefix + commentText) catch (cm_err "renombrar marcador" (getCurrentException()))
        cm_setMarkerColor obj commentColor
        for entry in CommentMaterial_Data where entry[1] == existingMarker do
        (
            entry[2] = realSelNodes
        )
    )
    else
    (
        -- El marcador se ubica centrado sobre el ancho del grupo (no solo en
        -- la esquina) para leer como una barra de titulo tipo comment box,
        -- en vez de un nodo mas al costado.
        local positions = for n in realSelNodes collect (try (n.position) catch (point2 0 0))
        local bbox = cm_boundingBox positions
        local centerX = (bbox[1] + bbox[3]) / 2.0
        local markerPos = point2 (centerX - 60) (bbox[2] - 60)

        local markerObj = cm_createMarkerMap()
        if markerObj == undefined do
        (
            cm_err "crear nodo marcador" "No se encontro ningun texmap candidato (Color/RGB_Tint/ColorCorrection/Checker) en esta version de 3ds Max."
            return()
        )
        try (markerObj.name = CommentMaterial_Prefix + commentText) catch()
        cm_setMarkerColor markerObj commentColor

        local markerNode = undefined
        try (markerNode = view.CreateNode markerObj markerPos) catch (cm_err "crear nodo en el view" (getCurrentException()))

        if markerNode == undefined do
        (
            try
            (
                local numN = view.GetNumNodes()
                for i = 1 to numN while markerNode == undefined do
                (
                    local nd = view.GetNode i
                    if (cm_underlyingObj nd) == markerObj do markerNode = nd
                )
            )
            catch()
        )

        if markerNode != undefined then
        (
            append CommentMaterial_Data #(markerNode, realSelNodes, markerPos)
            cm_startTracker()
        )
        else
        (
            cm_err "localizar nodo creado" "El texmap se creo pero no se pudo ubicar como nodo dentro del view. El arrastre automatico no va a funcionar para este comentario."
        )
    )
)

messageBox ("CommentMaterial instalado correctamente.\n\n" + \
    "Categoria: Minitools\n" + \
    "Uso: abri el Slate Material Editor, seleccioná nodos y ejecutá CommentMaterial desde Customize UI (o con el atajo una vez asignado).\n\n" + \
    cm_hotkeyInstructions() + "\n\n" + \
    "Pendiente (no implementado todavia): auto-actualizacion contra el server, persistencia entre sesiones, y una caja/fondo real dibujada detras de los nodos.") \
    title:"CommentMaterial"

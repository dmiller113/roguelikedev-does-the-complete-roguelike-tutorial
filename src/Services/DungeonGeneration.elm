module Services.DungeonGeneration exposing (..)
import Constants.Map exposing (defaultMap, bigRoom)
import Array exposing (Array)
import Random exposing (Generator, Seed, pair, bool, int)
import Lib.Utils exposing (mapWithRandom)


type DungeonGenerator = ConstantGenerator Seed
  | RogueGenerator Int Int Seed

type CorridorOrientation = Left
  | Right
  | Up
  | Down


type alias RoomInfo =
  { tX: Int
  , tY: Int
  , section: Int
  , width: Int
  , height: Int
  }

type alias Coord =
  { x: Int
  , y: Int
  }

type alias CorridorInfo =
  { beginSection: Int
  , endSection: Int
  , startEnd: (Coord, Coord)
  }

rogueRoomCoords =
  pair (int 1 20) (int 1 8)

rogueRoomGenerator =
  Random.map2 generateRoom rogueRoomCoords rogueRoomCoords

rogueChooseNeighborSection =
  pair (Random.bool) (Random.bool)


generatorToCharList: DungeonGenerator -> (List Char, Seed)
generatorToCharList generator =
  case generator of
    ConstantGenerator seed ->
      (String.toList defaultMap, seed)
    RogueGenerator width height seed ->
      generateRooms width height 12 seed


generateRooms: Int -> Int -> Int -> Seed -> (List Char, Seed)
generateRooms width height sections seed =
  let
    (roomInfos, middleSeed) = List.range 0 (sections - 1)
      |> mapWithRandom finishRogueRoom rogueRoomGenerator seed
  in
    createMap width height middleSeed roomInfos


generateRoom: (Int, Int) -> (Int, Int) -> RoomInfo
generateRoom coords1 coords2 =
  let
    tx = min (Tuple.first coords1) (Tuple.first coords2) |> min 17
    ty = min (Tuple.second coords1) (Tuple.second coords2) |> min 4
    bx = max (Tuple.first coords1) (Tuple.first coords2)
    by = max (Tuple.second coords1) (Tuple.second coords2)
  in
    { tX = tx
    , tY = ty
    , width = bx - tx |> max 3
    , height = by - ty |> max 3
    , section = 0}

finishRogueRoom: RoomInfo -> Int -> RoomInfo
finishRogueRoom ri section =
  { ri | section = section}


createMap: Int -> Int -> Seed -> List RoomInfo -> (List Char, Seed)
createMap width height seed roomInfos =
  let
    initMap = Array.repeat (width * height) '#'
    (corridorInfos, newSeed) = joinSections seed (Array.fromList roomInfos)
    corridorIndex = List.concatMap corridorInfoToIndexes corridorInfos
    roomMap = List.foldl changeMapWithRi initMap roomInfos
    map = List.foldl (\i accum -> Array.set i '.' accum) roomMap corridorIndex
  in
    (Array.toList map, newSeed)


changeMapWithRi: RoomInfo -> Array Char -> Array Char
changeMapWithRi ri acc =
  let
    h = List.range 0 (ri.height - 1)
    sectionX = (ri.section % 4)
    sectionY = (ri.section // 4)
    indexes = (List.concatMap (rogueFormCoords sectionX sectionY ri) h)
  in
    List.foldl (\i accum -> Array.set i '.' accum) acc indexes


joinSections: Seed -> Array RoomInfo -> (List CorridorInfo, Seed)
joinSections currentSeed roomInfos =
  mapWithRandom (createRogueCorridor roomInfos) rogueChooseNeighborSection currentSeed (Array.toList roomInfos)


createRogueCorridor: Array RoomInfo -> (Bool, Bool) -> RoomInfo -> CorridorInfo
createRogueCorridor roomArray (isX, sign) ri =
  let
    amount = if sign then 1 else -1
    elSection = ri.section
    sectionX = ri.section % 4
    sectionY = ri.section // 4
    newSectionX = if isX then
        if sectionX + amount > 3 then 2
        else if sectionX + amount < 0 then 1
        else sectionX + amount
      else sectionX

    newSectionY = if not isX then
        if sectionY + amount > 2 then 1
        else if sectionY + amount < 0 then 1
        else sectionY + amount
      else sectionY
    newSection = newSectionX + (newSectionY * 4)
    endRi = Maybe.withDefault ri <| Array.get newSection roomArray
  in
    { beginSection = ri.section
    , endSection = newSection
    , startEnd = (
      {x = (ri.tX + ri.width // 2), y = (ri.tY + ri.height // 2)}
      , {x = (endRi.tX + endRi.width // 2), y = (endRi.tY + endRi.height // 2)})
    }


corridorInfoToIndexes: CorridorInfo -> List Int
corridorInfoToIndexes {beginSection, endSection, startEnd} =
  List.concat
    [(sectionCorridor beginSection (compare (beginSection % 4) (endSection % 4), compare (beginSection // 4) (endSection // 4)) (Tuple.first startEnd)),
    (sectionCorridor endSection (compare (endSection % 4) (beginSection % 4) , compare (endSection // 4) (beginSection // 4)) (Tuple.second startEnd)),
    (joinVertically beginSection endSection startEnd)]


sectionCorridor: Int -> (Order, Order) -> Coord -> List Int
sectionCorridor section order {x, y} =
  let
    orientation = getOrientation order
    (rStart, rEnd) = properCorridorOrder orientation {x = x, y = y}
    start = rogueTranslateSCoordToCoord section rStart
    end = rogueTranslateSCoordToCoord section rEnd
  in
    if orientation == Left || orientation == Right then
      List.range
        (start)
        (end)
    else
      List.map callTranslateWithSection
      <| verticalLink (abs (rStart.tY - rEnd.tY)) section {x = rStart.tX, y = rStart.tY}


callTranslateWithSection: {a| tX: Int, tY: Int, section: Int} -> Int
callTranslateWithSection a =
  rogueTranslateSCoordToCoord a.section a

joinVertically: Int -> Int -> (Coord, Coord) -> List Int
joinVertically beginSection endSection (start, end) =
  let
    orientation = getOrientation (compare (beginSection % 4) (endSection % 4)
                                 , compare (beginSection // 4) (endSection // 4)
                                 ) --|> Debug.log "baba"
    -- aset = Debug.log "Coords" (beginSection, start, endSection, end)
    startCoord =
      case orientation of
        Right -> {start| x = 19, y = (min start.y end.y)}
        Left -> {start| x = 0, y = (min start.y end.y)}
        _ -> start
  in
    if orientation == Right || orientation == Left then
      List.map (\a -> rogueTranslateSCoordToCoord a.section a) <| verticalLink (abs (start.y - end.y)) beginSection startCoord
    else
      []


verticalLink: Int -> Int -> {a| x: Int, y: Int} -> List {tX: Int, tY: Int, section: Int}
verticalLink height section start =
  -- let
    -- h = Debug.log "Height" height
    -- s = Debug.log "Section" section
  -- in
    List.range start.y (start.y + height)
    |> List.map (constructVCoord section start) -- |> Debug.log "v's"


constructVCoord: Int -> {a| x: Int, y: Int} -> Int -> {tX: Int, tY: Int, section: Int}
constructVCoord section {x, y} hl =
  let
    -- aset = Debug.log "x, y, hl, section" (x, y, hl, section)
    newSection = section + (hl // 8) -- |> Debug.log "New Section"
  in
    {tX = x, tY = hl % 8, section = newSection}

getOrientation: (Order, Order) -> CorridorOrientation
getOrientation (horizontal, verticle) =
  case (horizontal, verticle) of
    (GT, EQ) -> Left
    (LT, EQ) -> Right
    (EQ, GT) -> Up
    (EQ, LT) -> Down
    _ -> Left


properCorridorOrder: CorridorOrientation -> Coord -> ({tX: Int, tY: Int}, {tX: Int, tY: Int})
properCorridorOrder orientation {x, y} =
  case orientation of
    Left ->
      -- Going left, to zero
      ({tX = 0, tY = y}, {tX = x, tY = y})
    Right ->
      -- Going right to 19
      ({tX = x, tY = y}, {tX = 19, tY = y})
    Up ->
      -- Going up to 0
      ({tX = x, tY = 0}, {tX = x, tY = y})
    Down ->
      -- Going down to 7
      ({tX = x, tY = y}, {tX = x, tY = 7})


formCoords: Int -> Int -> Int -> Int -> RoomInfo -> Int -> List Int
formCoords sectionWidth sectionHeight sectionX sectionY ri hi =
  List.range (translateSCoordToCoord sectionWidth sectionHeight 80 hi sectionX sectionY ri)
             (translateSCoordToCoord sectionWidth sectionHeight 80 hi sectionX sectionY {ri| tX = ri.tX + ri.width})

rogueFormCoords: Int -> Int -> RoomInfo -> Int -> List Int
rogueFormCoords = formCoords (80 // 4) (24 // 3)


translateSCoordToCoord: Int -> Int -> Int -> Int -> Int -> Int -> {a | tX: Int, tY: Int} -> Int
translateSCoordToCoord sectionWidth sectionHeight mapHeight heightLine sectionX sectionY {tX, tY} =
  (tX + (sectionX * sectionWidth)) + ((heightLine + (tY + (sectionY * sectionHeight))) * mapHeight)

rogueTranslateSCoordToCoord: Int -> {a | tX: Int, tY: Int} -> Int
rogueTranslateSCoordToCoord section ri =
  translateSCoordToCoord (80 // 4) (24 // 3) 80 0 (section % 4) (section // 4) ri

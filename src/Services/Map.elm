module Services.Map exposing (..)
import Models.Entity exposing (Entity)
import Models.ComponentStateTypes exposing (Position, DrawInfo)
import Models.Position exposing (extractPosition)
import Models.Tiles exposing (TileInfo, floor_tile)
import Services.Physical exposing (PhysicalInfo, PhysicalDict)
import Dict exposing (Dict)

type alias Tile = Entity


makeTile: Int -> (Tile, Int)
makeTile nextId =
  (initTile nextId, nextId + 1)

initTile: Int -> Tile
initTile id =
  { id = id
  , name = "tile " ++ toString id
  }

initPosition: Int -> Int -> Position
initPosition x y =
  {x = x, y = y}

initPositions: List Int -> Int -> List Position
initPositions ly x =
  List.map (initPosition x) ly

initMap: Int -> Int -> Int -> Dict Int Position -> Dict Int DrawInfo -> (List Tile, Dict Int Position, Dict Int DrawInfo, Int)
initMap nextId maxX maxY pDict dDict=
  let
    idList = List.range nextId (nextId + (maxX + 1) * (maxY + 1) - 1)
    xList = List.range 0 maxX
    yList = List.range 0 maxY
    tiles = List.map initTile idList
    positions =  List.concatMap (initPositions yList) xList
    positionDict = linkTilesToPosition tiles positions pDict
    drawables = linkTilesToDraw tiles positionDict dDict
  in
    (tiles, positionDict, drawables, nextId + maxX * maxY)

linkTilesToPosition: List Tile -> List Position -> Dict Int Position -> Dict Int Position
linkTilesToPosition tiles positionsList positionsDict =
  let
    listId = List.map .id tiles
    posList = Dict.toList positionsDict
    kvList = List.map2 (,) listId positionsList
  in
    Dict.fromList <| kvList ++ posList

linkTilesToDraw: List Tile -> Dict Int Position -> Dict Int DrawInfo -> Dict Int DrawInfo
linkTilesToDraw tiles positions drawables =
  let
    dDi = Dict.fromList <| List.map (initialTilesToDI floor_tile positions) tiles
  in
    Dict.union dDi drawables

linkTilesToPhysical: List Tile -> PhysicalDict
linkTilesToPhysical tiles =
  Dict.fromList <| List.map (tileInfoToPhysical floor_tile) tiles

initialTilesToDI: TileInfo -> Dict Int Position -> Tile -> (Int, DrawInfo)
initialTilesToDI ti positions item =
  ( item.id
  , { position = extractPosition <| Dict.get item.id positions
    , symbol = ti.symbol
    , foregroundColor = ti.foregroundColor
    , backgroundColor = ti.backgroundColor
    }
  )

tileInfoToPhysical: TileInfo -> Tile -> (Int, PhysicalInfo)
tileInfoToPhysical ti tile =
  ( tile.id
  , ti.physicalInfo
  )

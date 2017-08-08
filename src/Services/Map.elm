module Services.Map exposing (..)
import Models.Entity exposing (Entity)
import Models.ComponentStateTypes exposing (Position, DrawInfo)
import Models.Position exposing (extractPosition)
import Models.Tiles exposing (TileInfo, mapPointToTileInfo)
import Services.Physical exposing (PhysicalInfo, PhysicalDict)
import Services.Component exposing (Components)
import Services.DungeonGeneration exposing (DungeonGenerator, generatorToCharList)
import Constants.Map exposing (defaultMap)
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
initPosition y x =
  {x = x, y = y}

initPositions: List Int -> Int -> List Position
initPositions lx y =
  List.map (initPosition y) lx

initMap: Int -> Int -> Int -> Dict Int Position ->
         Dict Int DrawInfo -> DungeonGenerator -> ( List Tile
                                                  , Dict Int Position
                                                  , Dict Int DrawInfo
                                                  , PhysicalDict
                                                  , Int)
initMap nextId maxX maxY pDict dDict dungeonGenerator =
  let
    idList = List.range nextId (nextId + (maxX + 1) * (maxY + 1) - 1)
    xList = List.range 0 maxX
    yList = List.range 0 maxY
    tiles = List.map initTile idList
    mapInfo = List.map mapPointToTileInfo <| generatorToCharList dungeonGenerator
    positions = List.concatMap (initPositions xList) yList
    positionDict = linkTilesToPosition tiles positions pDict
    physicals = linkTilesToPhysical mapInfo tiles
    drawables = linkTilesToDraw tiles positionDict dDict mapInfo
  in
    (tiles, positionDict, drawables, physicals, nextId + maxX * maxY)

linkTilesToPosition: List Tile -> List Position -> Dict Int Position -> Dict Int Position
linkTilesToPosition tiles positionsList positionsDict =
  let
    listId = List.map .id tiles
    posList = Dict.toList positionsDict
    kvList = List.map2 (,) listId positionsList
  in
    Dict.fromList <| kvList ++ posList

linkTilesToDraw: List Tile -> Dict Int Position -> Dict Int DrawInfo -> List TileInfo -> Dict Int DrawInfo
linkTilesToDraw tiles positions drawables tiList =
  let
    dDi = Dict.fromList <| List.map2 (initialTilesToDI positions) tiList tiles
  in
    Dict.union dDi drawables

linkTilesToPhysical: List TileInfo -> List Tile -> PhysicalDict
linkTilesToPhysical tiList tiles =
  Dict.fromList <| List.map2 tileInfoToPhysical tiList tiles

initialTilesToDI: Dict Int Position -> TileInfo -> Tile -> (Int, DrawInfo)
initialTilesToDI positions ti item =
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

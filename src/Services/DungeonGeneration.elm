module Services.DungeonGeneration exposing (..)
import Constants.Map exposing (defaultMap, blankMap)
import Array exposing (Array)


type DungeonGenerator = ConstantGenerator
  | RogueGenerator Int Int


type alias RoomInfo =
  { tX: Int
  , tY: Int
  , section: Int
  , width: Int
  , height: Int
  }


generatorToCharList: DungeonGenerator -> List Char
generatorToCharList generator =
  case generator of
    ConstantGenerator ->
      String.toList defaultMap
    RogueGenerator width height ->
      generateRooms width height 12


generateRooms: Int -> Int -> Int -> List Char
generateRooms width height sections =
  let
    roomInfos = List.range 0 (sections - 1)
      |> List.map generateRoom
  in
    createMap width height roomInfos


generateRoom: Int -> RoomInfo
generateRoom section =
  { tX = 1, tY = 1, width = 16, height = 6, section = section}


createMap: Int -> Int -> List RoomInfo -> List Char
createMap width height roomInfos =
  let
    initMap = Array.repeat (width * height) '#'
    sections = List.length roomInfos
    map = List.foldl (changeMapWithRi sections) initMap roomInfos
  in
    Array.toList map

changeMapWithRi: Int -> RoomInfo -> Array Char -> Array Char
changeMapWithRi sectionCount ri acc =
  let
    h = List.range 0 (ri.height - 1)
    sectionX = (ri.section % 4)
    sectionY = (ri.section % 3)
    sectionWidth = 80 // 4
    sectionHeight = 24 // 3
    indexes = List.concatMap (formCoords sectionWidth sectionHeight sectionX sectionY ri) h
  in
    List.foldl (\i accum -> Array.set i '.' accum) acc indexes


formCoords: Int -> Int -> Int -> Int -> RoomInfo -> Int -> List Int
formCoords sectionWidth sectionHeight sectionX sectionY ri hi =
  List.range ((ri.tX +
                (sectionX * sectionWidth)) +
                ((hi + (ri.tY + (sectionY * sectionHeight))) * 80))
             ((ri.tX + ri.width +
                (sectionX * sectionWidth)) +
                ((hi + ri.tY + (sectionY * sectionHeight)) * 80))

module Services.DungeonGeneration exposing (..)
import Constants.Map exposing (defaultMap, blankMap)

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
      generateRooms width height 8


generateRooms: Int -> Int -> Int -> List Char
generateRooms width height sections =
  List.range 0 (sections - 1)
  |> List.map (generateRoom >> (roomToStrings width height sections))
  |> List.foldl (stitch ((width // (sections // 2)) )) []

generateRoom: Int -> RoomInfo
generateRoom section =
  { tX = 1, tY = 1, width = 10, height = 9, section = section}


roomToStrings: Int -> Int -> Int -> RoomInfo -> List Char
roomToStrings mwidth mheight sections ri =
  List.range 0 (mwidth * mheight // sections - 1)
  |> List.map (constructRoomChars (mwidth // (sections // 2)) ri)


constructRoomChars: Int -> RoomInfo -> Int -> Char
constructRoomChars sectionWidth ri position =
  let
    roomLeftEdge = ri.tX
    roomRightEdge = roomLeftEdge + ri.width
    yPos = position // sectionWidth
  in
    case (compare (position % sectionWidth) roomLeftEdge, compare (position % sectionWidth) roomRightEdge) of
      (LT, _) -> '#'
      (_, GT) -> '#'
      _ ->
        case (compare yPos ri.tY, compare yPos (ri.tY + ri.height)) of
          (LT, _) -> '#'
          (_, GT) -> '#'
          _ -> '.'


stitch: Int -> List a -> List a -> List a
stitch start_width list1 list2 =
  case (list1, list2) of
    (a, []) -> a
    ([], _) -> []
    (x::xs, y) ->
      let
        width = (List.length y) // (List.length list1)
        head = List.take width y
        tail = List.drop width y
      in
        head ++ [x] ++ (stitch start_width xs tail)

module Models.ComponentStateTypes exposing
  ( Position
  , DrawInfo
  , Symbol
  , Momentum
  , sortDrawInfo
  , Color
  , drawInfoToString
  , posToString
  , Coord
  )
import Set exposing (Set)
import Constants.Colors exposing(explored, unexplored)

type alias Position =
  { x: Int
  , y: Int
  }


type alias Coord =
  (Int, Int)

type alias Symbol = Char

type alias Momentum =
  { cX: Int
  , cY: Int
  }

type alias DrawInfo =
  { position: Position
  , symbol: Symbol
  , foregroundColor: Color
  , backgroundColor: Color
  }

type alias Color = String

posToString: Position -> String
posToString position =
  String.concat [toString position.x, ":", toString position.y]

compareDrawInfo: DrawInfo -> DrawInfo -> Order
compareDrawInfo a b =
  case compare a.position.y b.position.y of
    EQ ->
      compare a.position.x b.position.x
    o ->
      o


sortDrawInfo: List DrawInfo -> List DrawInfo
sortDrawInfo =
  List.sortWith compareDrawInfo

drawInfoToString: Set Coord -> Set Coord -> DrawInfo -> String
drawInfoToString fov explored di =
  case Set.member (di.position.x, di.position.y) fov of
    _ ->
      "%c{" ++ di.foregroundColor ++ "}" ++ "%b{" ++ di.backgroundColor ++ "}" ++ String.fromChar di.symbol ++ "%c{}%b{}"
    -- False ->
    --   case Set.member (di.position.x, di.position.y) explored of
    --     True ->
    --       "%c{" ++ Constants.Colors.explored ++ "}%b{" ++ Constants.Colors.unexplored ++ "}" ++ String.fromChar di.symbol ++ "%c{}%b{}"
    --     False ->
    --       "%c{" ++ unexplored ++ "}%b{" ++ unexplored ++ "}.%c{}%b{}"

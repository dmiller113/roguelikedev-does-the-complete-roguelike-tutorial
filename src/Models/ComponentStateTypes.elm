module Models.ComponentStateTypes exposing
  ( Position
  , DrawInfo
  , Symbol
  , Momentum
  , sortDrawInfo
  , Color
  , drawInfoToString
  )

type alias Position =
  { x: Int
  , y: Int
  }

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

drawInfoToString: DrawInfo -> String
drawInfoToString di =
  "%c{" ++ di.foregroundColor ++ "}" ++ "%b{" ++ di.backgroundColor ++ "}" ++ String.fromChar di.symbol ++ "%c{}%b{}"

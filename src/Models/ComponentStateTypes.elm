module Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol, Momentum, sortDrawInfo)

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
  }


compareDrawInfo: DrawInfo -> DrawInfo -> Order
compareDrawInfo a b =
  case compare a.position.y b.position.y of
    GT ->
      GT
    _ ->
      compare a.position.x b.position.x


sortDrawInfo: List DrawInfo -> List DrawInfo
sortDrawInfo = List.sortWith compareDrawInfo

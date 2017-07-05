module Models.ComponentStateTypes exposing (Position, DrawInfo, Symbol)

type alias Position =
  { x: Int
  , y: Int
  }

type alias Symbol = Char

type alias DrawInfo =
  { position: Position
  , symbol: Symbol
  }

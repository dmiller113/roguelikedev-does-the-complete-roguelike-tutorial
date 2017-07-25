module Models.Tiles exposing (..)
import Services.Physical exposing (PhysicalInfo)
import Models.ComponentStateTypes exposing (Color)

type alias TileInfo =
  { symbol: Symbol
  , physicalInfo: PhysicalInfo
  , backgroundColor: Color
  , foregroundColor: Color
  , name: String
  }

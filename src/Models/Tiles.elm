module Models.Tiles exposing (..)
import Services.Physical exposing (PhysicalInfo)
import Models.ComponentStateTypes exposing (Color, Symbol)

type alias TileInfo =
  { symbol: Symbol
  , physicalInfo: PhysicalInfo
  , backgroundColor: Color
  , foregroundColor: Color
  , name: String
  , description: String
  }

floor_tile: TileInfo
floor_tile =
  { symbol = '.'
  , physicalInfo = { blocksMovement = False, blocksSight = False }
  , backgroundColor = "#333333"
  , foregroundColor = "#FFFFFF"
  , name = "Undescript Floor"
  , description = "A bare patch of floor. Dust and dirt covers its cool surface."
  }

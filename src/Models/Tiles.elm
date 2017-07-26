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
  , name = "Nondescript Floor"
  , description = "A bare patch of floor. Dust and dirt covers its cool surface."
  }

wall_tile: TileInfo
wall_tile =
  { symbol = '#'
  , physicalInfo = { blocksMovement = True, blocksSight = True }
  , backgroundColor = "#333333"
  , foregroundColor = "#FFFFFF"
  , name = "Nondescript Wall"
  , description = "A bare wall. It has a dull shine from your light hitting its slick surface."
  }

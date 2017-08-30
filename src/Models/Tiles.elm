module Models.Tiles exposing (..)

import Services.Physical exposing (PhysicalInfo)
import Models.ComponentStateTypes exposing (Color, Symbol)


type alias TileInfo =
    { symbol : Symbol
    , physicalInfo : PhysicalInfo
    , backgroundColor : Color
    , foregroundColor : Color
    , name : String
    , description : String
    }


floor_tile : TileInfo
floor_tile =
    { symbol = '.'
    , physicalInfo = { blocksMovement = False, blocksSight = False }
    , backgroundColor = "#222222"
    , foregroundColor = "#bac5c5"
    , name = "Nondescript Floor"
    , description = "A bare patch of floor. Dust and dirt covers its cool surface."
    }


corridor_tile : TileInfo
corridor_tile =
    { symbol = ':'
    , physicalInfo = { blocksMovement = False, blocksSight = False }
    , backgroundColor = "#222222"
    , foregroundColor = "#b7b072"
    , name = "Nondescript Corridor"
    , description = "A bare patch of floor. Dust and dirt covers its cool surface."
    }


wall_tile : TileInfo
wall_tile =
    { symbol = '#'
    , physicalInfo = { blocksMovement = True, blocksSight = True }
    , backgroundColor = "#583e34"
    , foregroundColor = "#7f7f7f"
    , name = "Nondescript Wall"
    , description = "A bare wall. It has a dull shine from your light hitting its slick surface."
    }


mapPointToTileInfo : Char -> TileInfo
mapPointToTileInfo point =
    case point of
        '#' ->
            wall_tile

        '.' ->
            floor_tile

        '@' ->
            -- player spawn
            floor_tile

        ':' ->
            -- Corridor
            floor_tile

        _ ->
            wall_tile

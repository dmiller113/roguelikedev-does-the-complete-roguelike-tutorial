module Services.Physical exposing (..)
import Dict exposing (Dict)


type alias PhysicalInfo =
  { blocksMovement: Bool
  , blocksSight: Bool
  }

type alias PhysicalDict = Dict Int PhysicalInfo

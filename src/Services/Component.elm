module Services.Component exposing (..)
import Models.ComponentStateTypes exposing (Position, DrawInfo, Momentum)
import Services.Physical exposing (PhysicalDict)
import Dict exposing (Dict)

type alias Components =
  { positions: Dict Int Position
  , drawables: Dict Int DrawInfo
  , movables: Dict Int Momentum
  , physicals: PhysicalDict
  }

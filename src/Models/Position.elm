module Models.Position exposing (deltaPosition,
                                 extractPosition)
import Services.Key exposing (Key(..))
import Maybe exposing (Maybe(..))
import Dict exposing (Dict)
import Models.ComponentStateTypes exposing (Position, Momentum)


type alias Delta = (Int, Int)


-- Left == 37 - Down == 40
deltaPosition: Key -> Delta
deltaPosition key =
  case key of
    Left -> -- Left
      (-1, 0)
    Up -> -- Up
      (0, -1)
    Right -> -- Right
      (1, 0)
    Down -> -- Down
      (0, 1)
    _ ->
      (0, 0)


-- Utilities
extractPosition: Maybe Position -> Position
extractPosition p =
  case p of
    Just position ->
      position
    Nothing ->
      { x = 0, y = 0 }

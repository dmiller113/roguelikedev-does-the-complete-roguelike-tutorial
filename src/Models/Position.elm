module Models.Position exposing (updatePosition, deltaPosition,
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


-- Updates
updatePosition: Dict Int Momentum -> Int -> Position -> Position
updatePosition momentumDict eid position =
  let
    {cX, cY} = Maybe.withDefault { cX = 0, cY = 0 } <| Dict.get eid momentumDict
  in
    { x = position.x + cX, y = position.y + cY }


-- Utilities
extractPosition: Maybe Position -> Position
extractPosition p =
  case p of
    Just position ->
      position
    Nothing ->
      { x = 0, y = 0 }

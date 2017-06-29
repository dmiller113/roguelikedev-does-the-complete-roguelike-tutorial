module Models.Position exposing (updatePosition,
                                 extractPosition, isPositionComponent)
import Services.Component exposing (Component(..))
import Services.Key exposing (Key(..))
import Maybe exposing (Maybe(..))
import Models.ComponentStateTypes exposing (Position)


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
updatePosition: Position -> Key -> Position
updatePosition position key =
  let
    (nX, nY) = deltaPosition key
    {x, y} = position
  in
    { x = x + nX, y = y + nY }


-- Utilities
extractPosition: Maybe Component -> Position
extractPosition c =
  case c of
    Just position ->
      case position of
        PositionComponent position _ ->
          position
        _ ->
          { x = 0, y = 0 }
    Nothing ->
      { x = 0, y = 0 }

isPositionComponent: Component -> Bool
isPositionComponent c =
  case c of
    PositionComponent _ _ ->
      True
    _ ->
      False

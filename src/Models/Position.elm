module Models.Position exposing (Position, updatePosition)
import Services.Key exposing (Key(..))


type alias Position =
  { x: Int
  , y: Int
  }

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
updatePosition: Position -> Delta -> Position
updatePosition position delta =
  let
    (nX, nY) = delta
    {x, y} = position
  in
    { x = x + nX, y = y + nY }

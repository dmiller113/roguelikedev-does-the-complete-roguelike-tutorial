module Services.Movement exposing (..)
import Models.ComponentStateTypes exposing (Momentum, Position)
import Models.Position exposing (deltaPosition, updatePosition)
import Services.Key exposing (Key)
import Dict exposing (Dict)
import Maybe exposing (Maybe(..))


updateMovables: Dict Int Momentum -> Key -> Int -> Dict Int Momentum
updateMovables iv key pid =
  Dict.update pid (updateMovableWithKey key) iv

updateMovableWithKey: Key -> Maybe Momentum -> Maybe Momentum
updateMovableWithKey key momentum =
  let
    (cx, cy) = deltaPosition key
  in
    case momentum of
      _ ->
        Just { cX = cx, cY = cy }

moveActors: Dict Int Momentum -> Dict Int Position -> Dict Int Position
moveActors momentumDict positionDict =
  Dict.map (updatePosition momentumDict) positionDict

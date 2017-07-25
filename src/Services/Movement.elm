module Services.Movement exposing (..)
import Models.ComponentStateTypes exposing (Momentum, Position)
import Models.Position exposing (deltaPosition)
import Services.Physical exposing (PhysicalDict)
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

moveActors: Dict Int Momentum -> PhysicalDict -> Dict Int Position -> Dict Int Position
moveActors momentumDict physicalDict positionDict =
  Dict.map (updatePosition momentumDict positionDict physicalDict) positionDict


updatePosition: Dict Int Momentum -> Dict Int Position -> PhysicalDict -> Int -> Position -> Position
updatePosition momentumDict positionDict physicalDict eid position =
  let
    {cX, cY} = Maybe.withDefault { cX = 0, cY = 0 } <| Dict.get eid momentumDict
    newPosition = { x = position.x + cX, y = position.y + cY }
  in
    newPosition

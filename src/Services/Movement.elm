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
  let
    mirroredPositions = Dict.foldl reversePositionDict (Dict.empty) positionDict
  in
    Dict.map (updatePosition momentumDict physicalDict mirroredPositions positionDict) positionDict


updatePosition: Dict Int Momentum -> PhysicalDict -> Dict String (List Int) -> Dict Int Position -> Int -> Position -> Position
updatePosition momentumDict physicalDict reversePosition positionDict eid position =
  let
    {cX, cY} = Maybe.withDefault { cX = 0, cY = 0 } <| Dict.get eid momentumDict
    newPosition = if cX == 0 && cY == 0 then
      position
    else
      let
        proposedPosition = { x = position.x + cX, y = position.y + cY } |> Debug.log "Moving To"
        key = (toString proposedPosition.x) ++ ":" ++ (toString proposedPosition.y)
        newPositionIds = Debug.log "NewPosId" <| Maybe.withDefault [eid] <| Dict.get key reversePosition
        newPositionPhysicals = List.map (\i -> Dict.get i physicalDict) newPositionIds |> Debug.log "Physicals"
      in
        if List.any Services.Physical.isBlocking newPositionPhysicals then
          position
        else
          proposedPosition

  in
    newPosition

reversePositionDict: Int -> Position -> Dict String (List Int) -> Dict String (List Int)
reversePositionDict tid position accumulator =
  let
    key = (toString position.x) ++ ":" ++ (toString position.y)
    value = (Dict.get key accumulator |> (Maybe.withDefault [])) ++ [tid]
  in
    Dict.insert key value accumulator

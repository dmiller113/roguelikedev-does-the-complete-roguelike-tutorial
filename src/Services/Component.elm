module Services.Component exposing (Component(..), updateComponents)
import Models.ComponentStateTypes exposing (Position)
import Services.Key exposing (Key(..))


type Component = NoComponent
  | PositionComponent Position (Position -> Key -> Position)

-- Update stuff specific to Components
updateComponents: Key -> List Component -> List Component
updateComponents key componentList =
  List.map (updateComponent key) componentList


updateComponent: Key -> Component -> Component
updateComponent key component =
  case component of
    PositionComponent position updatePosition ->
      PositionComponent (updatePosition position key)  updatePosition
    NoComponent ->
      component

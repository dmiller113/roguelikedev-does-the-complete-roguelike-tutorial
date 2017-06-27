module Models.Actor exposing (Actor, Component(..), updateComponents)
import Models.Position exposing (Position, updatePosition)

type Component = NoComponent | PositionComponent Position

type alias Actor =
  { id: Int
  , name: String
  , components: List Component
  }


-- Update stuff specific to Actors

-- Update stuff specific to Components
updateComponents: List Component -> List Component
updateComponents componentList =
  List.map updateComponent componentList


updateComponent: Component -> Component
updateComponent component =
  case component of
    PositionComponent position ->
      PositionComponent position
    NoComponent ->
      component

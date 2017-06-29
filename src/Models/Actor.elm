module Models.Actor exposing (Actor)
import Services.Component exposing (Component(..))


type alias Actor =
  { id: Int
  , name: String
  , components: List Component
  }


-- Update stuff specific to Actors

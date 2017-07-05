module Models.Actor exposing (Actor)
import Services.Component exposing (Component(..))


type alias Actor =
  { id: Int
  , name: String
  }


-- Update stuff specific to Actors

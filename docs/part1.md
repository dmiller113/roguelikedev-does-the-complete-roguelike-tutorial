# Part 1, Elm
Hey! We got [Part1: Graphics](http://www.roguebasin.com/index.php?title=Complete_Roguelike_Tutorial,_using_python%2Blibtcod,_part_1) done already! But I realize that I've not actually explained any of the elm code so far, so lets correct that.

### Basics
Elm very much embraces as their main, and occasionally only, pattern what they call, the **Elm Architecture**. It is a pattern that you take a *Model* of the problem, a function that will *Update* that model through a change represented by a *Message*, and a function that creates a *View* from that Model.

So lets walk through each in this program.

### Model
```elm
type alias Model = (Int, Int)
```

Currently our model is very simple. Its a tuple of `Int`s representing the x, y position of the `@` on the `Rot.js` display.

```elm
type alias Delta = (Int, Int)
```
We also currently have a type representing a change in position. Its a tuple of ints such as (-1, 1), which represents a movement of 1 grid towards origin on the X line, with 1 grid away from the origin on the Y line.

### Update
```elm
type Msg = Reset
  | Tick Time
  | KeyDown KeyCode
```

Elm's update function accepts a `Msg` and a `Model` to return back a new `Model`. This is where we're defining what messages our program actually accepts to change its model. There's some vestiges of code that I think I'll need later (`Tick`, `Reset`).

```elm
update: Msg -> Model -> (Model, Cmd Msg)
```
This is the type signature for our `Update` function. Elm's syntax is a bit odd on this point because of the implicit currying of the function, but what it says is that its a function that takes a `Msg` and a `Model` and returns back a tuple containing a `Model` and a `Cmd Msg`. `Cmd Msg` are signals to other parts of your program, and seem to be analogous to events in vanilla js.

```elm
update msg model =
  case msg of
    Reset ->
      init
    Tick newTime ->
      (model, Cmd.none)
    KeyDown code ->
      let
        newPos = updatePosition model <| deltaPosition code
      in
        ( newPos, render (newPos, "@"))
```
A couple syntax notes.
* `<|` is a operator that takes the result of the right side and passes it to the left side.
* `case` statements are similar to switch statements but with much more capability to match on various attributes of the variable.
* `let/in` is a construct for local variables. `Let` blocks define variables that can be used in the matching `in` block.

Our `case` statement up there is matching the type of the `Message` that's being passed to the function, and directing the flow of execution to a specific section. Lets break it down.

* `Reset`: This is a message that would allow the program to return to the initial state that it started with. `init` is a `Model` state that the application starts with, and is defined above this section of the code.
* `Tick`: This is not currently used, but is called 24 times each second and will help with animations while waiting for input.
* `Keydown`: This message is raised whenever a key is pressed down, and is passed into this function with the keycode of the key being pressed. Lets take a look at `updatePosition`.

```elm
updatePosition: Model -> Delta -> Model
deltaPosition: KeyCode -> (Int, Int)
```
```elm
newPos = updatePosition model <| deltaPosition code
```

These two functions work together to go from a `Keycode` to a new `Model`.

### View
```elm
view: Model -> Html Msg
view model =
  div [] []
```
Our view function is pretty much a NOP. All of our rendering happens in our JS layer which is our interface to Rot.js.

### Subscriptions
So if you know anything about about elm, or most functional languages, they like referentially transparent, pure functions. Elm is no different, and forces your functions to be pure. You might say, "How can this be? You have a view function, and displaying things is a side effect". And you'd be right, except that the function we wrote didn't actually display anything. We wrote a function that provides a Html Msg type that the elm wrapper the elm wrapper then deals with the issues of displaying. So its technically pure, which is the best kind of pure.
So that's how elm handles display, what about user input which is another type of side effect that is common in games/programs. `Subscriptions` are the answer to that. `Subscriptions` are essentially events that you register to get notified of. Here's our subscriptions:

```elm
subscriptions model =
  Sub.batch
    [ Time.every (1000 / 24 * millisecond) Tick
    , downs KeyDown
    ]
```

`Sub.batch` is a function that groups together individual subscriptions into a request for a group of them. We register to be notified every `1000 / 24` milliseconds with a `Tick Msg`, and to be notified whenever a key down event would be triggered with a `KeyDown` `Msg`.

```elm
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
```

This is the function that ties all the different parts together. It takes an initial model state, a view function, and update function, and any subscriptions.

### Ports
```elm
port render: (Model, String) -> Cmd msg
```

This is our connection to normal JS code, and `Rot.js` in our case. Whenever I send this `Msg`, a subscribed function in JS land will call some of the display functions of `Rot.js`

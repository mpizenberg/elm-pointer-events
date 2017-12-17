module Main exposing (..)

{-| Multi touch example.

Compile using `elm-make Main.elm --output Main.js`

-}

import Html exposing (..)
import MultiTouch
import Touch


main : Program Never TouchEvent TouchEvent
main =
    beginnerProgram
        { model = None
        , update = \newEvent _ -> newEvent
        , view = view
        }


type TouchEvent
    = None
    | Start Touch.Event
    | Move Touch.Event
    | End Touch.Event
    | Cancel Touch.Event


view : TouchEvent -> Html TouchEvent
view event =
    div
        [ MultiTouch.onStart Start
        , MultiTouch.onMove Move
        , MultiTouch.onEnd End
        , MultiTouch.onCancel Cancel
        ]
        [ text <| toString event ]

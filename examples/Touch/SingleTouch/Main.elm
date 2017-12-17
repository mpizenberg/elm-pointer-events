module Main exposing (..)

{-| Single touch example.

Compile using `elm-make Main.elm --output Main.js`

-}

import Html exposing (..)
import SingleTouch
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
    | Start ( Float, Float )
    | Move ( Float, Float )
    | End ( Float, Float )
    | Cancel ( Float, Float )


view : TouchEvent -> Html TouchEvent
view event =
    div
        [ SingleTouch.onStart (Touch.clientPos >> Start)
        , SingleTouch.onMove (Touch.clientPos >> Move)
        , SingleTouch.onEnd (Touch.clientPos >> End)
        , SingleTouch.onCancel (Touch.clientPos >> Cancel)
        ]
        [ text <| toString event ]

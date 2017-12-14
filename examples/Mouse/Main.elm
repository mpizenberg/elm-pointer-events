module Main exposing (..)

import Html exposing (..)
import Mouse


main : Program Never MouseEvent MouseEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \newEvent _ -> newEvent
        }


type MouseEvent
    = None
    | Down Mouse.Event
    | Move Mouse.Event
    | Up Mouse.Event


view : MouseEvent -> Html MouseEvent
view event =
    div
        [ Mouse.onDown Down
        , Mouse.onMove Move
        , Mouse.onUp Up
        ]
        [ text <| toString event ]

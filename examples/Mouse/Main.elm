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
    | Click Mouse.Event
    | DoubleClick Mouse.Event
    | Over Mouse.Event
    | Out Mouse.Event
    | ContextMenu Mouse.Event


view : MouseEvent -> Html MouseEvent
view event =
    div []
        [ p
            [ Mouse.onDown Down
            , Mouse.onMove Move
            , Mouse.onUp Up
            , Mouse.onClick Click
            , Mouse.onDoubleClick DoubleClick
            , Mouse.onOver Over
            , Mouse.onOut Out
            , Mouse.onContextMenu ContextMenu
            ]
            [ text <| toString event ]
        ]

module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pointer


main : Program Never PointerEvent PointerEvent
main =
    beginnerProgram
        { model = None
        , view = view
        , update = \event _ -> event
        }


type PointerEvent
    = None
    | Down Pointer.Event
    | Move Pointer.Event
    | Up Pointer.Event


update : PointerEvent -> PointerEvent -> PointerEvent
update event _ =
    event


view : PointerEvent -> Html PointerEvent
view event =
    div
        [ Pointer.onDown Down
        , Pointer.onMove Move
        , Pointer.onUp Up

        -- no touch-action
        , style [ ( "touch-action", "none" ) ]

        -- elm PEP (polyfill) compatibility
        , attribute "elm-pep" "true"
        ]
        [ text <| toString event ]

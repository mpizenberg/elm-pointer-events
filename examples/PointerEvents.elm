module PointerEvents exposing (..)

import Html exposing (..)
import Html.Attributes as HtmlA
import Pointer


main : Program Never Model Msg
main =
    beginnerProgram
        { model = model
        , view = view
        , update = update
        }


type alias Model =
    { lastPointerEvent : PointerEvent }


type PointerEvent
    = None
    | Down Pointer.Event
    | Move Pointer.Event
    | Up Pointer.Event


model : Model
model =
    Model None


type Msg
    = PointerDown Pointer.Event
    | PointerMove Pointer.Event
    | PointerUp Pointer.Event


update : Msg -> Model -> Model
update msg model =
    case msg of
        PointerDown event ->
            Model (Down event)

        PointerMove event ->
            Model (Move event)

        PointerUp event ->
            Model (Up event)


view : Model -> Html Msg
view model =
    div
        (HtmlA.style [ ( "height", "100%" ) ] :: pointerEvents)
        [ viewPointerEvent model.lastPointerEvent ]


pointerEvents : List (Html.Attribute Msg)
pointerEvents =
    [ Pointer.onDown PointerDown
    , Pointer.onMove PointerMove
    , Pointer.onUp PointerUp

    -- no touch-action
    , HtmlA.style [ ( "touch-action", "none" ) ]

    -- PEP (polyfill) compatibility
    , HtmlA.attribute "touch-action" "none"
    ]


viewPointerEvent : PointerEvent -> Html msg
viewPointerEvent pointerEvent =
    case pointerEvent of
        None ->
            p [] [ text "No pointer event yet. Do some in this page." ]

        Down event ->
            p [] [ text "Down: ", text (toString event) ]

        Move event ->
            p [] [ text "Move: ", text (toString event) ]

        Up event ->
            p [] [ text "Up: ", text (toString event) ]

module MouseEvents exposing (..)

import Mouse
import Html exposing (..)
import Html.Attributes as HtmlA


main : Program Never Model Msg
main =
    beginnerProgram
        { model = model
        , view = view
        , update = update
        }


type alias Model =
    { lastMouseEvent : MouseEvent }


type MouseEvent
    = None
    | Down Mouse.Event
    | Move Mouse.Event
    | Up Mouse.Event


model : Model
model =
    Model None


type Msg
    = MouseDown Mouse.Event
    | MouseMove Mouse.Event
    | MouseUp Mouse.Event


update : Msg -> Model -> Model
update msg model =
    case msg of
        MouseDown event ->
            Model (Down event)

        MouseMove event ->
            Model (Move event)

        MouseUp event ->
            Model (Up event)


view : Model -> Html Msg
view model =
    div
        (HtmlA.style [ ( "height", "100%" ) ] :: mouseEvents)
        [ viewMouseEvent model.lastMouseEvent ]


mouseEvents : List (Html.Attribute Msg)
mouseEvents =
    [ Mouse.onDown MouseDown
    , Mouse.onMove MouseMove
    , Mouse.onUp MouseUp
    ]


viewMouseEvent : MouseEvent -> Html msg
viewMouseEvent mouseEvent =
    case mouseEvent of
        None ->
            p [] [ text "No mouse event yet. Do some in this page." ]

        Down event ->
            p [] [ text "Down: ", text (toString event) ]

        Move event ->
            p [] [ text "Move: ", text (toString event) ]

        Up event ->
            p [] [ text "Up: ", text (toString event) ]

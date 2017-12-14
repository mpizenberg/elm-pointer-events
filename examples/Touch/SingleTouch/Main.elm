module Main exposing (..)

{-| Single touch example.

Compile using `elm-make Main.elm --output Main.js`

-}

import Touch
import SingleTouch
import Html exposing (..)
import Html.Attributes as HtmlA


main : Program Never Model Msg
main =
    beginnerProgram
        { model = model
        , update = update
        , view = view
        }



-- MODEL #############################################################


type alias Model =
    { lastTouchEvent : TouchEvent }


type TouchEvent
    = None
    | Start ( Float, Float )
    | Move ( Float, Float )
    | End ( Float, Float )
    | Cancel ( Float, Float )


model : Model
model =
    Model None



-- UPDATE ############################################################


type Msg
    = TouchStart Touch.Coordinates
    | TouchMove Touch.Coordinates
    | TouchEnd Touch.Coordinates
    | TouchCancel Touch.Coordinates


update : Msg -> Model -> Model
update msg model =
    case msg of
        TouchStart coordinates ->
            Model (Start <| Touch.clientPos coordinates)

        TouchMove coordinates ->
            Model (Move <| Touch.clientPos coordinates)

        TouchEnd coordinates ->
            Model (End <| Touch.clientPos coordinates)

        TouchCancel coordinates ->
            Model (Cancel <| Touch.clientPos coordinates)



-- VIEW ##############################################################


view : Model -> Html Msg
view model =
    div
        (HtmlA.style [ ( "height", "100%" ) ] :: touchEvents)
        [ p [] [ text "Try to touch anywhere (only works on touch devices)" ]
        , p [] [ text <| toString model.lastTouchEvent ]
        ]


touchEvents : List (Html.Attribute Msg)
touchEvents =
    [ SingleTouch.onStart TouchStart
    , SingleTouch.onMove TouchMove
    , SingleTouch.onEnd TouchEnd
    , SingleTouch.onCancel TouchCancel
    ]

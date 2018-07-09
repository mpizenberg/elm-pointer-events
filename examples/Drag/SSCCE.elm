port module Main exposing (..)

import Browser
import Html exposing (Attribute, Html, div, p, text)
import Html.Events
import Json.Decode as Decode exposing (Value)


main : Program () () Msg
main =
    Browser.element
        { init = always ( (), Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- Update


type Msg
    = NoOp
    | PortMsg String Value


update : Msg -> () -> ( (), Cmd Msg )
update msg () =
    case msg of
        PortMsg eventName value ->
            ( (), valuePort value )

        _ ->
            ( (), Cmd.none )


port valuePort : Value -> Cmd msg



-- View


view : () -> Html Msg
view () =
    div [ valueOn "dragover" (PortMsg "dragover") ]
        [ p [ discard "dragleave" ] [] ]


valueOn : String -> (Value -> Msg) -> Attribute Msg
valueOn event tag =
    Html.Events.preventDefaultOn event <|
        Decode.map (\v -> ( tag v, True )) Decode.value


discard : String -> Attribute Msg
discard event =
    Html.Events.custom event <|
        Decode.succeed { message = NoOp, stopPropagation = True, preventDefault = True }

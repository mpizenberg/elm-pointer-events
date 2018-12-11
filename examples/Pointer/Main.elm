port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode


main : Program () Model Msg
main =
    Browser.element
        { init = always ( Nothing, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    Maybe Event


type Event
    = Down Pointer.Event
    | Move Pointer.Event
    | Up Pointer.Event
    | Cancel Pointer.Event


type Msg
    = EventMsg Event
    | RawDownMsg Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        EventMsg event ->
            ( Just event, Cmd.none )

        RawDownMsg value ->
            ( Decode.decodeValue Pointer.eventDecoder value
                |> Result.toMaybe
                |> Maybe.map Down
              -- use a port to "capture" pointer event
              -- since it requires JS function calls
            , capture value
            )


port capture : Value -> Cmd msg


view : Model -> Html Msg
view model =
    div []
        [ p
            [ Pointer.onUp (EventMsg << Up)
            , Pointer.onMove (EventMsg << Move)
            , Pointer.onCancel (EventMsg << Cancel)
            , msgOn "pointerdown" (Decode.map RawDownMsg Decode.value)
            ]
            [ text <| Debug.toString model ]
        ]


msgOn : String -> Decoder msg -> Attribute msg
msgOn event =
    Decode.map (\msg -> { message = msg, stopPropagation = True, preventDefault = True })
        >> Html.Events.custom event

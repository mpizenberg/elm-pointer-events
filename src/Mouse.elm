module Mouse
    exposing
        ( Coordinates
        , Event
        , Keys
        , eventDecoder
        , onDown
        , onMove
        , onUp
        , onWithOptions
        )

{-| Handling detailed mouse events.

@docs Event, Keys, Coordinates

@docs onDown, onMove, onUp, onWithOptions

@docs eventDecoder

-}

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)


-- MODEL #############################################################


{-| Type that get returned by a mouse event.
-}
type alias Event =
    { key : Keys
    , clientPos : Coordinates
    , offsetPos : Coordinates
    }


{-| The keys that might have been pressed during mouse event.
-}
type alias Keys =
    { alt : Bool, ctrl : Bool, shift : Bool }


{-| Coordinates of a mouse event.
-}
type alias Coordinates =
    ( Float, Float )



-- EVENTS ############################################################


{-| Listen to `mousedown` events.
-}
onDown : (Event -> msg) -> Attribute msg
onDown =
    onWithOptions "mousedown" stopOptions


{-| Listen to `mousemove` events.
-}
onMove : (Event -> msg) -> Attribute msg
onMove =
    onWithOptions "mousemove" stopOptions


{-| Listen to `mouseup` events.
-}
onUp : (Event -> msg) -> Attribute msg
onUp =
    onWithOptions "mouseup" stopOptions


{-| Choose the mouse event to listen to, and specify the event options.
-}
onWithOptions : String -> Events.Options -> (Event -> msg) -> Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions event options


stopOptions : Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }



-- DECODERS ##########################################################


{-| An `Event` decoder for mouse events.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map3 Event
        keyDecoder
        clientPosDecoder
        offsetPosDecoder


keyDecoder : Decoder Keys
keyDecoder =
    Decode.map3 Keys
        (Decode.field "altKey" Decode.bool)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)


clientPosDecoder : Decoder Coordinates
clientPosDecoder =
    Decode.map2 (,)
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


offsetPosDecoder : Decoder Coordinates
offsetPosDecoder =
    Decode.map2 (,)
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)

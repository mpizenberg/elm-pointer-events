module Pointer
    exposing
        ( Event
        , eventDecoder
        , onDown
        , onMove
        , onUp
        , onWithOptions
        )

{-| Handling pointer events.

@docs Event

@docs onDown, onMove, onUp, onWithOptions

@docs eventDecoder

-}

import Html
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Mouse


-- MODEL #############################################################


{-| Type that get returned by a pointer event.
-}
type alias Event =
    { isPrimary : Bool
    , pointerId : Int
    , pointer : Mouse.Event
    }



-- EVENTS ############################################################


{-| Listen to `pointerdown` events.
-}
onDown : (Event -> msg) -> Html.Attribute msg
onDown =
    onWithOptions "pointerdown" stopOptions


{-| Listen to `pointermove` events.
-}
onMove : (Event -> msg) -> Html.Attribute msg
onMove =
    onWithOptions "pointermove" stopOptions


{-| Listen to `pointerup` events.
-}
onUp : (Event -> msg) -> Html.Attribute msg
onUp =
    onWithOptions "pointerup" stopOptions


{-| Choose the mouse event to listen to, and specify the event options.
-}
onWithOptions : String -> Html.Events.Options -> (Event -> msg) -> Html.Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Html.Events.onWithOptions event options


stopOptions : Html.Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }



-- DECODERS ##########################################################


{-| An Event decoder for pointer events.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map3 Event
        (Decode.field "isPrimary" Decode.bool)
        (Decode.field "pointerId" Decode.int)
        Mouse.eventDecoder

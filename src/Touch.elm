-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Touch
    exposing
        ( Event
        , Keys
        , Touch
        , eventDecoder
        , onCancel
        , onEnd
        , onMove
        , onStart
        )

{-| Handling Touch events in elm.

@docs Event, Keys, Touch

@docs onStart, onMove, onEnd, onCancel

@docs eventDecoder

-}

import Dict exposing (Dict)
import Html
import Html.Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder)


{-| Touch event.
-}
type alias Event =
    { keys : Keys
    , changedTouches : Dict Int Touch
    , targetTouches : Dict Int Touch
    , touches : Dict Int Touch
    }


{-| Keys modifiers.
-}
type alias Keys =
    { alt : Bool
    , ctrl : Bool
    , shift : Bool
    }


{-| A Touch object.
-}
type alias Touch =
    { identifier : Int
    , clientPos : ( Float, Float )
    , pagePos : ( Float, Float )
    , screenPos : ( Float, Float )
    }



-- EVENTS ############################################################


{-| Triggered on a "touchstart" event.
-}
onStart : (Event -> msg) -> Html.Attribute msg
onStart =
    onWithOptions "touchstart" stopOptions


{-| Triggered on a "touchmove" event.
-}
onMove : (Event -> msg) -> Html.Attribute msg
onMove =
    onWithOptions "touchmove" stopOptions


{-| Triggered on a "touchend" event.
-}
onEnd : (Event -> msg) -> Html.Attribute msg
onEnd =
    onWithOptions "touchend" stopOptions


{-| Triggered on a "touchcancel" event.
-}
onCancel : (Event -> msg) -> Html.Attribute msg
onCancel =
    onWithOptions "touchcancel" stopOptions


onWithOptions : String -> Html.Events.Options -> (Event -> msg) -> Html.Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Html.Events.onWithOptions event options


stopOptions : Html.Events.Options
stopOptions =
    { preventDefault = True
    , stopPropagation = True
    }



-- DECODERS ##########################################################


{-| Touch event decoder.
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map4 Event
        Internal.Decode.keys
        (Decode.field "changedTouches" decodeTouchList)
        (Decode.field "targetTouches" decodeTouchList)
        (Decode.field "touches" decodeTouchList)


decodeTouchList : Decoder (Dict Int Touch)
decodeTouchList =
    Decode.field "length" Decode.int
        |> Decode.andThen decodeNbTouches


decodeNbTouches : Int -> Decoder (Dict Int Touch)
decodeNbTouches nbTouches =
    List.range 0 (nbTouches - 1)
        |> List.map (decodeOneTouch >> Decode.map touchTuple)
        |> Internal.Decode.all
        |> Decode.map Dict.fromList


decodeOneTouch : Int -> Decoder Touch
decodeOneTouch n =
    Decode.field (toString n) touchDecoder


touchTuple : Touch -> ( Int, Touch )
touchTuple touch =
    ( touch.identifier, touch )


touchDecoder : Decoder Touch
touchDecoder =
    Decode.map4 Touch
        (Decode.field "identifier" Decode.int)
        Internal.Decode.clientPos
        Internal.Decode.pagePos
        Internal.Decode.screenPos

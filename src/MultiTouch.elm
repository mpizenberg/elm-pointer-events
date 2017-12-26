-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module MultiTouch
    exposing
        ( onCancel
        , onEnd
        , onMove
        , onStart
        )

{-| This module exposes functions
to deal with multitouch interactions.

@docs onStart, onMove, onEnd, onCancel

-}

import Dict exposing (Dict)
import Html
import Html.Events as Events
import Internal.Decode
import Internal.Touch exposing (Touch)
import Json.Decode as Decode exposing (Decoder)
import Touch


{-| Triggered on a "touchstart" event.
-}
onStart : (Touch.Event -> msg) -> Html.Attribute msg
onStart tag =
    on "touchstart" tag


{-| Triggered on a "touchmove" event.
-}
onMove : (Touch.Event -> msg) -> Html.Attribute msg
onMove tag =
    on "touchmove" tag


{-| Triggered on a "touchend" event.
-}
onEnd : (Touch.Event -> msg) -> Html.Attribute msg
onEnd tag =
    on "touchend" tag


{-| Triggered on a "touchcancel" event.
-}
onCancel : (Touch.Event -> msg) -> Html.Attribute msg
onCancel tag =
    on "touchcancel" tag



-- HELPER FUNCTIONS ##################################################


on : String -> (Touch.Event -> msg) -> Html.Attribute msg
on event tag =
    Decode.map tag decodeTouchEvent
        |> Events.onWithOptions event Internal.Touch.stopOptions


decodeTouchEvent : Decoder Touch.Event
decodeTouchEvent =
    Decode.map3 Internal.Touch.Event
        (Decode.field "changedTouches" decodeTouchList)
        (Decode.field "targetTouches" decodeTouchList)
        (Decode.field "touches" decodeTouchList)


decodeTouchList : Decoder (Dict Int Touch.Coordinates)
decodeTouchList =
    Decode.field "length" Decode.int
        |> Decode.andThen decodeTouches


decodeTouches : Int -> Decoder (Dict Int Touch.Coordinates)
decodeTouches nbTouches =
    List.range 0 (nbTouches - 1)
        |> List.map (decodeTouch >> Decode.map Internal.Touch.toTuple)
        |> Internal.Decode.all
        |> Decode.map Dict.fromList


decodeTouch : Int -> Decoder Touch
decodeTouch n =
    Decode.field (toString n) Internal.Touch.decode

-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module MultiTouch
    exposing
        ( onStart
        , onMove
        , onEnd
        , onCancel
        )

{-| This module exposes functions
to deal with multitouch interactions.

@docs onStart, onMove, onEnd, onCancel

-}

import Html
import Html.Events as Events
import Touch
import Private.Touch exposing (Touch)
import Private.Decode
import Json.Decode as Decode exposing (Decoder)
import Dict exposing (Dict)


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
        |> Events.onWithOptions event Private.Touch.stopOptions


decodeTouchEvent : Decoder Touch.Event
decodeTouchEvent =
    Decode.map3 Private.Touch.Event
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
        |> List.map (decodeTouch >> Decode.map Private.Touch.toTuple)
        |> Private.Decode.all
        |> Decode.map Dict.fromList


decodeTouch : Int -> Decoder Touch
decodeTouch n =
    Decode.field (toString n) Private.Touch.decode

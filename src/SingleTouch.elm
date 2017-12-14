-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module SingleTouch
    exposing
        ( onStart
        , onMove
        , onEnd
        , onCancel
        )

{-| This module exposes functions
to deal with single touch interactions.

The coordinates provided are the ones of the first touch in the
["changedTouches"](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent) list.
As a consequence, it may behave inconsistently
in case of an accidental multitouch usage.
In case of a need for consistency with potential
unwanted multitouch interactions,
you might want to use the `MultiTouch` module which provides
finer grained control over the processing of the touch event.

@docs onStart, onMove, onEnd, onCancel

-}

import Html
import Html.Events as Events
import Touch
import Private.Touch
import Json.Decode as Decode exposing (Decoder)


{-| Triggered on a "touchstart" event.
-}
onStart : (Touch.Coordinates -> msg) -> Html.Attribute msg
onStart tag =
    on "touchstart" tag


{-| Triggered on a "touchmove" event.
-}
onMove : (Touch.Coordinates -> msg) -> Html.Attribute msg
onMove tag =
    on "touchmove" tag


{-| Triggered on a "touchend" event.
-}
onEnd : (Touch.Coordinates -> msg) -> Html.Attribute msg
onEnd tag =
    on "touchend" tag


{-| Triggered on a "touchcancel" event.
-}
onCancel : (Touch.Coordinates -> msg) -> Html.Attribute msg
onCancel tag =
    on "touchcancel" tag



-- HELPER FUNCTIONS ##################################################


on : String -> (Touch.Coordinates -> msg) -> Html.Attribute msg
on event tag =
    Decode.map tag decodeCoordinates
        |> Events.onWithOptions event Private.Touch.stopOptions


decodeCoordinates : Decoder Touch.Coordinates
decodeCoordinates =
    Private.Touch.decode
        |> Decode.at [ "changedTouches", "0" ]
        |> Decode.map .coordinates

-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Touch
    exposing
        ( Coordinates
        , Event
        , changedTouches
        , clientPos
        , targetTouches
        , touches
        )

{-| This module exposes types and functions
common to both single and multi touch interactions.

@docs Event, changedTouches, targetTouches, touches

@docs Coordinates, clientPos

-}

import Dict exposing (Dict)
import Internal.Touch


{-| Type alias for a touch event.

The properties `touches`, `targetTouches` and `changedTouches`
are accessible through their corresponding functions.

To have more info about these properties and how to use them,
please refer to the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/Events/touchstart)

-}
type alias Event =
    Internal.Touch.Event


{-| Retrieve the `changedTouches` property.

It returns a dictionary whose keys are the unique identifiers
of the touches.

-}
changedTouches : Event -> Dict Int Coordinates
changedTouches =
    .changedTouches


{-| Retrieve the `targetTouches` property.

It returns a dictionary whose keys are the unique identifiers
of the touches.

-}
targetTouches : Event -> Dict Int Coordinates
targetTouches =
    .targetTouches


{-| Retrieve the `touches` property.

It returns a dictionary whose keys are the unique identifiers
of the touches.

-}
touches : Event -> Dict Int Coordinates
touches =
    .touches


{-| A simple type alias for the coordinates of a JavaScript
[Touch](https://developer.mozilla.org/en-US/docs/Web/API/Touch) object.
-}
type alias Coordinates =
    Internal.Touch.Coordinates


{-| Retrieve the clientX and clientY coordinates.
-}
clientPos : Coordinates -> ( Float, Float )
clientPos coordinates =
    ( .clientX coordinates, .clientY coordinates )

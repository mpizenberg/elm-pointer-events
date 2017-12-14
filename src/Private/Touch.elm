-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Private.Touch exposing (..)

{-| This module exposes internally types and constants
common to both single and multi touch interactions.
-}

import Json.Decode as Decode exposing (Decoder)
import Html.Events
import Dict exposing (Dict)


type alias Event =
    { changedTouches : Dict Int Coordinates
    , targetTouches : Dict Int Coordinates
    , touches : Dict Int Coordinates
    }


type alias Touch =
    { identifier : Int
    , coordinates : Coordinates
    }


type alias Coordinates =
    { clientX : Float
    , clientY : Float
    }


toTuple : Touch -> ( Int, Coordinates )
toTuple touch =
    ( touch.identifier, touch.coordinates )


decode : Decoder Touch
decode =
    Decode.map2 Touch
        (Decode.field "identifier" Decode.int)
        (Decode.map2 Coordinates
            (Decode.field "clientX" Decode.float)
            (Decode.field "clientY" Decode.float)
        )


stopOptions : Html.Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }

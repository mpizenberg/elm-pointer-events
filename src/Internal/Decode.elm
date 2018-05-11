-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Internal.Decode exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Keys =
    { alt : Bool
    , ctrl : Bool
    , shift : Bool
    }


dynamicListOf : Decoder a -> Decoder (List a)
dynamicListOf itemDecoder =
    let
        decodeN n =
            List.range 0 (n - 1)
                |> List.map decodeOne
                |> all

        decodeOne n =
            Decode.field (String.fromInt n) itemDecoder
    in
    Decode.field "length" Decode.int
        |> Decode.andThen decodeN


all : List (Decoder a) -> Decoder (List a)
all =
    List.foldr (Decode.map2 (::)) (Decode.succeed [])


keys : Decoder Keys
keys =
    Decode.map3 Keys
        (Decode.field "altKey" Decode.bool)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)


clientPos : Decoder ( Float, Float )
clientPos =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


offsetPos : Decoder ( Float, Float )
offsetPos =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


pagePos : Decoder ( Float, Float )
pagePos =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


screenPos : Decoder ( Float, Float )
screenPos =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "screenX" Decode.float)
        (Decode.field "screenY" Decode.float)

port module DragPorts exposing (dragover, dragstart)

import Json.Decode exposing (Value)


port dragstart : { effectAllowed : String, event : Value } -> Cmd msg


port dragover : { dropEffect : String, event : Value } -> Cmd msg

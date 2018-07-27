module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Events.Extra.Drag as Drag
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (class, id)
import Json.Decode as Decode exposing (Value)
import List
import Ports


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Model =
    { dragAndDropStatus : DragAndDropStatus
    , tasks : Dict Int Task
    }


type DragAndDropStatus
    = NoDnD
    | Dragging Int


type Task
    = Task ProgressStatus String


type ProgressStatus
    = ToDo
    | Doing
    | Done


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { dragAndDropStatus = NoDnD
    , tasks =
        Dict.fromList
            [ ( 1, Task ToDo "Bake a cake" )
            , ( 2, Task ToDo "Go for a run" )
            , ( 3, Task ToDo "Pet the cat" )
            , ( 4, Task ToDo "Watch that episode before I get spoiled!" )
            , ( 5, Task ToDo "Sleep, yes really!" )
            ]
    }



-- Update


type Msg
    = DragStart Int Drag.EffectAllowed Value
    | DragEnd
    | DragOver Drag.DropEffect Value
    | Drop ProgressStatus


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.dragAndDropStatus ) of
        ( DragStart id effectAllowed value, _ ) ->
            ( { model | dragAndDropStatus = Dragging id }
            , Ports.dragstart (Drag.startPortData effectAllowed value)
            )

        ( DragEnd, _ ) ->
            ( { model | dragAndDropStatus = NoDnD }, Cmd.none )

        ( DragOver dropEffect value, _ ) ->
            ( model, Ports.dragover (Drag.overPortData dropEffect value) )

        ( Drop status, Dragging id ) ->
            let
                newTasks =
                    Dict.update id (maybeSetStatus status) model.tasks
            in
            ( { model | tasks = newTasks }, Cmd.none )

        _ ->
            ( model, Cmd.none )


maybeSetStatus : ProgressStatus -> Maybe Task -> Maybe Task
maybeSetStatus status maybeTask =
    case maybeTask of
        Just (Task _ instruction) ->
            Just (Task status instruction)

        _ ->
            maybeTask



-- View


view : Model -> Html Msg
view model =
    div [ id "kanban" ]
        [ div
            (class "kanban-area" :: id "todo" :: Drag.onDropTarget (dropTargetConfig ToDo))
            (h1 [] [ text "To Do" ] :: viewTasks ToDo model.tasks)
        , div
            (class "kanban-area" :: id "doing" :: Drag.onDropTarget (dropTargetConfig Doing))
            (h1 [] [ text "Doing" ] :: viewTasks Doing model.tasks)
        , div
            (class "kanban-area" :: id "done" :: Drag.onDropTarget (dropTargetConfig Done))
            (h1 [] [ text "Done" ] :: viewTasks Done model.tasks)
        ]


dropTargetConfig : ProgressStatus -> Drag.DropTargetConfig Msg
dropTargetConfig status =
    { dropEffect = Drag.MoveOnDrop
    , onOver = DragOver
    , onDrop = always (Drop status)
    , onEnter = Nothing
    , onLeave = Nothing
    }


viewTasks : ProgressStatus -> Dict Int Task -> List (Html Msg)
viewTasks status tasks =
    tasks
        |> Dict.filter (\_ task -> progressStatus task == status)
        |> Dict.toList
        |> List.map viewOneTask


progressStatus : Task -> ProgressStatus
progressStatus (Task status _) =
    status


viewOneTask : ( Int, Task ) -> Html Msg
viewOneTask ( id, Task status instruction ) =
    p (class "task" :: Drag.onSourceDrag (draggedSourceConfig id)) [ text instruction ]


draggedSourceConfig : Int -> Drag.DraggedSourceConfig Msg
draggedSourceConfig id =
    { effectAllowed = { move = True, copy = False, link = False }
    , onStart = DragStart id
    , onEnd = always DragEnd
    , onDrag = Nothing
    }

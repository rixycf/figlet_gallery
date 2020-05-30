module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, cols, rows, value)
import Html.Events exposing (onInput)



-- Model


type alias Model =
    { input : String, figletFont : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "", Cmd.none )



-- Updatee


type Msg
    = Input String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ Html.form []
            [ input [ value model.input, onInput Input ] []
            ]
        , div [ class "textarea" ] [ textarea [ rows 30, cols 100 ] [ text model.input ] ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }

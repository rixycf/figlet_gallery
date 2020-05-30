module Main exposing (main)

import Browser
import Html exposing (..)


type alias Model =
    { input : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "", Cmd.none )


type Msg
    = Input String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text "hello" ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }

port module Main exposing (main)

import Browser
import FontList
import GeneratedFigList
import Html exposing (..)
import Html.Attributes exposing (autofocus, class, cols, href, id, placeholder, readonly, rows, selected, type_, value)
import Html.Events as Events exposing (onClick, onInput)
import Json.Decode as Json



-- Model


type alias Model =
    { figletGenerator : FigletGenerator
    , gallery : Gallery
    }


type alias FigletGenerator =
    { figletOp : FigletOp
    , receiveFiglet : String
    , fontList : List String
    }


type alias Gallery =
    { figletOp : FigletOp
    , receiveFiglet : String
    , fontList : List String
    , figList : List String
    }


type alias FigletOp =
    { inputText : String
    , font : String
    , horizontalLayout : String
    , verticalLayout : String
    }


initFigletOp : FigletOp
initFigletOp =
    FigletOp "Welcome!" "ANSI Shadow" "dafault" "dafault"


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        (FigletGenerator initFigletOp initFigletChars FontList.fontList)
        (Gallery initFigletOp "" FontList.fontList GeneratedFigList.generatedFigList)
    , Cmd.none
    )



-- Updatee


type Msg
    = Input String
    | ReceiveFiglet String
    | SelectFont String
    | GalleryInput String
    | GalleryReceiveFig String
    | Click String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            let
                figOp =
                    model.figletGenerator.figletOp

                newFigOp =
                    { figOp | inputText = input }

                figletGenerator =
                    model.figletGenerator

                newFigGen =
                    { figletGenerator | figletOp = newFigOp }
            in
            ( { model | figletGenerator = newFigGen }, inputFigletJS newFigOp )

        SelectFont newFont ->
            let
                figOp =
                    model.figletGenerator.figletOp

                newFigOp =
                    { figOp | font = newFont }

                figletGenerator =
                    model.figletGenerator

                newFigGen =
                    { figletGenerator | figletOp = newFigOp }
            in
            ( { model | figletGenerator = newFigGen }, inputFigletJS newFigOp )

        ReceiveFiglet figlet ->
            let
                figGen =
                    model.figletGenerator

                newFigGen =
                    { figGen | receiveFiglet = figlet }
            in
            ( { model | figletGenerator = newFigGen }, Cmd.none )

        GalleryInput input ->
            let
                figOp =
                    model.gallery.figletOp

                newFigOp =
                    { figOp | inputText = input }

                gallery =
                    model.gallery

                newGallery =
                    { gallery | figletOp = newFigOp }
            in
            ( { model | gallery = newGallery }, galleryInputFigletJS newFigOp )

        GalleryReceiveFig figlet ->
            let
                gallery =
                    model.gallery

                newGallery =
                    { gallery | receiveFiglet = figlet }
            in
            ( { model | gallery = newGallery }, Cmd.none )

        Click newFont ->
            let
                figOp =
                    model.gallery.figletOp

                newFigOp =
                    { figOp | inputText = "", font = newFont }

                gallery =
                    model.gallery

                newGallery =
                    { gallery | figletOp = newFigOp }
            in
            ( { model | gallery = newGallery }, galleryInputFigletJS newFigOp )



-- View


view : Model -> Html Msg
view model =
    let
        handler selectedValue =
            SelectFont selectedValue

        half =
            round (toFloat (List.length model.figletGenerator.fontList) / 2)
    in
    div []
        [ header []
            [ pre []
                [ text titleFig
                ]
            , h2 [] [ text "\"Figlet Generator\" generate ASCII art" ]
            ]
        , div [ class "FigletGenerator" ]
            [ text "Font"
            , select [ onChange handler ] (List.map pullDownMenu model.figletGenerator.fontList)
            , h3 [] [ text "TextField" ]
            , Html.form []
                [ textarea [ autofocus True, value model.figletGenerator.figletOp.inputText, onInput Input, rows 4, cols 40 ] [] ]
            , h2 [] [ text "Result" ]
            , textarea [ class "resultArea", rows 15, cols 80, readonly True ] [ text model.figletGenerator.receiveFiglet ]
            ]
        , h2 [] [ text "---- Gallery ----" ]
        , div [ class "row" ]
            [ div [ class "column" ]
                (List.map2
                    figletSample
                    (List.take half model.gallery.fontList)
                    (List.take half model.gallery.figList)
                )
            , div
                [ class "column" ]
                (List.map2
                    figletSample
                    (List.drop half model.gallery.fontList)
                    (List.drop half model.gallery.figList)
                )
            ]
        , div [ class "modal-wrapper", id "modal" ]
            [ a [ href "#!", class "modal-overlay" ] []
            , div [ class "modal-window" ]
                [ div [ class "modal-content" ]
                    [ h2 [] [ text "textarea" ]
                    , textarea [ value model.gallery.figletOp.inputText, onInput GalleryInput, rows 5, cols 40 ] []
                    , h2 [] [ text "Result" ]
                    , textarea [ readonly True, rows 20, cols 70 ] [ text model.gallery.receiveFiglet ]
                    ]
                , a [ href "#!", class "modal-close" ] []
                ]
            ]
        ]


figletSample : String -> String -> Html Msg
figletSample fontName fig =
    div [ class "sample_figlet" ]
        [ text fontName
        , a [ onClick (Click fontName), href "#modal" ] [ pre [] [ text fig ] ]
        ]


onChange : (String -> msg) -> Attribute msg
onChange handler =
    Events.on "change" (Json.map handler Events.targetValue)


pullDownMenu : String -> Html Msg
pullDownMenu font =
    option [ value font ] [ text font ]



-- Main


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Port


port inputFigletJS : FigletOp -> Cmd msg


port galleryInputFigletJS : FigletOp -> Cmd msg


port receiveFiglet : (String -> msg) -> Sub msg


port receiveGalleryFig : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveFiglet ReceiveFiglet
        , receiveGalleryFig GalleryReceiveFig
        ]



-- Internal


titleFig : String
titleFig =
    """
 ███████████  ███           ████            █████   
░░███░░░░░░█ ░░░           ░░███           ░░███    
 ░███   █ ░  ████   ███████ ░███   ██████  ███████  
 ░███████   ░░███  ███░░███ ░███  ███░░███░░░███░   
 ░███░░░█    ░███ ░███ ░███ ░███ ░███████   ░███    
 ░███  ░     ░███ ░███ ░███ ░███ ░███░░░    ░███ ███
 █████       █████░░███████ █████░░██████   ░░█████ 
░░░░░       ░░░░░  ░░░░░███░░░░░  ░░░░░░     ░░░░░  
                   ███ ░███                         
                  ░░██████                          
                   ░░░░░░                           
   █████████                                                    █████                      
  ███░░░░░███                                                  ░░███                       
 ███     ░░░   ██████  ████████    ██████  ████████   ██████   ███████    ██████  ████████ 
░███          ███░░███░░███░░███  ███░░███░░███░░███ ░░░░░███ ░░░███░    ███░░███░░███░░███
░███    █████░███████  ░███ ░███ ░███████  ░███ ░░░   ███████   ░███    ░███ ░███ ░███ ░░░ 
░░███  ░░███ ░███░░░   ░███ ░███ ░███░░░   ░███      ███░░███   ░███ ███░███ ░███ ░███     
 ░░█████████ ░░██████  ████ █████░░██████  █████    ░░████████  ░░█████ ░░██████  █████    
  ░░░░░░░░░   ░░░░░░  ░░░░ ░░░░░  ░░░░░░  ░░░░░      ░░░░░░░░    ░░░░░   ░░░░░░  ░░░░░     

    """


initFigletChars : String
initFigletChars =
    """
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                              
    """

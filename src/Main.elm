port module Main exposing (main)

import Array
import Browser
import FontList
import GeneratedFigList
import Html exposing (..)
import Html.Attributes exposing (autofocus, class, cols, href, id, placeholder, readonly, rows, selected, type_, value, wrap)
import Html.Events as Events exposing (onClick, onInput)
import Json.Decode as Json
import Random



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
    | Copy
    | Random
    | NewSelect Int


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

        Copy ->
            ( model, copyGenResult () )

        Random ->
            ( model, Random.generate NewSelect (Random.int 0 (List.length FontList.fontList)) )

        NewSelect num ->
            let
                arrayFontList =
                    Array.fromList model.figletGenerator.fontList

                newFont =
                    arrayFontList |> Array.get num |> Maybe.withDefault "Standard.flf"

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
            , select [ onChange handler ] (pullDownMenu model)
            , button [ onClick Copy ] [ text "copy" ]
            , button [ onClick Random ] [ text "random" ]
            , h3 [] [ text "TextField" ]
            , Html.form []
                [ textarea [ autofocus True, value model.figletGenerator.figletOp.inputText, onInput Input, rows 4, cols 40 ] [] ]
            , h2 [] [ text "Result" ]
            , textarea [ id "generatedResult", rows 15, cols 80, readonly True, wrap "off" ] [ text model.figletGenerator.receiveFiglet ]
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
                    , Html.form []
                        [ textarea [ value model.gallery.figletOp.inputText, onInput GalleryInput, rows 5, cols 40 ] []
                        ]
                    , h2 [] [ text "Result" ]
                    , button [ onClick Copy ] [ text "copy" ]
                    , textarea [ readonly True, rows 20, cols 70, wrap "off" ] [ text model.gallery.receiveFiglet ]
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


pullDownMenu : Model -> List (Html Msg)
pullDownMenu model =
    let
        selectedFont =
            model.figletGenerator.figletOp.font

        fontList =
            model.figletGenerator.fontList
    in
    List.map (\font -> option [ value font, selected (selectedFont == font) ] [ text font ]) fontList



-- option [ value font, selected (selectedFont == font) ] [ text font ]
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


port copyGenResult : () -> Cmd msg


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

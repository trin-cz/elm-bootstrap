module Bootstrap.Modal
    exposing
        ( modal
        , hiddenState
        , visibleState
        , small
        , large
        , State
        , ModalOption
        )

import Html
import Html.Attributes as Attr
import Html.Events as Events
import Bootstrap.Internal.Grid as GridInternal exposing (ScreenSize(..))


type State
    = State Bool


type ModalOption
    = ModalSize GridInternal.ScreenSize



small : ModalOption
small =
    ModalSize Small


large : ModalOption
large =
    ModalSize Large


hiddenState : State
hiddenState =
    State False


visibleState : State
visibleState =
    State True


modal :
    { closeMsg : State -> msg
    , header : Maybe (Html.Html msg)
    , body : Maybe (Html.Html msg)
    , footer : Maybe (Html.Html msg)
    , options : List ModalOption
    }
    -> State
    -> Html.Html msg
modal { closeMsg, header, body, footer, options } state =
    Html.div
        []
        ([ Html.div
            ([ Attr.tabindex -1 ] ++ display state)
            [ Html.div
                (Attr.attribute "role" "document" :: modalAttributes options)
                [ Html.div
                    [ Attr.class "modal-content" ]
                    (modalHeader closeMsg header
                        :: List.filterMap
                            modalItem
                            [ ( "modal-body", body ), ( "modal-footer", footer ) ]
                    )
                ]
            ]
        ] ++  backdrop state)


display : State -> List (Html.Attribute msg)
display (State open) =
    [ Attr.style
        [ ( "display", ifElse open "block" "none" ) ]
    , Attr.classList
        [ ("modal", True)
        , ("fade", True)
        , ("show", open)
        ]
    ]


modalAttributes : List ModalOption -> List (Html.Attribute msg)
modalAttributes options =
    Attr.class "modal-dialog"
        :: (List.map modalClass options
                |> List.filterMap identity
           )


modalClass : ModalOption -> Maybe (Html.Attribute msg)
modalClass option =
    case option of
        ModalSize size ->
            case GridInternal.screenSizeOption size of
                Just s ->
                    Just <| Attr.class <| "modal-" ++ s

                Nothing ->
                    Nothing


modalHeader : (State -> msg) -> Maybe (Html.Html msg) -> Html.Html msg
modalHeader closeMsg maybeHeader =
    Html.div
        [ Attr.class "modal-header" ]
        ([ closeButton closeMsg ]
            ++ case maybeHeader of
                Just header ->
                    [ header ]

                Nothing ->
                    []
        )


modalItem : ( String, Maybe (Html.Html msg) ) -> Maybe (Html.Html msg)
modalItem ( itemClass, maybeItem ) =
    case maybeItem of
        Just item ->
            Just <| Html.div [ Attr.class itemClass ] [ item ]

        Nothing ->
            Nothing


closeButton : (State -> msg) -> Html.Html msg
closeButton closeMsg =
    Html.button
        [ Attr.class "close", Events.onClick (closeMsg hiddenState) ]
        [ Html.text "x" ]


backdrop : State -> List (Html.Html msg)
backdrop ((State open) as state) =
    if open then
        [ Html.div
            [ Attr.class "modal-backdrop fade show" ]
            []
        ]
    else
        []



ifElse : Bool -> a -> a -> a
ifElse pred true false =
    if pred then
        true
    else
        false

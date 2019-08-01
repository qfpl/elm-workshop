module Main exposing (main)

import Browser
import Debug
import Generated.Api as BE
import Html as H
import Html.Attributes as HA
import Html.Attributes.Aria as HAA
import Html.Events as HE
import Http
import RemoteData exposing (RemoteData)
import Utils


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type Msg
    = HandleLoginResp (Result Http.Error String)


type alias Model =
    { backendOK : Bool
    , backendError : Maybe String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { backendOK = True
      , backendError = Nothing
      }
    , BE.postApiLogin (BE.DbPlayer "user1" "pass") HandleLoginResp
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        HandleLoginResp (Ok r) ->
            ( { model | backendOK = True, backendError = Nothing }, Cmd.none )

        HandleLoginResp (Err err) ->
            ( { model | backendError = Just "Backend login failed", backendOK = False }, Cmd.none )


view : Model -> H.Html Msg
view model =
    H.div []
        [ H.h1 [] [ H.text "Hello World" ]
        , H.text
            (if model.backendOK then
                "Login Worked. All good!"

             else
                "Login Failed. Check network tab."
            )
        ]

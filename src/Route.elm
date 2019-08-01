module Route exposing (Route(..), parser, pushRoute, routeLink)

import Browser.Navigation as Nav
import Html as H
import Html.Attributes as HA
import Url.Builder exposing (absolute)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string, top)


type Route
    = Login
    | Register
    | Lobby
    | Game Int


routeLink : Route -> List (H.Html a) -> H.Html a
routeLink r =
    H.a [ HA.href (toString r) ]


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Lobby top
        , map Register (s "register")
        , map Login (s "login")
        , map Game (s "game" </> int)
        ]


toString : Route -> String
toString r =
    case r of
        Login ->
            absolute [ "login" ] []

        Register ->
            absolute [ "register" ] []

        Lobby ->
            absolute [] []

        Game gId ->
            absolute [ "game", String.fromInt gId ] []


pushRoute : Nav.Key -> Route -> Cmd a
pushRoute k =
    toString >> Nav.pushUrl k

module Utils exposing (disabledIfLoading, httpErrorToStr, maybe, maybeIsNothing, maybeToList, remoteDataError)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Http
import Json.Decode
import RemoteData


disabledIfLoading : RemoteData.RemoteData e a -> H.Attribute msm
disabledIfLoading m =
    HA.disabled (RemoteData.isLoading m)


remoteDataError : RemoteData.RemoteData e a -> Maybe e
remoteDataError rd =
    case rd of
        RemoteData.Failure e ->
            Just e

        _ ->
            Nothing


maybe : b -> (a -> b) -> Maybe a -> b
maybe z f =
    Maybe.map f >> Maybe.withDefault z


maybeIsNothing : Maybe a -> Bool
maybeIsNothing =
    maybe True (always False)


maybeToList : Maybe a -> List a
maybeToList =
    maybe [] List.singleton


httpErrorToStr : Http.Error -> String
httpErrorToStr err =
    case err of
        Http.BadUrl s ->
            "Bad URL: " ++ s

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus s ->
            "Bad Status" ++ String.fromInt s

        Http.BadBody s ->
            "Bad Body" ++ s

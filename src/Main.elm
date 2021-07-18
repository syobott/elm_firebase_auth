--module Main exposing (..)


port module Main exposing
    ( Model
    , Msg(..)
    , init
    , main
    , signingInWithEmailAndPassword
    , update
    , validateAuthState
    , view
    )

import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }



--- PORTS ---


port signingInWithEmailAndPassword : Encode.Value -> Cmd msg


port validateAuthState : (String -> msg) -> Sub msg



---- MODEL ----


type AuthState
    = SignedOut --サインアウト
    | SignedIn --サインイン
    | SignedInWithError --認証失敗


type alias EmailAndPassword =
    { email : String
    , password : String
    }


type alias Model =
    { authState : AuthState
    , emailAndPassword : EmailAndPassword
    }


initialModel : Model
initialModel =
    { authState = SignedOut
    , emailAndPassword =
        { email = ""
        , password = ""
        }
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type AuthMsg
    = SignIn


type ChangedEmailAndPasswordMsg
    = EmailChanged String
    | PasswordChanged String


type ValidateAuthStateMsg
    = ValidateAuthState String


type Msg
    = AuthMsg AuthMsg
    | ChangedEmailAndPasswordMsg ChangedEmailAndPasswordMsg
    | ValidateAuthStateMsg ValidateAuthStateMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthMsg tryToAuthMsg ->
            updateAuth tryToAuthMsg model

        ChangedEmailAndPasswordMsg changedEmailAndPasswordMsg ->
            updateEmailAndPassword changedEmailAndPasswordMsg model

        ValidateAuthStateMsg validateAuthMsg ->
            updateValidateAuth validateAuthMsg model



-- エンコードした文字列をportに引数として渡す


updateAuth : AuthMsg -> Model -> ( Model, Cmd Msg )
updateAuth msg model =
    case msg of
        SignIn ->
            ( model, signingInWithEmailAndPassword <| loginInfoEncoder model )



-- emailとpasswordのエンコード


loginInfoEncoder : Model -> Encode.Value
loginInfoEncoder model =
    Encode.object
        [ ( "email", Encode.string model.emailAndPassword.email )
        , ( "password", Encode.string model.emailAndPassword.password )
        ]


updateEmailAndPassword : ChangedEmailAndPasswordMsg -> Model -> ( Model, Cmd Msg )
updateEmailAndPassword msg model =
    let
        emailAndPassword =
            model.emailAndPassword
    in
    case msg of
        EmailChanged email ->
            ( { model | emailAndPassword = { emailAndPassword | email = email } }
            , Cmd.none
            )

        PasswordChanged password ->
            ( { model | emailAndPassword = { emailAndPassword | password = password } }
            , Cmd.none
            )



--受け取った文字列に応じてauthStateを更新する


updateValidateAuth : ValidateAuthStateMsg -> Model -> ( Model, Cmd Msg )
updateValidateAuth msg model =
    case msg of
        ValidateAuthState authState ->
            case authState of
                "SignedOut" ->
                    ( { model | authState = SignedOut }
                    , Cmd.none
                    )

                "SignedIn" ->
                    ( { model | authState = SignedIn }
                    , Cmd.none
                    )

                "SignedInWithError" ->
                    ( { model | authState = SignedInWithError }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )



-- SUBSCRIPTIUONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ validateAuthState ValidateAuthState
            |> Sub.map ValidateAuthStateMsg
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Firebase Authentication" ]
        , Html.map ChangedEmailAndPasswordMsg (viewEmail model)
        , Html.map ChangedEmailAndPasswordMsg (viewPassword model)
        , Html.map AuthMsg viewLoginButton
        , viewValidateSignIn model
        ]


viewEmail : Model -> Html ChangedEmailAndPasswordMsg
viewEmail model =
    div []
        [ input
            [ onInput EmailChanged
            , value model.emailAndPassword.email
            , placeholder "User or Email"
            ]
            []
        ]


viewPassword : Model -> Html ChangedEmailAndPasswordMsg
viewPassword model =
    div []
        [ input
            [ type_ "password"
            , onInput PasswordChanged
            , value model.emailAndPassword.password
            , placeholder "Password"
            ]
            []
        ]


viewLoginButton : Html AuthMsg
viewLoginButton =
    div []
        [ button [ onClick SignIn ] [ text "SignIn" ] ]


viewValidateSignIn : Model -> Html Msg
viewValidateSignIn model =
    case model.authState of
        SignedOut ->
            div []
                [ div [] [ text "Status: SignOut" ]
                ]

        SignedIn ->
            div []
                [ div [] [ text "Status: SiginIn" ] ]

        SignedInWithError ->
            div []
                [ div [] [ text "Status: ERROR" ] ]

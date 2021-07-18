import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";
import firebase from "firebase/app";
import "firebase/analytics";
import "firebase/auth";
import "firebase/firestore";

// ここが異なるかも
const app = Elm.Main.init({
  node: document.getElementById("root"),
});

const firebaseConfig = {
  // 各自のapi key等を記載してください
};

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();

// firebaseの初期化
firebase.initializeApp(firebaseConfig);
const Googleprovider = new firebase.auth.GoogleAuthProvider();
const DB = firebase.firestore();

app.ports.signingInWithEmailAndPassword.subscribe((input) => {
  firebase
    .auth()
    //emailとpasswordを受け取る
    .signInWithEmailAndPassword(input.email, input.password)
    .then((_) => {
      //認証が成功すれば、"SignedIn"をElmに送信
      app.ports.validateAuthState.send("SignedIn");
    })
    .catch((error) => {
      //認証が失敗すれば、"SignedInWithError"をElmに送信
      app.ports.validateAuthState.send("SignedInWithError");
    });
});

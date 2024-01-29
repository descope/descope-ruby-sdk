import React from "react";
import ReactDOM from 'react-dom/client';
import App from "./App";
import reportWebVitals from '../reportWebVitals';
import { AuthProvider } from '@descope/react-sdk'
import '../App.css';

document.addEventListener("turbo:load", () => {
    document.body.innerHTML = '<div id="root"></div>';
    const root = ReactDOM.createRoot(document.getElementById("root"));

    root.render(
        <React.StrictMode>
            <AuthProvider projectId={process.env.REACT_APP_PROJECT_ID}>
                <App />
            </AuthProvider>
        </React.StrictMode>
    );
});

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
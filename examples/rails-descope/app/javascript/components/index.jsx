import React from "react";
import ReactDOM from 'react-dom/client';
import '../App.css';
import App from "./App";
import { AuthProvider } from '@descope/react-sdk'


document.addEventListener("turbo:load", () => {
    const root = ReactDOM.createRoot(document.body.appendChild(document.createElement("div")));

    root.render(
        <React.StrictMode>
            <AuthProvider
                projectId="P2aVGmQvQzSLJwP3ttcxO12tmQXk"
            >
                <App />
            </AuthProvider>
        </React.StrictMode>
    );
});
import '../App.css';
import React, { useEffect } from "react";
import { Descope, useSession, useUser } from '@descope/react-sdk'
import { useNavigate } from "react-router-dom";


function Login() {
    // isAuthenticated: boolean - is the user authenticated?
    // isSessionLoading: boolean - Use this for showing loading screens while objects are being loaded
    const { isAuthenticated, isSessionLoading } = useSession()
    // isUserLoading: boolean - Use this for showing loading screens while objects are being loaded
    const { isUserLoading } = useUser()
    const navigate = useNavigate()

    useEffect(() => {
        if (isAuthenticated) {
            return navigate("/profile");
        }
    }, [isAuthenticated]) // listen for when isAuthenticated has changed

    return (
        <div className='page'>
            {
                (isSessionLoading || isUserLoading) && <p>Loading...</p>
            }

            {!isAuthenticated &&
                (
                    <>
                        <h1 className='title'>Login/SignUp to see the Secret Message!</h1>
                        <Descope
                            flowId="sign-up-or-in"
                            onSuccess = {(e) => console.log(e.detail.user)}
                            onError={(e) => console.log('Could not log in! ' + e.detail.error)}
                            theme="light"
                        />
                    </>
                )
            }
        </div>
    )
}


export default Login;

import React from "react";
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import { getSessionToken } from '@descope/react-sdk';
import '../App.css';

function Dashboard() {
    const sessionToken = getSessionToken(); // get the session token
    const navigate = useNavigate()
    const [roles, setRoles] = useState({
        teacherRole: false,
        studentRole: false
    })

    useEffect(() => {
        fetch('/get_role_data', { // call the api endpoint from the flask server
            headers: {
                Accept: 'application/json',
                Authorization: 'Bearer ' + sessionToken,
            }
        }).then(data => {
            if (data.status === 401) {
                navigate('/login')
            }
            return data.json()
        }).then(jsonData => {
            setRoles({
                teacherRole: jsonData.valid_teacher,
                studentRole: jsonData.valid_student
            })
        }).catch((err) => {
            console.log(err)
            navigate('/login')
        })
    }, [])

    return (
        <div className='page'>
            <h1 className='title'>Dashboard</h1>
            <Link className='link btn' to="/profile">Profile</Link>
            {roles.teacherRole && (
                <div className='page'>
                    <h1>Welcome back Teacher!</h1>
                    <p className='students'>You have 50+ students currently 🧑‍🎓</p>
                </div>
            )}
            {roles.studentRole && (
                <div className='page'>
                    <h1>Welcome back Student!</h1>
                    <p className='student'>Unlucky! You have homework!</p>
                    <iframe src="https://giphy.com/embed/H9UeFGxZz4cBG" width="469" height="480" allowFullScreen></iframe>
                </div>
            )}
        </div>
    )
}


export default Dashboard;
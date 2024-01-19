import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "../components/Home";
import Login from "../components/Login";
import Profile from "../components/Profile";
import Dashboard from "../components/Dashboard";

export default (
    <Router>
        <Routes>
            <Route path="/" element={<Home />} />
            <Route path='/login' element={<Login />} />
            <Route path='/profile' element={<Profile />} />
            <Route path='/dashboard' element={<Dashboard />} />
        </Routes>
    </Router>
);
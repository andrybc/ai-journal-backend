import {useNavigate } from "react-router";

const handleLogout = () => {
    const navigate = useNavigate();

    localStorage.removeItem("userId");
    localStorage.removeItem("username");
    localStorage.removeItem("token");
    navigate("/login");
  };

  export default handleLogout;
import { BrowserRouter, Routes, Route, Navigate } from "react-router";

import Login from "./pages/Login";
import SignUp from "./pages/SignUp";
import Relationships from "./pages/Relationships";
import EmailVerify from "./pages/EmailVerify";
import ForgotPassword from "./pages/ForgotPwd";
import ResetPassword from "./pages/ResetPassword";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/notes" replace />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<SignUp />} />
        <Route path="/relationships" element={<Relationships />} />
        <Route path="/verify-email" element={<EmailVerify />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/reset-password" element={<ResetPassword />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

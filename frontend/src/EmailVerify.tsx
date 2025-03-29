import { useNavigate } from "react-router";
import Navbar from "./components/Navbar";
import { useState, useEffect } from "react";

const EmailVerify = () => {
  const navigate = useNavigate();
  const [message, setMessage] = useState("Verifying your email...");
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get("token");

    if (!token) {
      setErrorMessage("No verification token found in the URL");
      return;
    }

    handleVerify(token);
  }, []);

  const handleVerify = async (token: string) => { 
    try {
      const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:3000/api"; // Fallback
      console.log("API URL for verify:", apiUrl);

      const response = await fetch(
        `${apiUrl}/auth/verify-email?token=${token}`, // Use GET with query param
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
        },
      );

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `Verification failed: ${response.status} - ${errorText || "No details"}`,
        );
      }

      const data = await response.json();
      console.log("Email successfully verified:", data.message);
      setMessage("Email verified successfully! Redirecting to login...");
      setTimeout(() => navigate("/login"), 2000);
    } catch (error) {
      console.error("Email verification failed:", error);
      if (error instanceof Error) {
        setErrorMessage(error.message);
      } else {
        setErrorMessage("An unexpected error occurred");
      }
    }
  };

  return (
    <div className="fixed inset-0 flex flex-col justify-center items-center bg-neutral-900">
      <div className="w-full fixed top-0 left-0">
        <Navbar />
      </div>
      <div className="bg-neutral-700 w-96 p-6 rounded-xl shadow-md flex flex-col items-center">
        <h2 className="text-2xl font-bold text-white mb-4">Verify Your Email</h2>
        <p className="text-neutral-100 text-center mb-4">{message}</p>
        {errorMessage && (
          <p className="text-sm text-red-600 mb-4">{errorMessage}</p>
        )}
      </div>
    </div>
  );
};

export default EmailVerify;
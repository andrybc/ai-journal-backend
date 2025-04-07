import { useNavigate } from "react-router";


const searchJournal = async (query: string) => {
  const userID = localStorage.getItem("userId");
  const token = localStorage.getItem("token");
  const navigate = useNavigate();
  if (!userID || !token) {
    console.error("User ID or Auth Token is missing.");
    navigate("/login");
    return null;
  }

  try {
    const response = await fetch(
      `${import.meta.env.VITE_API_URL}/journal/search?userId=${userID}&query=${encodeURIComponent(query)}`,
      {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      },
    );

    if (!response.ok) {
      const errorText = await response.json();
      throw new Error(
        `Server error ${response.status}: ${errorText || "No details"}`,
      );
    }

    const data = await response.json();
    console.log(data.message);


    return data.notebooks;
  } catch (error) {
    console.error("Error:", error);
    alert("An error occurred while fetching the journals.");
    return null;
  }
};

export default searchJournal;

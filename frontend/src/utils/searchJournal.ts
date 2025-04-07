const searchJournal = async (query: string) => {
  const userID = localStorage.getItem("userId");
  const token = localStorage.getItem("token");
  if (!userID || !token) {
    console.error("User ID or Auth Token is missing.");
    window.location.href = '/login';
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

import SideNav from "../components/SideNavNote"; //import the SideNav component
import { useEffect, useState } from "react"; //import some hooks
import SimpleMDE from "react-simplemde-editor"; //import SimpleMDE text editor
import "easymde/dist/easymde.min.css"; //import SimpleMDE styles

//icons
import closeSideNav from "../assets/icons/close-nav-icon.svg";
import SaveNoteIcon from "../assets/icons/save-note-icon.svg";
import DeleteNoteIcon from "../assets/icons/delete-note-icon.svg";

const Notes = () => {
  const [sideNavOpen, setSideNavOpen] = useState<boolean>(true); //state to control SideNav visibility
  const [selectedNote, setSelectedNote] = useState<{
    //state to manipulate such selected note
    title: string;
    content: string;
    existingNoteFlag: number; //0 if it's a new note, 1 if it's an existing note
    updateFlag: number; //0 if it's a new note, 1 if it's an existing note
    notebookId: string; //optional notebook ID
    updateDelete: number; //0 if it's a new note, 1 if it's an existing note
  } | null>(null);

  //function to either retrieve the selected note or create a new one (SideNav)
  const getSelectedNote = async (id: string) => {
    const userID = localStorage.getItem("userId");

    if (userID === null) {
      console.error("User ID is not available in local storage.");
      return;
    }

    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/journal/read-notebook/${id}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(
          `Server error ${response.status}: ${errorText || "No details"}`
        );
      }
      const data = await response.json();
      console.log(data.message);
      console.log(data.notebook);

      setSelectedNote(data.notebook);
    } catch (error) {
      console.error("Error:", error);
      alert("An error occurred while fetching the journals.");
    }
  };

  useEffect(() => {
    //display a new note when the page loads
    createNewNote();
  }, []);

  const createNewNote = () => {
    setSelectedNote({
      title: "Untitled Note",
      existingNoteFlag: 0,
      content: "",
      updateFlag: 0,
      updateDelete: 0,
      notebookId: "",
    });
  };

  //HANDLE SAVE----------------------------------------------------------------
  const handleSave = async () => {
    const userID = localStorage.getItem("userId");
    const token = localStorage.getItem("token");
    // if (!token) {
    //   console.error("Token is not available in local storage.");
    //   return;
    // }
    if (!userID) {
      console.error("User ID is not available in local storage.");
      return;
    }

    if (selectedNote?.existingNoteFlag === 0) {
      //establish in order to use "selectedNotes"
      try {
        //start the API call
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/create-notebook`, //call "create-notebook" API
          {
            method: "POST", //use POST method
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`, //use the token from localStorage
            },
            body: JSON.stringify({
              title: selectedNote.title,
              content: selectedNote.content,
              userId: userID,
            }),
          }
        );

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
        console.log(data.notebook);

        setSelectedNote((prev) =>
          prev
            ? {
                ...prev,
                existingNoteFlag: 1,
                notebookId: data.notebook._id, //store the notebook ID
                updateFlag: 0, //create a new indicator to help with the update manipulation
                updateDelete: 0, //create a new indicator to help with the delete manipulation
              }
            : null
        );
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    }
  }; //END OF HANDLESAVE--------------------------------------------------------------------

  //HANDLE UPDATE--------------------------------------------------------------------------
  const handleUpdate = async () => {
    const token = localStorage.getItem("token");
    //before calling the API, set the content with the latest additions from the text editor
    if (selectedNote?.updateFlag === 0) {
      //this means that I am updating an note I JUST created
      try {
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/update-notebook/${
            //caall "update-notebook" API
            selectedNote?.notebookId
          }`,
          {
            method: "PUT",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(selectedNote),
          }
        );

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
        console.log(data.notebook);

        setSelectedNote((prev) =>
          prev
            ? {
                ...prev,
                updateFlag: 1, //update the updateFlag to 1
              }
            : null
        );
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    } else {
      //when flag is 1, it means that I am updating an existing note (helpful when selecting one from the SideNav)
      try {
        const response = await fetch(
          `${
            import.meta.env.VITE_API_URL
          }/journal/update-notebook/${localStorage.getItem("notebookId")}`, //use localStorage to get the notebookId
          {
            method: "PUT",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(selectedNote),
          }
        );

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
        console.log(data.notebook);

        setSelectedNote((prev) =>
          prev
            ? {
                ...prev,
                updateDelete: 1, //update the updateDelete flag to 1
              }
            : null
        );
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    }
  }; //END OF HANDLE UPDATE--------------------------------------------------------------------------

  //HANDLE DELETE---------------------------------------------------------------------------
  const handleDelete = async () => {
    const token = localStorage.getItem("token");
    if (selectedNote?.updateDelete === 0) {
      try {
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/delete-notebook/${
            selectedNote?.notebookId
          }`, // Use the notebookId from selectedNotes to delete the specific note
          {
            method: "DELETE", // Use DELETE method
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
              notebookId: selectedNote?.notebookId,
            }),
          }
        );

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    } else {
      //when the updateDelete flag is 1, it means that I am deleting an existing note (helpful when selecting one from the SideNav)
      try {
        const response = await fetch(
          `${
            import.meta.env.VITE_API_URL
          }/journal/delete-notebook/${localStorage.getItem("notebookId")}`, //use localStorage to get the notebookId
          {
            method: "DELETE",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
              notebookId: localStorage.getItem("notebookId"), //same notebookId from localStorage
            }),
          }
        );

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    }
  };
  //END OF HANDLE DELETE--------------------------------------------------------------------------

  //START OF GET ALL JOURNALS---------------------------------------------------------------------
  //END OF GET ALL JOURNALS---------------------------------------------------------------------

  //return the components created
  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && ( //if the SideNav is set to open, display it
        <SideNav
          createNewNote={createNewNote}
          getSelectedNote={getSelectedNote}
          page="Notes"
          closeNav={setSideNavOpen}
        />
      )}

      <div //main content area
        className={`flex flex-col h-full grow sm:overflow-y-auto ${
          sideNavOpen && "overflow-y-hidden"
        }`}
      >
        <div //header area
          className={`px-2.5 py-2.5 flex items-center border-b ${
            sideNavOpen && "sm:hidden"
          }`}
        >
          <button //button to open/close the SideNav
            className="p-1 rounded-lg hover:bg-gray-200 cursor-pointer"
            onClick={() => setSideNavOpen(true)}
          >
            <img //icon to open/close the SideNav
              className="w-[25px] h-[25px] rotate-180"
              src={closeSideNav}
              alt="Open Navbar Icon"
            />
          </button>
          <span className="grow text-center ml-[-33px] font-semibold text-lg">
            Notes
          </span>
        </div>

        {selectedNote ? ( //condition so "selectedNotes" can be manipulated
          <div
            className={`px-10 ${
              //padding for the main content area
              sideNavOpen ? "sm:px-10" : "sm:px-14"
            } md:px-14 py-8 ${
              sideNavOpen ? "sm:py-8" : "sm:py-12"
            } md:py-12 flex flex-col gap-5 max-w-4xl mx-auto`}
          >
            <input //input field for the note title
              type="text"
              placeholder="Enter Title Here..." //placeholder text
              className="text-4xl font-semibold font-montserrat"
              value={selectedNote.title || ""} //use the title from selectedNotes
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                //use onChange along with React.ChangeEvent to modify the title
                setSelectedNote((prev) =>
                  prev ? { ...prev, title: e.target.value } : null
                );
              }}
            />

            <SimpleMDE //text editor
              value={selectedNote.content} //use the content from selectedNotes
              onChange={(value: string) => {
                setSelectedNote((prev) =>
                  prev ? { ...prev, content: value } : prev
                );
              }}
              options={{
                spellChecker: false,
                placeholder: "Write your notes here...", //placeholder text
                toolbar: [
                  //get rid of unnecessary tools
                  "bold",
                  "|",
                  "italic",
                  "|",
                  "heading",
                  "|",
                  "quote",
                  "|",
                  "unordered-list",
                  "|",
                  "ordered-list",
                  "|",
                  "preview",
                  "|",
                ],
              }}
            />
            <div className="relative">
              <div className="absolute top-4 right-4 flex gap-2">
                <button //Save Button
                  className={`p-1 rounded-lg cursor-pointer hover:bg-gray-200 ${
                    !selectedNote.content ? "opacity-50 cursor-not-allowed" : ""
                  }`}
                  onClick={
                    selectedNote?.existingNoteFlag === 0 //depending on flag, we save it or update it
                      ? handleSave
                      : handleUpdate
                  }
                  disabled={
                    //disable the button if the title is empty
                    selectedNote?.title === "" || selectedNote?.content === ""
                  }
                >
                  <img //icon for button
                    src={SaveNoteIcon}
                    alt="Save Icon"
                    className="w-[40px] h-[35px]"
                  />
                </button>

                <button //Delete Button
                  className="p-1 rounded-lg hover:bg-gray-200 cursor-pointer"
                  onClick={() => {
                    handleDelete();
                    createNewNote();
                  }}
                >
                  <img
                    src={DeleteNoteIcon}
                    alt="Delete Icon"
                    className="w-[35px] h-[35px]"
                  />
                </button>
              </div>
            </div>
          </div>
        ) : (
          <div className="h-full p-8 flex flex-col justify-center items-center gap-5 text-center"></div>
        )}
      </div>
    </div>
  );
};

export default Notes;

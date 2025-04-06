import SideNav from "../components/SideNavNote"; //import the SideNav component
import { useEffect, useState, useRef } from "react"; //import some hooks
import SimpleMDE from "react-simplemde-editor"; //import SimpleMDE text editor
import "easymde/dist/easymde.min.css"; //import SimpleMDE styles

//icons
import closeSideNav from "../assets/icons/close-nav-icon.svg";
import SaveNoteIcon from "../assets/icons/save-note-icon.svg";
import DeleteNoteIcon from "../assets/icons/delete-note-icon.svg";
import debounce from "lodash.debounce";

const Notes = () => {
  const [sideNavOpen, setSideNavOpen] = useState<boolean>(true); //state to control SideNav visibility
  const [selectedNotes, setSelectedNotes] = useState<{
    //state to manipulate such selected note
    title: string;
    existingNoteFlag: number; //0 if it's a new note, 1 if it's an existing note
    content?: string;
    [key: string]: string | number | boolean | undefined; //allows properties of any type
  } | null>(null);

  //useRef is useful for storing values that don't need to trigger a re-render
  const editorContentRef = useRef<string>(""); //reference to the editor content

  const [displayList, setDisplayList] = useState<
    //hook to view the stored notes in SideNav
    { notebookId: string; notebookTitle: string }[] //establish for title and id of "notebook" from API
  >([]);

  //userID of the logged-in user
  const userID = localStorage.getItem("userId");
  //token
  const token = localStorage.getItem("token");

  //TEST TEST TEST
  /*const debouncedUpdate = useRef(
    debounce((value: string) => {
      setSelectedNotes((prev) =>
        prev
          ? {
              ...prev,
              content: value, //update the content in the state
            }
          : null
      );
    }, 1000) //adjust the debounce delay as needed
  ).current;*/

  //function to either get retrieve the selected note or create a new one (SideNav)
  const getSelectedNotes = (existingNoteFlag: number) => {
    if (existingNoteFlag === -1) {
      // If -1, create a new note
      createNewNote();
    } else {
      //save the current editor content to the current note before switching
      setSelectedNotes((prev) =>
        prev
          ? {
              ...prev,
              content: editorContentRef.current, //content updated with the latest additions
            }
          : null
      );

      setTimeout(() => {
        //ensure the content is stored properly before switching to another note
        setSelectedNotes({
          title: localStorage.getItem("journalTitle") || "",
          content: localStorage.getItem("journalContent") || "",
          existingNoteFlag: 1,
        });
        editorContentRef.current = localStorage.getItem("journalContent") || ""; //sync editor content
      }, 0);
    }
  };

  useEffect(() => {
    //display a new note when the page loads
    createNewNote();
    getAllJournals(); //call the API to get all the notes in order to display them in the SideNav
  }, []);

  const createNewNote = () => {
    //function to create a new note
    editorContentRef.current = ""; //initialize and/or refresh the editor content
    setSelectedNotes({
      title: "Untitled Note",
      existingNoteFlag: 0,
      content: "",
    });
  };

  //HANDLE SAVE----------------------------------------------------------------
  const handleSave = async () => {
    const updatedContent = editorContentRef.current;

    //before calling the API, we set content with the latest additions from the text editor
    setSelectedNotes((prev) =>
      prev
        ? {
            ...prev,
            content: updatedContent,
          }
        : null
    );
    if (selectedNotes?.existingNoteFlag === 0) {
      //establish in order to use "selectedNotes"
      if (userID === null) {
        //make sure userID is not null
        console.error("User ID is not available in local storage.");
        return;
      }
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
              title: selectedNotes.title, //use the title note
              content: updatedContent, //use the updated content from the editor
              userId: userID, //use the userID from local storage
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

        setSelectedNotes((prev) =>
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
    getAllJournals(); //call the API to get all the notes in order to display them in the SideNav
  }; //END OF HANDLESAVE--------------------------------------------------------------------

  //HANDLE UPDATE--------------------------------------------------------------------------
  const handleUpdate = async () => {
    const updatedContent = editorContentRef.current;
    //before calling the API, set the content with the latest additions from the text editor
    setSelectedNotes((prev) =>
      prev
        ? {
            ...prev,
            content: updatedContent,
          }
        : null
    );

    if (selectedNotes?.updateFlag === 0) {
      //this means that I am updating an note I JUST created
      try {
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/update-notebook/${
            //caall "update-notebook" API
            selectedNotes?.notebookId
          }`,
          {
            method: "PUT",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              title: selectedNotes?.title,
              content: updatedContent, //use the updated content from the editor
              notebookId: selectedNotes?.notebookId, //use the same notebookId
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

        setSelectedNotes((prev) =>
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
            },
            body: JSON.stringify({
              title: selectedNotes?.title,
              content: updatedContent,
              notebookId: localStorage.getItem("notebookId"), //get notebookId from localStorage
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

        setSelectedNotes((prev) =>
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
    getAllJournals(); //call the API to get all the notes in order to display them in the SideNav
  }; //END OF HANDLE UPDATE--------------------------------------------------------------------------

  //HANDLE DELETE---------------------------------------------------------------------------
  const handleDelete = async () => {
    if (selectedNotes?.updateDelete === 0) {
      try {
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/delete-notebook/${
            selectedNotes?.notebookId
          }`, // Use the notebookId from selectedNotes to delete the specific note
          {
            method: "DELETE", // Use DELETE method
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              notebookId: selectedNotes?.notebookId,
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

    createNewNote(); //create a new note after deleting the current one
    getAllJournals(); //call the API to get all the notes in order to update in the SideNav
  };
  //END OF HANDLE DELETE--------------------------------------------------------------------------

  //START OF GET ALL JOURNALS---------------------------------------------------------------------
  const getAllJournals = async () => {
    if (userID === null) {
      //make sure we have a userID stored
      console.error("User ID is not available in local storage.");
      return;
    }

    try {
      //start the API call
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/journal/all/${userID}`, //use the userID in localStorage
        {
          method: "GET", //use GET method
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

      setDisplayList(
        data.notebooks.map((notebook: { _id: string; title: string }) => ({
          notebookId: notebook._id,
          notebookTitle: notebook.title,
        }))
      );

      console.log(data.message);
    } catch (error) {
      console.error("Error:", error);
      alert("An error occurred while fetching the journals.");
    }
  };
  //END OF GET ALL JOURNALS---------------------------------------------------------------------

  //return the components created
  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && ( //if the SideNav is set to open, display it
        <SideNav
          getSelectedItem={getSelectedNotes}
          page="Notes"
          closeNav={setSideNavOpen}
          displayList={displayList}
          setDisplayList={setDisplayList}
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

        {selectedNotes ? ( //condition so "selectedNotes" can be manipulated
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
              value={selectedNotes.title || ""} //use the title from selectedNotes
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                //use onChange along with React.ChangeEvent to modify the title
                setSelectedNotes(
                  (
                    prev //call the setSelectedNotes function
                  ) =>
                    prev
                      ? {
                          ...prev,
                          title: e.target.value, //update the title
                          content: editorContentRef.current, //keep the content updated
                        }
                      : null
                );
              }}
            />

            <SimpleMDE //text editor
              value={selectedNotes.content || ""} //use the content from selectedNotes
              onChange={(value: string) => {
                //use onChange to modify the content
                editorContentRef.current = value; //use the useRef to store the content, to later on update it
                setSelectedNotes((prev) =>
                  prev
                    ? {
                        ...prev,
                        content: value, //update the content in the state
                      }
                    : null
                );
                //debouncedUpdate(value); //call the debounced function to update the content
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
                    !selectedNotes.content
                      ? "opacity-50 cursor-not-allowed"
                      : ""
                  }`}
                  onClick={
                    selectedNotes?.existingNoteFlag === 0 //depending on flag, we save it or update it
                      ? handleSave
                      : handleUpdate
                  }
                  disabled={
                    //disable the button if the title is empty
                    selectedNotes?.title === "" || selectedNotes?.content === ""
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
                  onClick={handleDelete}
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

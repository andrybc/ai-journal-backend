import SideNav from "../components/SideNav";
import { useEffect, useState, useCallback } from "react";
import closeSideNav from "../assets/icons/close-nav-icon.svg";
import SimpleMDE from "react-simplemde-editor";
import "easymde/dist/easymde.min.css"; // Import SimpleMDE styles
import { debounce } from "lodash";

const Notes = () => {
  const [sideNavOpen, setSideNavOpen] = useState<boolean>(true);
  const [selectedNotes, setSelectedNotes] = useState<{
    title: string;
    id: number;
    content?: string;
    [key: string]: string | number | boolean | undefined;
  } | null>(null);

  const getSelectedNotes = (id: number) => {
    if (id === -1) {
      createNewNote();
    } /*else {
      setSelectedNotes({
        title: "",
        id,
        content: "",
      });
    }*/
  };

  useEffect(() => {
    createNewNote();
  }, []);

  const createNewNote = () => {
    setSelectedNotes({
      title: "Untitled Note",
      id: 0,
      content: "Hello",
    });
  };

  const handleSave = async () => {
    if (selectedNotes?.id === 0) {
      try {
        const API_URL = "http://localhost:3000";
        const response = await fetch(`${API_URL}/journal/create-notebook`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            title: selectedNotes.title,
            content: selectedNotes.content,
            userId: "507f191e810c19729de860ea",
          }),
        });

        if (!response.ok) {
          const errorText = await response.text();
          throw new Error(
            `Server error ${response.status}: ${errorText || "No details"}`
          );
        }
        const data = await response.json();
        console.log(data.message);
        console.log(data.verificationToken);
        console.log(data.notebook);

        if (data.verificationToken) {
          localStorage.setItem("verificationToken", data.verificationToken);
        }
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }

      console.log("New note created");
    } /*else {
      //IF note already exists, simply update its content
      try {
        const response = await fetch(
          `${import.meta.env.VITE_API_URL}/journal/update-notebook`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              title: selectedNotes?.title,
              content: selectedNotes?.content,
              userId: selectedNotes?.id,
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
        console.log(data.verificationToken);

        if (data.verificationToken) {
          localStorage.setItem("verificationToken", data.verificationToken);
        }
      } catch (error) {
        console.error("Error:", error);
        alert("An error occurred while saving the note.");
      }
    }*/
  };

  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && (
        <SideNav
          getSelectedItem={getSelectedNotes}
          page="Notes"
          closeNav={setSideNavOpen}
        />
      )}

      <div
        className={`flex flex-col h-full grow sm:overflow-y-auto ${
          sideNavOpen && "overflow-y-hidden"
        }`}
      >
        <div
          className={`px-2.5 py-2.5 flex items-center border-b ${
            sideNavOpen && "sm:hidden"
          }`}
        >
          <button
            className="p-1 rounded-lg hover:bg-gray-200 cursor-pointer"
            onClick={() => setSideNavOpen(true)}
          >
            <img
              className="w-[25px] h-[25px] rotate-180"
              src={closeSideNav}
              alt="Open Navbar Icon"
            />
          </button>
          <span className="grow text-center ml-[-33px] font-semibold text-lg">
            Notes
          </span>
        </div>

        {selectedNotes ? (
          <div
            className={`px-10 ${
              sideNavOpen ? "sm:px-10" : "sm:px-14"
            } md:px-14 py-8 ${
              sideNavOpen ? "sm:py-8" : "sm:py-12"
            } md:py-12 flex flex-col gap-5 max-w-4xl mx-auto`}
          >
            <input
              type="text"
              placeholder="Journal Title"
              className="text-4xl font-semibold font-montserrat"
              value={selectedNotes.title}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                setSelectedNotes((prev) =>
                  prev
                    ? {
                        ...prev,
                        title: e.target.value,
                      }
                    : null
                );
              }}
            />
            <SimpleMDE
              value={selectedNotes.content || ""}
              onChange={
                debounce((value: string) => {
                  setSelectedNotes((prev) =>
                    prev
                      ? {
                          ...prev,
                          content: value,
                        }
                      : null
                  );
                }, 300) // Debounce to limit the number of updates
              }
              options={{
                spellChecker: false,
                placeholder: "Write your notes here...",
              }}
            />
            {/* Save Button */}
            <div className="flex justify-end">
              <button
                className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                onClick={handleSave}
              >
                Save
              </button>
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

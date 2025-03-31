import SideNav from "../components/SideNav";
import { useState } from "react";
import closeSideNav from "../assets/icons/close-nav-icon.svg";
import ghostIcon from "../assets/icons/ghost-icon.svg";

const Relationships = () => {
  const [sideNavOpen, setSideNavOpen] = useState<boolean>(true);
  const [selectedRelationship, setSelectedRelationship] = useState<{
    name: string;
    id: number;
    [key: string]: string | number | boolean;
  } | null>(null);
  const userId = 1;

  const searchProfiles = async (query: string) => {
    try {
      const response = await fetch(
        `${
          import.meta.env.VITE_API_URL
        }/profile/search?userId=${userId}&query=${encodeURIComponent(query)}`,
        {
          method: "GET",
        },
      );

      if (!response.ok) {
        const errorMessage = await response.json();
        throw new Error(
          errorMessage.error || "Unexpected error while searching for profiles",
        );
      }

      const responseData = await response.json();
      console.log(responseData.message);

      console.log(responseData.profiles);
    } catch (error) {
      console.error(error);
    }
  };

  const getSelectedRelationship = async (profileId: number) => {
    try {
      const response = await fetch(
        `${import.meta.env.VITE_API_URL}/profile/${userId}/${profileId}`,
      );

      if (!response.ok) {
        const errorMessage = await response.json();
        throw new Error(
          errorMessage.error || "Unexpected error while retrieving profile",
        );
      }

      const responseData = await response.json();
      console.log(responseData.message);

      setSelectedRelationship(responseData.profile);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && (
        <SideNav
          getSelectedItem={getSelectedRelationship}
          page="Relationships"
          closeNav={setSideNavOpen}
          searchItems={searchProfiles}
        />
      )}

      <div
        className={`flex flex-col h-full grow sm:overflow-y-auto ${
          sideNavOpen ? "overflow-y-hidden" : "overflow-y-auto"
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
            Relationship
          </span>
        </div>

        {selectedRelationship ? (
          <div
            className={`px-10 ${
              sideNavOpen ? "sm:px-10" : "sm:px-14"
            } md:px-14 py-8 ${
              sideNavOpen ? "sm:py-8" : "sm:py-12"
            } md:py-12 flex flex-col gap-5 max-w-4xl mx-auto w-full`}
          >
            <h3 className="text-4xl font-semibold font-montserrat">
              {selectedRelationship.name}
            </h3>
            <span className="text-[18px]/[1.6]">
              {selectedRelationship.summary}
            </span>
          </div>
        ) : (
          <div className="h-full p-8 flex flex-col justify-center items-center gap-5 text-center">
            <img
              className="w[75px] h-[75px]"
              src={ghostIcon}
              alt="Ghost Icon"
            />
            <h3 className="font-semibold font-montserrat text-2xl">
              No Profile is Selected
            </h3>
          </div>
        )}
      </div>
    </div>
  );
};

export default Relationships;

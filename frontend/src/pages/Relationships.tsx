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

  const getSelectedRelationship = (id: number) => {
    console.log(id);
    setSelectedRelationship({
      name: "John Doe",
      id: 1,
      summary: `John Doe is a name that has long been associated with anonymity, mystery, and adaptability. Used widely in legal, medical, and fictional contexts, John Doe can represent an unidentified individual, a person seeking to keep their identity secret, or even a symbol of the everyday, average person. Over time, the name has evolved beyond its practical applications and taken on a cultural significance, appearing in literature, film, and media as an archetype of the unknown or forgotten man.  

In legal and medical settings, John Doe (or Jane Doe for females) is a placeholder used when an individual's real name is unknown or cannot be disclosed. This practice dates back centuries and is still commonly employed today in court cases, autopsies, and police investigations. Whether it is an unidentified body, a witness who wishes to remain anonymous, or a defendant whose identity is unknown, the name John Doe serves as a neutral stand-in, allowing proceedings to move forward without revealing sensitive or unavailable information.  

Beyond legal and administrative use, John Doe has taken on a broader cultural and symbolic role. In fiction, he is often depicted as an everyman character—someone without distinguishing traits or a unique identity, representing the common person in society. At the same time, John Doe can also be used to portray someone shrouded in mystery, an individual with a hidden past, a secret identity, or even a person who has been erased from public records. In crime dramas, thrillers, and conspiracy narratives, the name is frequently attached to characters who either do not remember their past or are deliberately concealed from the world.  

In the realm of psychological and philosophical discussions, John Doe serves as a symbol of the faceless masses, the countless individuals who go unnoticed in the grand scheme of history. His identity—or lack thereof—raises questions about individuality, anonymity, and the significance of a name. It also touches on themes of existentialism, as a person labeled "John Doe" may struggle with their own sense of self, especially if the name is imposed upon them due to circumstances beyond their control.  

Despite his anonymity, John Doe is paradoxically well-known. The name is instantly recognizable and understood across different cultures and contexts. Whether he is the victim of a crime, a witness seeking protection, or a protagonist in a gripping mystery, John Doe remains one of the most famous unknown figures in history. His identity may be uncertain, but his presence is undeniably significant.`,
    });
  };

  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && (
        <SideNav
          getSelectedItem={getSelectedRelationship}
          page="Relationships"
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
            Relationship
          </span>
        </div>

        {selectedRelationship ? (
          <div
            className={`px-10 ${
              sideNavOpen ? "sm:px-10" : "sm:px-14"
            } md:px-14 py-8 ${
              sideNavOpen ? "sm:py-8" : "sm:py-12"
            } md:py-12 flex flex-col gap-5 max-w-4xl mx-auto`}
          >
            <h3 className="text-4xl font-semibold font-montserrat">
              {selectedRelationship.name}
            </h3>
            <span className="text-[18px]/[1.45]">
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

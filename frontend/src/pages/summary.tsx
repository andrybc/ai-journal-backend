import { useState } from "react";
import SideNav from "../components/SideNav";
import { useEffect, useRef } from "react";

const Summary = () => {
  const [sideNavOpen, setSideNavOpen] = useState<boolean>(true);
  const [selectedSummary, setSelectedSummary] = useState<number | null>(null);
  const summarySectionRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const disableBodyScroll = () => {
      if (summarySectionRef.current) {
        if (sideNavOpen && window.innerWidth < 640) {
          summarySectionRef.current.style.overflowY = "hidden";
        } else {
          summarySectionRef.current.style.overflowY = "auto";
        }
      }
    };

    disableBodyScroll();
    window.addEventListener("resize", disableBodyScroll);

    return () => {
      window.addEventListener("resize", disableBodyScroll);
    };
  }, [sideNavOpen]);

  return (
    <div className="flex h-dvh overflow-hidden">
      {sideNavOpen && (
        <SideNav
          page="Summary"
          selectedItem={selectedSummary}
          closeNav={setSideNavOpen}
          setSelectedItem={setSelectedSummary}
        />
      )}

      <div ref={summarySectionRef} className="h-full grow overflow-y-auto">
        <div className="h-[1000px]">
          Testing Testing Testing Testing Testing Testing Testing Testing
          Testing Testing Testing Testing{" "}
        </div>
      </div>
    </div>
  );
};

export default Summary;

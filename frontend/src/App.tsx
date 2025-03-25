import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Summary from "./pages/Summary";
import Notes from "./pages/Notes";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/summary" element={<Summary />} />
        <Route path="/notes" element={<Notes />} />
      </Routes>
    </Router>
  );
}

export default App;

import { BrowserRouter as Router, Routes, Route } from "react-router";
import Relationships from "./pages/Relationships";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/relationships" element={<Relationships />} />
      </Routes>
    </Router>
  );
}

export default App;

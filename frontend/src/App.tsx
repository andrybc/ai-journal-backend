import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Summary from "./pages/Summary";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/summary" element={<Summary />} />
      </Routes>
    </Router>
  );
}

export default App;

import { BrowserRouter as Router, Routes, Route } from "react-router";
import Relationships from "./pages/Relationships";
import Login from "./Login";
import SignUp from "./SignUp";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<SignUp />} />
        <Route path="/relationships" element={<Relationships />} />
      </Routes>
    </Router>
  );
}

export default App;

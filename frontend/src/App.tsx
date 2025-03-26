import { useState } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  BrowserRouter,
} from "react-router-dom";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import Login from "./Login";
import SignUp from "./SignUp";
import Summary from "./pages/summary";
import Notes from "./pages/Notes";

function App() {
  const [count, setCount] = useState(0);
  //const [apiMessage, setApiMessage] = useState("")
  const MainContent = () => (
    <>
      <div>
        <a href="https://vite.dev" target="_blank" rel="noreferrer">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank" rel="noreferrer">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <h1>Frontend Test</h1>
      <p>{/*apiMessage ? apiMessage : "Loading..."*/}</p>
      <div className="card">
        <button type="button" onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  );

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/summary" element={<Summary />} />
        <Route path="/notes" element={<Notes />} />
        <Route path="/register" element={<SignUp />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

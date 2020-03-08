import React, { useState } from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import styled, { ThemeProvider } from "styled-components";

import Login from "./pages/Login";
import Home from "./pages/Home";
import NoMatch from "./pages/404";

import { AuthProvider } from "./providers/AuthProvider";

import { theme } from "@smooth-ui/core-sc";
//import { theme } from "./ui/theme";

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  return (
    <ThemeProvider theme={theme}>
      <AuthProvider>
        <Router>
          <Switch>
            <Route path="/signin">
              <Login />
            </Route>
            <Route path="/home">
              <Home />
            </Route>
            <Route path="*">
              <NoMatch />
            </Route>
          </Switch>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;

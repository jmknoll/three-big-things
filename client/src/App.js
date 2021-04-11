import React, { useEffect } from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Redirect,
} from "react-router-dom";
import { ThemeProvider } from "styled-components";

import Layout from "./pages/Layout";
import Login from "./pages/Login";
import Home from "./pages/Home";
import NoMatch from "./pages/404";
import ProtectedRoute from "./components/ProtectedRoute";

import { AuthProvider } from "./providers/AuthProvider";

import { theme } from "@smooth-ui/core-sc";

function App() {
  return (
    <ThemeProvider theme={theme}>
      <AuthProvider>
        <Router>
          <Switch>
            <Route path="/" exact>
              <Redirect to="/home" />
            </Route>
            <Route path="/login">
              <Login />
            </Route>
            <ProtectedRoute path="/home">
              <Home />
            </ProtectedRoute>
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

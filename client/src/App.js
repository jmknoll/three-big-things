import React, { useEffect } from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Redirect,
} from "react-router-dom";
import { MuiThemeProvider } from "@material-ui/core/styles";
import CssBaseline from "@material-ui/core/CssBaseline";

import theme from "./ui/theme";

import Layout from "./pages/Layout";
import Login from "./pages/Login";
import Home from "./pages/Home";
import NoMatch from "./pages/404";
import ProtectedRoute from "./components/ProtectedRoute";

import { AuthProvider } from "./providers/AuthProvider";

function App() {
  return (
    <MuiThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <Router>
          <Layout>
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
          </Layout>
        </Router>
      </AuthProvider>
    </MuiThemeProvider>
  );
}

export default App;

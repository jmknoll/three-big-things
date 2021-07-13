import React from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Redirect,
} from "react-router-dom";

import Layout from "./pages/Layout";
import Login from "./pages/Login";
import Home from "./pages/Home";
import NoMatch from "./pages/404";
import ProtectedRoute from "./components/ProtectedRoute";

import { AuthProvider } from "./providers/AuthProvider";

function App() {
  return (
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
  );
}

export default App;

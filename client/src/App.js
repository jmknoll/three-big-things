import React from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Redirect,
} from "react-router-dom";

import Layout from "./pages/Layout";
import Dashboard from "./pages/Dashboard";
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
              <Redirect to="/dashboard" />
            </Route>
            <ProtectedRoute path="/dashboard">
              <Dashboard />
            </ProtectedRoute>
            <Route path="/">
              <Home />
            </Route>
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

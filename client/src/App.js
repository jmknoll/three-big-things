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
import History from "./pages/History";
import NoMatch from "./pages/404";
import ProtectedRoute from "./components/ProtectedRoute";

import { AuthProvider } from "./providers/AuthProvider";
import { DataProvider } from "./providers/DataProvider";

function App() {
  return (
    <AuthProvider>
      <DataProvider>
        <Router>
          <Layout>
            <Switch>
              <Route path="/" exact>
                <Redirect to="/dashboard" />
              </Route>
              <ProtectedRoute path="/dashboard">
                <Dashboard />
              </ProtectedRoute>
              <Route path="/history">
                <History />
              </Route>
              <Route path="/">
                <Home />
              </Route>
              <Route path="*">
                <NoMatch />
              </Route>
            </Switch>
          </Layout>
        </Router>
      </DataProvider>
    </AuthProvider>
  );
}

export default App;

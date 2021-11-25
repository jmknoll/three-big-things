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
import Settings from "./pages/Settings";
import Inbox from "./pages/Inbox";
import NoMatch from "./pages/404";

import ProtectedRoute from "./components/ProtectedRoute";

import { AuthProvider } from "./providers/AuthProvider";
import { DataProvider } from "./providers/DataProvider";

function App() {
  return (
    <AuthProvider>
      <DataProvider>
        <Router>
          <Switch>
            <Route path="/" exact>
              <Redirect to="/dashboard" />
            </Route>
            <ProtectedRoute path="/dashboard">
              <Layout withSearch={true}>
                <Dashboard />
              </Layout>
            </ProtectedRoute>
            <ProtectedRoute path="/inbox">
              <Layout withSearch={true}>
                <Inbox />
              </Layout>
            </ProtectedRoute>
            <ProtectedRoute path="/history">
              <Layout withSearch={true}>
                <History />
              </Layout>
            </ProtectedRoute>
            <ProtectedRoute path="/settings">
              <Layout withSearch={false}>
                <Settings />
              </Layout>
            </ProtectedRoute>
            <Route path="/">
              <Home />
            </Route>
            <Route path="*">
              <NoMatch />
            </Route>
          </Switch>
        </Router>
      </DataProvider>
    </AuthProvider>
  );
}

export default App;

import React from "react";
import { Route, Redirect } from "react-router-dom";
import { useAuth } from "../providers/AuthProvider";

const ProtectedRoute = ({ children, ...rest }) => {
  const { state } = useAuth();
  const { isAuthenticated } = state;

  return (
    <Route
      {...rest}
      render={() => {
        if (isAuthenticated) {
          return children;
        }
        if (!isAuthenticated) {
          return <Redirect to="/login" />;
        }
        return <div>Loading...</div>;
      }}
    />
  );
};

export default ProtectedRoute;

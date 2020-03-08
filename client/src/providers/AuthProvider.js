import React, { useEffect } from "react";
import localforage from "localforage";

const AuthContext = React.createContext();

function useAuth() {
  const context = React.useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within a AuthProvider");
  }
  return context;
}

function AuthProvider(props) {
  const [user, setUser] = React.useState(null);
  const value = React.useMemo(() => [user, setUser], [user]);

  useEffect(() => {
    localforage
      .getItem("user")
      .then(user => {
        setUser(user);
      })
      .catch(err => {
        console.log(err);
      });
  }, []);

  if (user && user.token) {
    localforage.setItem("token", user.token);
    localforage.setItem("user", user);
  }

  return <AuthContext.Provider value={value} {...props} />;
}

export { AuthProvider, useAuth };

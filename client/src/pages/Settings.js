import React, { useState, useEffect } from "react";
import { MenuAlt1Icon } from "@heroicons/react/outline";

import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";
import Navigation from "../components/Navigation";
import Search from "../components/Search";

const Settings = (props) => {
  const {
    state: { user, token },
  } = useAuth();
  const {
    state: { archivedGoals: goals },
    dispatch: { fetchGoals },
  } = useData();

  useEffect(() => {
    fetchGoals({ token, archived: true });
  }, [token]);

  return (
    <main className="flex-1 relative pb-8 z-0 overflow-y-auto">
      <div>
        <h2>I'm the settings page</h2>
      </div>
    </main>
  );
};

export default Settings;

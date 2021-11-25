import React, { useState, useEffect } from "react";
import { MenuAlt1Icon } from "@heroicons/react/outline";

import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";
import Navigation from "../components/Navigation";
import Search from "../components/Search";

const History = (props) => {
  const {
    state: { user, token },
  } = useAuth();
  const {
    state: { archivedGoals: goals },
    dispatch: { fetchGoals },
  } = useData();

  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    fetchGoals({ token, archived: true });
  }, [token]);

  return (
    <div className="relative h-screen flex overflow-hidden bg-gray-100">
      <Navigation sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

      <div className="flex-1 overflow-auto focus:outline-none">
        <div className="relative z-10 flex-shrink-0 flex h-16 bg-white border-b border-gray-200 lg:border-none">
          <button
            type="button"
            className="px-4 border-r border-gray-200 text-gray-400 focus:outline-no ne focus:ring-2 focus:ring-inset focus:ring-cyan-500 lg:hidden"
            onClick={() => setSidebarOpen(true)}
          >
            <span className="sr-only">Open sidebar</span>
            <MenuAlt1Icon className="h-6 w-6" aria-hidden="true" />
          </button>
          <Search />
        </div>

        <main className="flex-1 relative pb-8 z-0 overflow-y-auto">
          <div>
            <h2>History Page</h2>
            {goals &&
              goals.map((goal, i) => {
                return (
                  <div>
                    <p>{goal.name}</p>
                    <p>{goal.content}</p>
                  </div>
                );
              })}
          </div>
        </main>
      </div>
    </div>
  );
};

export default History;

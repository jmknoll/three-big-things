import React, { useState, useEffect, Fragment } from "react";
import { MenuAlt1Icon } from "@heroicons/react/outline";

import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";
import { NewGoalButton } from "../components/NewGoalButton";
import { NewGoalModal } from "../components/NewGoalModal";
import Navigation from "../components/Navigation";
import Card from "../components/Card";
import Alert from "../components/Alert";
import Search from "../components/Search";
import { Placeholder } from "../components/Avatar";

const Dashboard = () => {
  const {
    state: { user, token },
  } = useAuth();
  const {
    state: { goals },
    dispatch: { fetchGoals },
  } = useData();

  const [type, setType] = useState("WEEKLY");

  const [showGoalModal, setShowGoalModal] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    fetchGoals({ token, archived: false });
  }, [token]);

  const [weeklyGoals, dailyGoals] =
    goals &&
    goals.reduce(
      (acc, curr) => {
        const i = curr.period === "WEEKLY" ? 0 : 1;
        acc[i] = [...acc[i], curr];
        return acc;
      },
      [[], []]
    );

  return (
    <main className="flex-1 relative pb-8 z-0 overflow-y-auto">
      {/* Page header */}
      <div className="bg-white shadow">
        <div className="px-4 sm:px-6 lg:max-w-6xl lg:mx-auto lg:px-8">
          <div className="py-6 md:flex md:items-center md:justify-between lg:border-t lg:border-gray-200">
            <div className="flex-1 min-w-0">
              {/* Profile */}
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <Placeholder size="16" />
                  <h1 className="ml-3 text-2xl font-bold leading-7 text-gray-900 sm:leading-9 sm:truncate">
                    What are you working on, {user.name.split(" ")[0]}?
                  </h1>
                </div>
                <div className="bg-cyan-700 rounded-full text-white h-12 w-12 inline-flex items-center justify-center text-2xl">
                  {user.streak || 0}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-8">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-lg leading-6 font-medium text-gray-900">
            Weekly Goals
          </h2>
          {weeklyGoals.length > 3 && <Alert content={alertContent} />}
          <div className="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {weeklyGoals.map((goal, i) => (
              <Card key={i} goal={goal} />
            ))}
            <NewGoalButton
              setType={setType}
              type="WEEKLY"
              showGoalModal={showGoalModal}
              setShowGoalModal={setShowGoalModal}
            />
          </div>
        </div>

        <div className="mt-8">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-lg leading-6 font-medium text-gray-900">
              Daily Goals
            </h2>
            {dailyGoals.length > 3 && <Alert content={alertContent} />}
            <div className="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
              {dailyGoals.map((goal, i) => (
                <Card key={i} goal={goal} />
              ))}
              <NewGoalButton
                setType={setType}
                type="DAILY"
                showGoalModal={showGoalModal}
                setShowGoalModal={setShowGoalModal}
              />
            </div>
          </div>
        </div>
      </div>
      <NewGoalModal
        showGoalModal={showGoalModal}
        setShowGoalModal={setShowGoalModal}
        type={type}
        mode="CREATE"
      />
    </main>
  );
};

const alertContent = () => (
  <p>
    In order to stay focused on what matters, try to limit yourself to three
    goals at any one time. See{" "}
    <a
      href="https://alifeofproductivity.com/rule-of-three/"
      target="_blank"
      rel="noreferrer"
    >
      The Rule of Three
    </a>{" "}
    for more info.
  </p>
);

export default Dashboard;

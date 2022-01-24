import React, { useState, useEffect } from "react";
import moment from "moment";
import { Link } from "react-router-dom";

import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";
import { NewGoalButton } from "../components/NewGoalButton";
import { NewGoalModal } from "../components/NewGoalModal";
import Card from "../components/Card";
import Alert from "../components/Alert";
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

  useEffect(() => {
    fetchGoals({ token, archived: false });
  }, [token]);

  const [inbox, weeklyGoals, dailyGoals] =
    goals &&
    goals.reduce(
      (acc, curr) => {
        let i;
        const created = moment.utc(curr.created_at);
        const now = moment();
        if (curr.period === "DAILY" && !created.isSame(now, "day")) {
          i = 0;
        } else if (curr.period === "WEEKLY" && !created.isSame(now, "week")) {
          i = 0;
        } else {
          i = curr.period === "WEEKLY" ? 1 : 2;
        }

        acc[i] = [...acc[i], curr];
        return acc;
      },
      [[], [], []]
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

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 my-6">
        {inbox.length > 0 && (
          <Alert content={inboxAlertContent} type="WARNING" />
        )}

        <div className="mt-6">
          <div className="my-4 flex items-center">
            <h2 className="text-xl font-medium text-gray-900 mr-4">
              Daily Goals
            </h2>

            {dailyGoals.length > 2 && (
              <NewGoalButton
                setType={setType}
                type="DAILY"
                showGoalModal={showGoalModal}
                setShowGoalModal={setShowGoalModal}
                size="sm"
              />
            )}
          </div>
          {dailyGoals.length > 3 && (
            <Alert content={alertContent} type="WARNING" />
          )}
          <div className="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {dailyGoals.map((goal, i) => (
              <Card key={i} goal={goal} />
            ))}
            {dailyGoals.length < 3 && (
              <NewGoalButton
                setType={setType}
                type="DAILY"
                showGoalModal={showGoalModal}
                setShowGoalModal={setShowGoalModal}
              />
            )}
          </div>
        </div>

        <div className="mt-6">
          <div className="my-4 flex items-center">
            <h2 className="text-xl font-medium text-gray-900 mr-4">
              Weekly Goals
            </h2>
            {weeklyGoals.length > 2 && (
              <NewGoalButton
                setType={setType}
                type="WEEKLY"
                showGoalModal={showGoalModal}
                setShowGoalModal={setShowGoalModal}
                size="sm"
              />
            )}
          </div>
          {weeklyGoals.length > 3 && (
            <Alert content={alertContent} type="WARNING" />
          )}
          <div className="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {weeklyGoals.map((goal, i) => (
              <Card key={i} goal={goal} />
            ))}
            {weeklyGoals.length < 3 && (
              <NewGoalButton
                setType={setType}
                type="WEEKLY"
                showGoalModal={showGoalModal}
                setShowGoalModal={setShowGoalModal}
                size="lg"
              />
            )}
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

const inboxAlertContent = () => (
  <p>
    You have expired records in your inbox. Processing and archiving them will
    help you build better analytics. <Link to="/inbox">Click here</Link> to view
    your inbox.
  </p>
);

export default Dashboard;

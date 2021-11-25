import React, { useState, useEffect, Fragment } from "react";
import moment from "moment";

import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";

import Card from "../components/Card";
import Alert from "../components/Alert";

const Inbox = () => {
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

  const [inbox, _weeklyGoals, _dailyGoals] =
    goals &&
    goals.reduce(
      (acc, curr) => {
        let i;
        const created = moment
          .utc(curr.createdAt)
          .subtract(user.timezone_offset, "minutes");
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
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 className="mt-8 mb-4 text-2xl font-medium text-gray-900">Inbox</h2>
        {inbox.length === 0 && <Alert content={alertContent} type="SUCCESS" />}
        <div className="mt-2 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {inbox.map((goal, i) => (
            <Card key={i} goal={goal} source="inbox" />
          ))}
        </div>
      </div>
    </main>
  );
};

const alertContent = () => (
  <p>You don't have any items remaining in your inbox. Nice work!</p>
);

export default Inbox;

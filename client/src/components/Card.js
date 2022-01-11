import React, { useState } from "react";
import { statuses, statusColorMap } from "../constants";
import { classNames } from "../utils";
import { Trash, Pencil } from "../assets/icons";
import ConfirmDialog from "./ConfirmDialog";
import { useData } from "../providers/DataProvider";
import { useAuth } from "../providers/AuthProvider";
import { NewGoalModal } from "./NewGoalModal";

const Card = (props) => {
  const { goal } = props;
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [showGoalModal, setShowGoalModal] = useState(false);

  const {
    state: { token },
  } = useAuth();

  const {
    dispatch: { removeGoal },
  } = useData();

  const handleDelete = () => {
    removeGoal({ token, goal });
  };

  const status = statuses.find((status) => status.value === goal.status);
  return (
    <div className="bg-white overflow-hidden shadow rounded-lg">
      <div className="p-5 h-full flex flex-col justify-between">
        <div className="flex flex-row justify-between">
          <p className="text-xl font-semibold text-gray-900">{goal.name}</p>
          <div className="flex flex-row">
            <span
              className="opacity-50 mr-2 cursor-pointer hover:opacity-70"
              onClick={() => {
                setShowGoalModal(true);
              }}
            >
              <Pencil />
            </span>
            <span
              className="opacity-50 cursor-pointer hover:opacity-70"
              onClick={() => {
                setShowConfirmation(true);
              }}
            >
              <Trash />
            </span>
          </div>
        </div>
        <p className="mt-3 text-base text-gray-500">{goal.content}</p>
        <div className="flex items-center mt-5">
          <span
            className={classNames(
              `bg-${statusColorMap[status.value]}-400`,
              "flex-shrink-0 inline-block h-2 w-2 rounded-full"
            )}
          />
          <span className="ml-3 block truncate">{status.label}</span>
        </div>
      </div>
      {showConfirmation && (
        <ConfirmDialog
          open={showConfirmation}
          setOpen={setShowConfirmation}
          handleDelete={handleDelete}
        />
      )}
      {showGoalModal && (
        <NewGoalModal
          showGoalModal={showGoalModal}
          setShowGoalModal={setShowGoalModal}
          type={goal.period}
          goal={goal}
          source={props.source}
        />
      )}
    </div>
  );
};

export default Card;

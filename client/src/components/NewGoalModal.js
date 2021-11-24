import React, { Fragment, useEffect, useRef, useState } from "react";
import { Dialog, Transition } from "@headlessui/react";
import { DurationSelector } from "./DurationSelector";
import { GoalStatusSelector } from "./GoalStatusSelector";
import { useAuth } from "../providers/AuthProvider";
import { useData } from "../providers/DataProvider";
import { durationSelectorOptions, statuses } from "../constants";

export const NewGoalModal = (props) => {
  const {
    state: { token },
  } = useAuth();

  const {
    dispatch: { createGoal },
  } = useData();

  const defaultGoal = {
    period: durationSelectorOptions.find((el) => el.value === props.type)
      ?.value,
    status: statuses[0].value,
  };

  const [goal, setGoal] = useState(props.goal || defaultGoal);

  const { showGoalModal, setShowGoalModal } = props;
  const cancelButtonRef = useRef(null);

  useEffect(() => {
    updateGoal(
      "period",
      durationSelectorOptions.find((el) => el.value === props.type)?.value
    );
  }, [props.type]);

  const updateGoal = (key, value) => {
    setGoal({
      ...goal,
      [key]: value,
    });
  };

  const _createGoal = () => {
    createGoal({ token, goal });
    setShowGoalModal(false);
    setGoal(defaultGoal);
  };

  console.log("type", props.type, durationSelectorOptions, goal);

  return (
    <Transition.Root show={showGoalModal} as={Fragment}>
      <Dialog
        as="div"
        auto-reopen="true"
        className="fixed z-10 inset-0 overflow-y-auto"
        initialFocus={cancelButtonRef}
        onClose={setShowGoalModal}
      >
        <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Dialog.Overlay className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
          </Transition.Child>

          {/* This element is to trick the browser into centering the modal contents. */}
          <span
            className="hidden sm:inline-block sm:align-middle sm:h-screen"
            aria-hidden="true"
          >
            &#8203;
          </span>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enterTo="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100 translate-y-0 sm:scale-100"
            leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <div className="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-7 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
              <h3 className="text-lg mb-4 font-medium text-gray-900">
                Add a New Goal
              </h3>
              <div>
                <label
                  htmlFor="project-name"
                  className="block text-sm font-medium text-gray-700"
                >
                  Goal Name
                </label>
                <div className="mt-1">
                  <input
                    type="text"
                    name="project-name"
                    id="project-name"
                    className="block w-full shadow-sm focus:ring-sky-500 focus:border-sky-500 sm:text-sm border-gray-300 rounded-md"
                    value={goal.name}
                    onChange={(e) => {
                      updateGoal("name", e.target.value);
                    }}
                  />
                </div>
                <div className="mt-4">
                  <label
                    htmlFor="description"
                    className="block text-sm font-medium text-gray-700"
                  >
                    Description
                  </label>
                  <div className="mt-1">
                    <textarea
                      id="description"
                      name="description"
                      rows={3}
                      className="block w-full shadow-sm focus:ring-sky-500 focus:border-sky-500 sm:text-sm border border-gray-300 rounded-md"
                      value={goal.content}
                      onChange={(e) => {
                        updateGoal("content", e.target.value);
                      }}
                    />
                  </div>
                </div>
                <div className="mt-4">
                  <label
                    htmlFor="status"
                    className="block text-sm font-medium text-gray-700"
                  >
                    Status
                  </label>
                  <div className="mt-1">
                    <GoalStatusSelector updateGoal={updateGoal} />
                  </div>
                </div>
                <div className="mt-4">
                  <label
                    htmlFor="duration"
                    className="block text-sm font-medium text-gray-700"
                  >
                    Duration
                  </label>
                  <div className="mt-1">
                    <DurationSelector
                      updateGoal={updateGoal}
                      value={goal.period}
                    />
                  </div>
                </div>
              </div>
              <div className="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
                <button
                  type="button"
                  className="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:col-start-2 sm:text-sm"
                  onClick={() => _createGoal()}
                >
                  Save
                </button>
                <button
                  type="button"
                  className="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:col-start-1 sm:text-sm"
                  onClick={() => setShowGoalModal(false)}
                  ref={cancelButtonRef}
                >
                  Cancel
                </button>
              </div>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
};

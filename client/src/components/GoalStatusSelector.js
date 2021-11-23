/* This example requires Tailwind CSS v2.0+ */
import React, { useEffect, Fragment, useState } from "react";
import { Listbox, Transition } from "@headlessui/react";
import { CheckIcon, SelectorIcon } from "@heroicons/react/solid";

const statuses = [
  { id: 1, label: "In progress", value: "IN_PROGRESS" },
  { id: 2, label: "Complete", value: "COMPLETE" },
  { id: 3, label: "Not Completed", value: "NOT_COMPLETED" },
];

const statusColorMap = {
  IN_PROGRESS: "yellow",
  COMPLETE: "green",
  NOT_COMPLETED: "red",
};

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

export const GoalStatusSelector = (props) => {
  const [selected, setSelected] = useState(statuses[0]);

  useEffect(() => {
    props.updateGoal(statuses[0]);
  }, [false]);

  const _handleChange = (status) => {
    setSelected(statuses.find((el) => el.value === status));
    props.updateGoal("status", status);
  };

  return (
    <Listbox value={selected} onChange={(status) => _handleChange(status)}>
      {({ open }) => (
        <>
          <div className="mt-1 relative">
            <Listbox.Button className="relative w-full bg-white border border-gray-300 rounded-md shadow-sm pl-3 pr-10 py-2 text-left cursor-default focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
              <div className="flex items-center">
                <span
                  className={classNames(
                    `bg-${statusColorMap[selected.value]}-400`,
                    "flex-shrink-0 inline-block h-2 w-2 rounded-full"
                  )}
                />
                <span className="ml-3 block truncate">{selected.label}</span>
              </div>
              <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                <SelectorIcon
                  className="h-5 w-5 text-gray-400"
                  aria-hidden="true"
                />
              </span>
            </Listbox.Button>

            <Transition
              show={open}
              as={Fragment}
              leave="transition ease-in duration-100"
              leaveFrom="opacity-100"
              leaveTo="opacity-0"
            >
              <Listbox.Options className="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm">
                {statuses.map((status) => (
                  <Listbox.Option
                    key={status.id}
                    className={({ active }) =>
                      classNames(
                        active ? "text-white bg-indigo-600" : "text-gray-900",
                        "cursor-default select-none relative py-2 pl-3 pr-9"
                      )
                    }
                    value={status.value}
                  >
                    {({ selected, active }) => (
                      <>
                        <div className="flex items-center">
                          <span
                            className={classNames(
                              `bg-${statusColorMap[status.value]}-400`,
                              "flex-shrink-0 inline-block h-2 w-2 rounded-full"
                            )}
                            aria-hidden="true"
                          />
                          <span
                            className={classNames(
                              selected ? "font-semibold" : "font-normal",
                              "ml-3 block truncate"
                            )}
                          >
                            {status.label}
                          </span>
                        </div>

                        {selected ? (
                          <span
                            className={classNames(
                              active ? "text-white" : "text-indigo-600",
                              "absolute inset-y-0 right-0 flex items-center pr-4"
                            )}
                          >
                            <CheckIcon className="h-5 w-5" aria-hidden="true" />
                          </span>
                        ) : null}
                      </>
                    )}
                  </Listbox.Option>
                ))}
              </Listbox.Options>
            </Transition>
          </div>
        </>
      )}
    </Listbox>
  );
};

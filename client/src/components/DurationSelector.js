import React, { useState, useEffect } from "react";
import { RadioGroup } from "@headlessui/react";

const options = [
  {
    label: "Weekly",
    value: "WEEKLY",
  },
  {
    label: "Daily",
    value: "DAILY",
  },
];

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

export const DurationSelector = (props) => {
  const [selected, setSelected] = useState(options[0]);

  useEffect(() => {
    const option = options.find((el) => el.value === props.type);
    props.updateGoal({ period: option.value });
    setSelected(option);
  }, [false]);

  const handleChange = (option) => {
    setSelected(option);
    props.updateGoal("period", option.value);
  };

  console.log("props type", props.type);

  return (
    <RadioGroup value={selected} onChange={handleChange}>
      <RadioGroup.Label className="sr-only">Server size</RadioGroup.Label>
      <div className="space-x-4 flex flex-row align-center">
        {options.map((option) => (
          <RadioGroup.Option
            key={option.value}
            value={option}
            className={({ active }) =>
              classNames(
                option.value === selected.value
                  ? "ring-1 ring-offset-2 ring-indigo-500"
                  : "",
                "relative block rounded-lg border border-gray-300 bg-white shadow-sm px-6 py-4 cursor-pointer hover:border-gray-400 sm:flex sm:justify-between focus:outline-none"
              )
            }
          >
            {({ checked }) => (
              <>
                <div className="flex items-center ">
                  <div className="text-sm">
                    <RadioGroup.Label as="p" className="text-gray-900">
                      {option.label}
                    </RadioGroup.Label>
                  </div>
                </div>
              </>
            )}
          </RadioGroup.Option>
        ))}
      </div>
    </RadioGroup>
  );
};

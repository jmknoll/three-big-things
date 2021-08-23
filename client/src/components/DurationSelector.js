import React, { useState } from "react";
import { RadioGroup } from "@headlessui/react";

const plans = [
  {
    name: "Weekly",
  },
  {
    name: "Daily",
  },
];

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}

export const DurationSelector = (props) => {
  const [selected, setSelected] = useState(plans[0]);

  return (
    <RadioGroup value={selected} onChange={setSelected}>
      <RadioGroup.Label className="sr-only">Server size</RadioGroup.Label>
      <div className="space-x-4 flex flex-row align-center">
        {plans.map((plan) => (
          <RadioGroup.Option
            key={plan.name}
            value={plan}
            className={({ active }) =>
              classNames(
                active ? "ring-1 ring-offset-2 ring-indigo-500" : "",
                "relative block rounded-lg border border-gray-300 bg-white shadow-sm px-6 py-4 cursor-pointer hover:border-gray-400 sm:flex sm:justify-between focus:outline-none"
              )
            }
          >
            {({ checked }) => (
              <>
                <div className="flex items-center ">
                  <div className="text-sm">
                    <RadioGroup.Label as="p" className="text-gray-900">
                      {plan.name}
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

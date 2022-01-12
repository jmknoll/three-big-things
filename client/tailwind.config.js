const defaultTheme = require("tailwindcss/defaultTheme");
const colors = require("tailwindcss/colors");
const forms = require("@tailwindcss/forms");
const typography = require("@tailwindcss/typography");

module.exports = {
  purge: {
    content: ["./src/**/*.{js,jsx,ts,tsx}", "./public/index.html"],
    options: {
      safelist: [
        "h-8",
        "w-8",
        "bg-yellow-50",
        "bg-red-50",
        "bg-green-50",
        "bg-blue-50",
        "bg-yellow-400",
        "bg-red-400",
        "bg-green-400",
        "bg-blue-400",
      ],
    },
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        cyan: colors.cyan,
      },
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [forms, typography],
};

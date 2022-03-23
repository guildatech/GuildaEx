const colors = require("tailwindcss/colors");
const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: ["../lib/**/*.ex", "../lib/**/*.leex", "../lib/**/*.heex", "../lib/**/*.eex", "./js/**/*.js"],
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography"), require("@tailwindcss/aspect-ratio")],
  darkMode: "class",
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: colors.amber,
      },
    },
  },
};

// tailwind.config.js
const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  experimental: {
    applyComplexClasses: true,
  },
  plugins: [require("@tailwindcss/ui")],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
};

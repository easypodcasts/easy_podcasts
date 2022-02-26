const colors = require('tailwindcss/colors')

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      backgroundImage: {
        "placeholder-small": "url('/images/placeholder-small.webp')",
        "placeholder-big": "url('/images/placeholder-big.webp')",
      },
    },
    extend: {
      colors: {
          primary: "#BE123C",
          "primary-dark": "#881337",
          "primary-light": "#F43F5E",
          surface: "#FFE4E6"
      },
    },
  },
  plugins: [require("@tailwindcss/line-clamp")],
};

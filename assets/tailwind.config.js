const colors = require("tailwindcss/colors");

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      backgroundImage: {
        "placeholder-small": "url('/images/placeholder-small.webp')",
        "placeholder-big": "url('/images/placeholder-big.webp')",
      },
      colors: {
        primary: "#0891B2",
        "primary-dark": "#155E75",
        "primary-light": "#06B6D4",
        surface: "#E5E7EB",
        "text-light": "#E5E7EB",
        "text-dark": "#111827",
        disabled: "#D1D5DB",
        cancel: "#6B7280",
        "cancel-dark": "#374151",

        //dark
        "d-primary": "#BE123C",
        "d-primary-dark": "#881337",
        "d-primary-light": "#F43F5E",
        "d-surface": "#1F2937",
        "d-text-light": "#E5E7EB",
        "d-text-dark": "#E5E7EB",
        "d-disabled": "#D1D5DB",
        "d-cancel": "#6B7280",
        "d-cancel-dark": "#374151",
      },
    },
  },
  plugins: [require("@tailwindcss/line-clamp")],
};

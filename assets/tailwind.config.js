module.exports = {
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      backgroundImage: {
        "placeholder-small": "url('/images/placeholder-small.webp')",
        "placeholder-big": "url('/images/placeholder-big.webp')",
      },
    },
    colors: {
      transparent: "transparent",
      current: "currentColor",
      primary: "#f3d2c1",
      "primary-light": "#fffff4",
      "primary-dark": "#c0a191",
      secondary: "#8bd3dd",
      "secondary-light": "#beffff",
      "secondary-dark": "#59a2ab",
      tertiary: "#f582ae",
      "tertiary-light": "#ffb4e0",
      "tertiary-dark": "#c0527f",
      surface: "#fef6e4",
      background: "#fef6e4",
      "on-primary": "#fef6e4",
      "on-secondary": "#001858",
    },
  },
  plugins: [require("@tailwindcss/line-clamp")],
};

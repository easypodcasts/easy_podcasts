module.exports = {
  mode: "jit",
  darkMode: "media",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {},
  variants: {},
  plugins: [require("@tailwindcss/line-clamp")],
};

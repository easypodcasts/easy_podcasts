module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {},
  variants: {},
  plugins: [require("@tailwindcss/line-clamp")],
};

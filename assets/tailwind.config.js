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
      },
    },
  },
  plugins: [require("@tailwindcss/line-clamp")],
};

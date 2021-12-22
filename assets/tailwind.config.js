const isProd = process.env.NODE_ENV === "production";

module.exports = {
    content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
    theme: {
        extend: {
            backgroundImage: {
                "placeholder-small": isProd ? "url('/podcasts/images/placeholder-small.webp')" : "url('/images/placeholder-small.webp')",
                "placeholder-big": isProd ? "url('/podcasts/images/placeholder-big.webp')" : "url('/images/placeholder-big.webp')",
            },
        },
    },
    plugins: [require("@tailwindcss/line-clamp")],
};

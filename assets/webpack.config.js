const path = require("path");
const glob = require("glob");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");

module.exports = (env, options) => {
  const devMode = options.mode !== "production";

  return {
    mode: options.mode || "production",
    entry: {
      app: glob.sync("./vendor/**/*.js").concat(["./js/app.js"]),
    },
    output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "../priv/static/js"),
      publicPath: "/js/",
    },
    devtool: devMode ? "eval-cheap-module-source-map" : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
          },
        },
        {
          test: /\.[s]?css$/,
          use: [MiniCssExtractPlugin.loader, "css-loader", "postcss-loader", "sass-loader"],
        },
        {
          test: /\.(ttf|woff|woff2|eot|svg)$/,
          type: "asset/resource",
        },
      ],
    },
    plugins: [new MiniCssExtractPlugin({ filename: "../css/app.css" })],
    optimization: {
      minimizer: ["...", new CssMinimizerPlugin()],
    },
  };
};

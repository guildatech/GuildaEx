[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  import_deps: [:ecto, :phoenix, :phoenix_live_view],
  inputs: ["*.{heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  line_length: 120
]

defmodule Guilda.Accounts.Events do
  defmodule LocationChanged do
    defstruct user: nil
  end

  defmodule LocationAdded do
    defstruct lat: nil, lng: nil
  end
end

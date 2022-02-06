defmodule Guilda.Accounts.Events do
  @moduledoc false

  defmodule LocationChanged do
    @moduledoc false
    defstruct user: nil
  end

  defmodule LocationAdded do
    @moduledoc false
    defstruct lat: nil, lng: nil
  end
end

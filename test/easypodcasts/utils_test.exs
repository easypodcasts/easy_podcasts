defmodule Easypodcasts.UtilsTest do
  use ExUnit.Case, async: true
  alias Easypodcasts.Helpers.Utils

  test "slugify works" do
    assert "this-is-a-string" == Utils.slugify("This# is-_a ST*R()ING")
  end
end

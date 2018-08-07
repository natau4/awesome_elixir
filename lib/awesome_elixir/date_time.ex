defmodule AwesomeElixir.DateTime do

  def beginning_of_day(datetime \\ DateTime.utc_now) do
    %{datetime | hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
  end
end
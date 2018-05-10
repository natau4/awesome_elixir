defmodule AwesomeElixir.Scheduler do
  use Cronex.Scheduler

  every :day, at: "21:00" do
    AwesomeElixir.Aggregator.aggregate
  end
end
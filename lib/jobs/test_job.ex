defmodule TaskBunnySentry.TestJob do
  @moduledoc """
  Handy sample job to try out the error reporting with TaskBunny.
  """
  use TaskBunny.Job

  def max_retry, do: 1
  def timeout, do: 1_000

  def perform(%{"sleep" => sleep}), do: :timer.sleep(sleep)
  def perform(%{"exception" => true}), do: raise("Testing exception")
  def perform(%{"exit" => true}), do: exit(:testing)
  def perform(%{"fail" => true}), do: :error
  def perform(_payload), do: :ok
end

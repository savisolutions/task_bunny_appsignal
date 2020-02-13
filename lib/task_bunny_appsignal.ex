defmodule TaskBunnyAppsignal do
  @moduledoc """
  A TaskBunny failure backend that reports to Appsignal.
  """
  alias TaskBunny.JobError

  use TaskBunny.FailureBackend

  @spec report_job_error(JobError.t()) :: {:ok, :done} | :error | :excluded | :ignored
  def report_job_error(%JobError{error_type: :exception, reject: true} = error) do
    prefix = "#{error.job}: exception raised"
    send_error(error, prefix, error.stacktrace)
  end

  def report_job_error(%JobError{error_type: :exit, reject: true} = error) do
    prefix = "#{error.job}: unexpected exit"
    send_error(error, prefix, error.stacktrace)
  end

  def report_job_error(%JobError{error_type: :return_value, reject: true} = error) do
    prefix = "#{error.job}: return value error"
    send_error(error, prefix)
  end

  def report_job_error(%JobError{error_type: :timeout, reject: true} = error) do
    prefix = "#{error.job}: timeout error"
    send_error(error, prefix)
  end

  def report_job_error(%JobError{reject: true} = error) do
    prefix = "#{error.job}: unknown error"
    send_error(error, prefix)
  end

  def report_job_error(_), do: nil

  defp send_error(error, prefix, stack \\ []) do
    Appsignal.send_error(error, prefix, stack, meta_from_error(error), nil, fn t -> t end)
    {:ok, :done}
  end

  defp meta_from_error(error) do
    Map.merge(error.meta, %{job: error.job, payload: Jason.encode!(error.payload)})
  end
end

defmodule TaskBunnyAppsignalTest do
  use ExUnit.Case, async: true
  use Mimic

  describe "report_job_error/1" do
    alias TaskBunny.JobError
    alias TaskBunnyAppsignal.TestJob

    @job TestJob
    @payload %{"test" => true}

    test "handle an exception" do
      exception =
        try do
          raise "Hello"
        rescue
          e in RuntimeError -> e
        end

      job_error = @job |> JobError.handle_exception(@payload, exception) |> Map.put(:reject, true)

      expect(Appsignal, :send_error, fn error, prefix, stack, meta, conn, _fun ->
        assert error == job_error
        assert prefix == "#{job_error.job}: exception raised"
        assert stack == job_error.stacktrace
        assert meta == %{job: job_error.job, payload: Jason.encode!(job_error.payload)}
        assert is_nil(conn)
        :ok
      end)

      TaskBunnyAppsignal.report_job_error(job_error)
    end

    test "handle the exit signal" do
      reason =
        try do
          exit(:test)
        catch
          _, reason -> reason
        end

      job_error = @job |> JobError.handle_exit(@payload, reason) |> Map.put(:reject, true)

      expect(Appsignal, :send_error, fn error, prefix, stack, meta, conn, _fun ->
        assert error == job_error
        assert prefix == "#{job_error.job}: unexpected exit"
        assert stack == job_error.stacktrace
        assert meta == %{job: job_error.job, payload: Jason.encode!(job_error.payload)}
        assert is_nil(conn)
        :ok
      end)

      TaskBunnyAppsignal.report_job_error(job_error)
    end

    test "handle timeout error" do
      job_error = @job |> JobError.handle_timeout(@payload) |> Map.put(:reject, true)

      expect(Appsignal, :send_error, fn error, prefix, stack, meta, conn, _fun ->
        assert error == job_error
        assert prefix == "#{job_error.job}: timeout error"
        assert stack == []
        assert meta == %{job: job_error.job, payload: Jason.encode!(job_error.payload)}
        assert is_nil(conn)
        :ok
      end)

      TaskBunnyAppsignal.report_job_error(job_error)
    end

    test "should not send error" do
      job_error = JobError.handle_timeout(@job, @payload)
      reject(&Appsignal.send_error/6)
      TaskBunnyAppsignal.report_job_error(job_error)
    end
  end
end

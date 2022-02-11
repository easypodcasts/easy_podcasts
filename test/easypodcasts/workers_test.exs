defmodule Easypodcasts.WorkersTest do
  use Easypodcasts.DataCase

  alias Easypodcasts.Workers

  describe "workers" do
    alias Easypodcasts.Workers.Worker

    import Easypodcasts.WorkersFixtures

    @invalid_attrs %{name: nil}

    test "list_workers/0 returns all workers" do
      worker = worker_fixture()
      assert Workers.list_workers() == [worker]
    end

    test "get_worker!/1 returns the worker with given id" do
      worker = worker_fixture()
      assert Workers.get_worker!(worker.id) == worker
    end

    test "create_worker/1 with valid data creates a worker" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Worker{} = worker} = Workers.create_worker(valid_attrs)
      assert worker.name == "some name"
      id = worker.id

      assert {:ok, ^id} =
               Phoenix.Token.verify(EasypodcastsWeb.Endpoint, "worker auth", worker.token,
                 max_age: :infinity
               )
    end

    test "create_worker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workers.create_worker(@invalid_attrs)
    end

    test "delete_worker/1 deletes the worker" do
      worker = worker_fixture()
      assert {:ok, %Worker{}} = Workers.delete_worker(worker)
      assert_raise Ecto.NoResultsError, fn -> Workers.get_worker!(worker.id) end
    end

    test "change_worker/1 returns a worker changeset" do
      worker = worker_fixture()
      assert %Ecto.Changeset{} = Workers.change_worker(worker)
    end
  end
end

defmodule App.CtxTest do
  use App.DataCase

  alias App.Ctx

  describe "sent" do
    alias App.Ctx.Sent

    @valid_attrs %{message_id: "some message_id", request_id: "some request_id", template: "some template"}
    @update_attrs %{message_id: "some updated message_id", request_id: "some updated request_id", template: "some updated template"}
    @invalid_attrs %{message_id: nil, request_id: nil, template: nil}

    def sent_fixture(attrs \\ %{}) do
      {:ok, sent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ctx.create_sent()

      sent
    end

    # open a JSON fixture file and return an Elixir Map
    def get_json(filename) do
      # IO.inspect(filename, label: "filename")
      # IO.inspect(File.cwd!, label: "cwd")
      {:ok, body} = File.read(filename)
      {:ok, json} = Jason.decode(body)
      # IO.inspect json, label: "json"
      json
    end

    test "list_sent/0 returns all sent" do
      sent = sent_fixture()
      assert Ctx.list_sent() == [sent]
    end

    test "get_sent!/1 returns the sent with given id" do
      sent = sent_fixture()
      assert Ctx.get_sent!(sent.id) == sent
    end

    test "create_sent/1 with valid data creates a sent" do
      assert {:ok, %Sent{} = sent} = Ctx.create_sent(@valid_attrs)
      assert sent.message_id == "some message_id"
      assert sent.request_id == "some request_id"
      assert sent.template == "some template"
    end

    test "create_sent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ctx.create_sent(@invalid_attrs)
    end

    test "update_sent/2 with valid data updates the sent" do
      sent = sent_fixture()
      assert {:ok, %Sent{} = sent} = Ctx.update_sent(sent, @update_attrs)
      assert sent.message_id == "some updated message_id"
      assert sent.request_id == "some updated request_id"
      assert sent.template == "some updated template"
    end

    test "update_sent/2 with invalid data returns error changeset" do
      sent = sent_fixture()
      assert {:error, %Ecto.Changeset{}} = Ctx.update_sent(sent, @invalid_attrs)
      assert sent == Ctx.get_sent!(sent.id)
      IO.inspect sent, label: "sent"
    end

    test "delete_sent/1 deletes the sent" do
      sent = sent_fixture()
      assert {:ok, %Sent{}} = Ctx.delete_sent(sent)
      assert_raise Ecto.NoResultsError, fn -> Ctx.get_sent!(sent.id) end
    end

    test "change_sent/1 returns a sent changeset" do
      sent = sent_fixture()
      assert %Ecto.Changeset{} = Ctx.change_sent(sent)
    end

    test "upsert_sent/1 inserts a valid NEW sent record with email" do

      # bounce = get_json("test/fixtures/bounce.json")
      data = %{
        "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2-000000",
        "status" => "Sent",
        "email" => "amaze@gmail.com",
        "template" => "welcome"
      }
      # IO.inspect(data, label: "data")
      sent = Ctx.upsert_sent(data)
      # assert json == bounce

      # sent = sent_fixture()
      IO.inspect(sent, label: "sent")
      # assert %Ecto.Changeset{} = Ctx.change_sent(sent)
    end



    test "upsert_sent/1 inserts a valid NEW sent record" do

      bounce = get_json("test/fixtures/bounce.json")
      # bounce = %{
      #   "message_id" => "0102017092006798-f0456694-ac24-487b-9467-b79b8ce798f2-000000",
      #   "status" => "Bounce Permanent"
      # }
      # IO.inspect(bounce, label: "bounce")
      sent = Ctx.upsert_sent(bounce)
      # assert json == bounce

      # sent = sent_fixture()
      IO.inspect(sent, label: "sent")
      # assert %Ecto.Changeset{} = Ctx.change_sent(sent)
    end
  end
end

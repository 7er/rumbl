defmodule Rumbl.Noop do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
  end
end


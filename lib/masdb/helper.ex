defmodule Masdb.Helper do
  def find_task_by_ref(tasks, ref) when is_reference(ref) do
    Enum.find(tasks, fn t -> t.ref == ref end)
  end
end

defmodule GMS.SendText do


  @doc """
  Send throttled messages 5 at a time to prevent carriers from blocking texts
  """
  def send_many(number_list, msg) do
    msg_length = String.length(msg)

    if msg_length > 156 do
      "Error: Message is #{msg_length} characters but must be 156 characters or less."
    else
      # If only one number is left (i.e. remainder 1 after division by 5) then
      # append Jons number and 3 dummy numbers to make list of 5
      _send_many(Enum.chunk(number_list, 5, 5, ~w/13852418454 2 3 4/), msg)
    end
  end

  # head for default indices used to choose sender
  defp _send_many(number_list, msg, indices \\ [0,1,2,3])

  defp _send_many([], _msg, indices), do: "Finished Sending!"

  defp _send_many(grouped_list, msg, indices) do
    {plivo_auth_id, plivo_token, plivo_numbers, content_type, send_url} =
      setup_plivo()

    # Alternate sender each time
    [ head_index | tail_indices ] = indices
    new_indices = Enum.concat(tail_indices, [head_index])
    sender = Enum.at(plivo_numbers, head_index)

    # Work through list of recipient groups
    head_group = hd grouped_list
    tail_group = tl grouped_list

    send_list = head_group |> Enum.join("<")
    IO.inspect(send_list)

    payload = "{\"src\":\"#{sender}\",\"dst\":\"#{send_list}\"," <>
      "\"text\":\"#{msg}\"}"

    curl_command = ["-i", "--user", "#{plivo_auth_id}:#{plivo_token}",
      "-H", "#{content_type}", "-d", payload, send_url]

    System.cmd("curl", curl_command)

    # :timer.sleep(1000 + Enum.random(1000..5000))

    :timer.sleep(15000 + Enum.random(0..5000))
    _send_many(tail_group, msg, new_indices)
  end

  def send_one_sms(number, msg) do

    # Message must be 156 characters or less.
    if String.length(msg) > 156 do
      "Error: Message must be 156 characters or less."
    else

      {plivo_auth_id, plivo_token, plivo_number, content_type, send_url} =
        setup_plivo()

      payload = "{\"src\":\"#{plivo_number}\",\"dst\":\"#{number}\"," <>
        "\"text\":\"#{msg}\"}"
      curl_command = ["-i", "--user", "#{plivo_auth_id}:#{plivo_token}",
        "-H", "#{content_type}", "-d", payload, send_url]
      System.cmd("curl", curl_command)

      # Response
      # {
      # "message": "message(s) queued",
      # "message_uuid": ["db3ce55a-7f1d-11e1-8ea7-1231380bc196"],
      # "api_id": "db342550-7f1d-11e1-8ea7-1231380bc196"
      # }
    end

  end

  def setup_plivo() do
    plivo_auth_id = System.get_env("PLIVO_AUTH_ID")
    plivo_token = System.get_env("PLIVO_AUTH_TOKEN")
    plivo_numbers = Enum.map(~w[PLIVO_NUMBER0 PLIVO_NUMBER1
      PLIVO_NUMBER2 PLIVO_NUMBER3], &System.get_env(&1))
    content_type = "Content-Type: application/json"
    send_url = "https://api.plivo.com/v1/Account/#{plivo_auth_id}/Message/"

    {plivo_auth_id, plivo_token, plivo_numbers, content_type, send_url}
  end

end

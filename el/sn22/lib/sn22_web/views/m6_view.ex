defmodule Sn22Web.ThermostatLive do
alias Sn22Web.Presence
  use Sn22Web, :live_view


  @cursorview "cursorview"
  def mount(_params, _, socket) do
    n = Faker.Pokemon.name
    s = M6.get
    cells = M7state.get.cells;
    Sn22Web.Endpoint.subscribe(@cursorview)
    Presence.track(self(), @cursorview, socket.id, %{
      socket_id: socket.id,
      x: 50,
      y: 50,
      p: 50,
      id: 1,

      name: n,
      # cl: M7.parse,
      mu: :erlang.memory(:total)
    })

    initial_users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(:user, n)
      |> assign(:users, initial_users)
      |> assign(:x, 50)
      |> assign(:y, 50)
      |> assign(:p, 50)
      |> assign(:id, 50)
      |> assign(:cl, cells)
      |> assign(c: Presence.list(@cursorview) |> map_size)
      |> assign(s: s)
      |> assign(mu: :erlang.memory(:total))
      |> assign(pc: :erlang.system_info(:process_count))
      |> assign(us:  '')

    {:ok, updated}
  end

  def terminate(_, socket) do
    # IO.inspect socket

  end


  def handle_event("cursor-move", %{"x" => x, "y" => y, "p" => p}, socket) do
    key = socket.id
    # payload = %{x: x, y: y, p: p}
    id = 64*(floor y/16)+(floor x/16)
    payload = %{x: x, y: y, p: p, id: id}

    IO.puts("#{floor x/16} #{floor y/16} #{id} #{p}
    #{inspect socket.assigns.user}
    #{inspect M7cell.get id}
    #{inspect M7cell.ns floor(x/16), floor(y/16), 64, 64}
     ");

    # IO.inspect [x, y, id, p]

    metas =
      Presence.get_by_key(@cursorview, key)[:metas]
      |> List.first()
      |> Map.merge(payload)
      # |> assign(id: id)


    # Presence.update(self(), @cursorview, key, metas)

    # IO.inspect socket

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)
      |> assign(s: M6.get)
      |> assign(id: socket.id)
      |> assign(mu: :erlang.memory(:total))
      |> assign(pc: :erlang.system_info(:process_count))
      |> assign(c: Presence.list(@cursorview) |> map_size)
      # |> assign(:cl, M7.parse)


    {:noreply, updated}
  end



  def render(assigns) do
    ~H"""

<div style="float: right; top: 111px;"><br><br><p>
<button>Make white noise</button>
<audio
        controls
        src="/ts">
    </audio>
</p></div>



<span style="font-size: 24px;"> <%=

  @us

   %> </span>
<span style="font-size: 24px;"> <%= @c %> </span>
<span style="font-size: 24px;"> <%= @mu %> </span>
<span style="font-size: 24px;"> <%= @pc %> </span>

    <%= for user <- @users do %>
    <span style={"font-family:monospace;
    display: inline-block;
    position: absolute; top: "<>"#{user.y}"<>"px;
     left: "<>"#{user.x}"<>"px; "<>
    "filter: hue-rotate("<>"#{111}"<>"deg);
    font-size: "
      <>
    "#{32}"
    <>"px;
    transform: scale("
      <>
    "#{1}"
    <>", 1) rotate("<>
    "#{20}"
    <>"deg);

   filter: contrast(70%)
    hue-rotate( "
      <>
    "#{}"
    <>"deg)
    opacity(70%);
    "

    }><%=  "🦎" <> List.to_string(@s)  %>

    <span style=" position: absolute;
    font-family:monospace;"><%=  M7cell.get(user.id) |> inspect %></span>

   <span id="cursors" phx-hook="TrackClientCursor"
   style=" position: absolute;
   font-family:monospace;  background-color:
    deeppink;"> <%= user.name %></span>
    </span>

    <% end %>

    <%= for e <- @cl do %>
    <pre style={"
    font-size: #{16*e.hue/111}px;
    position: absolute;
     top: #{(e.y-1)*16}px;
     left: "<>"#{e.x*16}"<>"px;
     filter: hue-rotate("<>"#{e.hue}"<>"deg);
     "}><%=
      "#{e.type}"
        %></pre>
    <% end %>

    <script>

const audioCtx = new (window.AudioContext)();
console.log(audioCtx)
// Create an empty three-second stereo buffer at the sample rate of the AudioContext
const myArrayBuffer = audioCtx.createBuffer(1, 111111, 4444);

  const s = new Float32Array(
   <%=
   s = for e <- 1..111111, do:
   (:math.sin(e*(e/128/5)+e/11) + :math.sin(e*0.2*(e/55555)+e/2)
   |> Kernel.* :math.sin(e/32)
   |> Kernel.* :math.sin(e/1024)
   |> Kernel./ 20
   );
   inspect(s, limit: :infinity)
   %>
    );

  myArrayBuffer.copyToChannel(s, 0);

  console.log(s)

///////////////////////
// Get an AudioBufferSourceNode.
// This is the AudioNode to use when we want to play an AudioBuffer
const source = audioCtx.createBufferSource();
// set the buffer in the AudioBufferSourceNode
source.buffer = myArrayBuffer;
// connect the AudioBufferSourceNode to the
// destination so we can hear the sound
source.connect(audioCtx.destination);
// start the source playing
source.start();

    </script>


    """

  end
end

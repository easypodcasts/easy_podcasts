// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket, LongPoll } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let Hooks = {};
Hooks.PlayerHook = {
  async mounted() {
    const { Howl } = await import("howler");
    this.Howl = Howl;
    this.setupPlayer();
  },
  updated() {
    this.player.unload();
    this.setupPlayer();
  },
  destroyed() {
    this.player.unload();
  },
  setupPlayer() {
    const audioUrl = this.el.dataset.audioUrl;

    let progressWrapper = this.el.querySelector("#progress-wrapper");
    let progress = this.el.querySelector("#progress");

    progressWrapper.onclick = (event) => {
      let rect = event.target.getBoundingClientRect();
      let x = event.clientX - rect.left;
      let clickedValue = (x * this.player.duration()) / progressWrapper.offsetWidth;
      this.player.seek(clickedValue);
    };

    let currentTime = this.el.querySelector("#current-time");

    let step = () => {
      var seek = this.player.seek() || 0;
      progress.style.width = ((seek / this.player.duration()) * 100 || 0) + "%";
      let strCurrentTime = new Date(parseInt(seek) * 1000).toISOString().substr(11, 8);
      currentTime.textContent = strCurrentTime;
      if (this.player.playing()) {
        requestAnimationFrame(step);
      }
    };

    let loading = this.el.querySelector("#loading");
    let play_button = this.el.querySelector("#play");
    let pause_button = this.el.querySelector("#pause");

    play_button.onclick = () => {
      this.player.play();
      play_button.classList.add("hidden");
      pause_button.classList.remove("hidden");
    };

    pause_button.onclick = () => {
      this.player.pause();
      pause_button.classList.add("hidden");
      play_button.classList.remove("hidden");
    };

    this.player = new this.Howl({
      src: [audioUrl],
      onload: function () {
        loading.classList.add("hidden");
        pause_button.classList.remove("hidden");
      },
      onplay: function () {
        requestAnimationFrame(step);
      },
      onend: function () {
        pause_button.classList.add("hidden");
        play_button.classList.remove("hidden");
      },
    });

    this.player.play();
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks });

liveSocket.socket.onError((error, transport, establishedConnections) => {
  if (transport === WebSocket && establishedConnections === 0) {
    liveSocket.socket.replaceTransport(LongPoll);
    liveSocket.connect();
  }
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

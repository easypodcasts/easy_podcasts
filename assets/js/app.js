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
  mounted() {
    this.player = this.getElement("audio");
    let progressWrapper = this.getElement("#progress-wrapper");
    let progress = this.getElement("#progress");
    let loading = this.getElement("#loading");
    let playButton = this.getElement("#play");
    let pauseButton = this.getElement("#pause");
    let currentTime = this.getElement("#current-time");

    this.player.onloadeddata = (event) => {
      loading.classList.add("hidden");
      pauseButton.classList.remove("hidden");
      this.player.play();
    };
    this.player.onplay = (event) => {
      playButton.classList.add("hidden");
      pauseButton.classList.remove("hidden");
    };
    this.player.onended = (event) => {
      playButton.classList.remove("hidden");
      pauseButton.classList.add("hidden");
    };
    playButton.onclick = () => {
      this.player.play();
      playButton.classList.add("hidden");
      pauseButton.classList.remove("hidden");
    };
    pauseButton.onclick = () => {
      this.player.pause();
      pauseButton.classList.add("hidden");
      playButton.classList.remove("hidden");
    };
  },
  getElement(el) {
    return this.el.querySelector(el);
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

liveSocket.socket.onError((error, transport, establishedConnections) => {
  if (transport === WebSocket && establishedConnections === 0) {
    liveSocket.socket.replaceTransport(LongPoll);
    liveSocket.connect();
  }
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
let topBarScheduled = undefined;

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });

window.addEventListener("phx:page-loading-start", (info) => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 500);
  }
});
window.addEventListener("phx:page-loading-stop", (info) => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

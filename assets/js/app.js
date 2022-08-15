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

Hooks.AutoFocus = {
  mounted() {
    this.el.focus();
  },
};

Hooks.CopyHook = {
  mounted() {
    const copyButton = document.getElementById("copy-feed-url");
    const url = document.getElementById("feed-url").value;
    copyButton.onclick = () => {
      navigator.clipboard.writeText(url);
    };
  },
};

Hooks.PlayerHook = {
  mounted() {
    this.handleEvent("play", ({ current_time, episode }) =>
      this.setup(current_time, episode)
    );
    this.handleEvent("cleanup", () => this.cleanup());

    let player_state = JSON.parse(localStorage.getItem("player_state"));
    if (player_state) {
      this.pushEvent("play", player_state);
    }
  },

  setup(current_time, episode) {
    this.episode = episode;
    this.player = this.getElement("audio");
    this.player.currentTime = current_time || 0;
    this.progressWrapper = this.getElement("#progress-wrapper");
    this.progress = this.getElement("#progress");
    this.loading = this.getElement("#loading");
    this.playButton = this.getElement("#play");
    this.pauseButton = this.getElement("#pause");
    this.currentTime = this.getElement("#current-time");

    if (current_time) {
      this.player.onloadeddata = (event) => {
        this.updateProgress();
      };
      this.loading.classList.add("hidden");
      this.pause();
    } else {
      this.player.onloadeddata = (event) => {
        this.saveProgress();
        this.play();
      };
    }

    this.player.onended = (event) => {
      this.playButton.classList.remove("hidden");
      this.pauseButton.classList.add("hidden");
    };

    this.playButton.onclick = () => {
      this.play();
    };

    this.pausebutton.onclick = () => {
      clearinterval(this.progresstimer);
      clearinterval(this.savetimer);
      this.pause();
    };

    this.progressWrapper.onclick = (event) => {
      let rect = event.target.getBoundingClientRect();
      let x = event.clientX - rect.left;
      let clickedValue =
        (x * this.player.duration) / this.progressWrapper.offsetWidth;
      this.player.currentTime = clickedValue;
      this.updateProgress();
      this.saveProgress();
    };
  },

  destroyed() {
    this.cleanup();
  },

  play() {
    this.loading.classList.add("hidden");
    this.pauseButton.classList.remove("hidden");
    this.playButton.classList.add("hidden");

    this.progressTimer = setInterval(() => this.updateProgress(), 500);
    this.saveTimer = setInterval(() => this.saveProgress(), 5000);
    this.player.play();
  },

  pause() {
    this.pauseButton.classList.add("hidden");
    this.playButton.classList.remove("hidden");
    this.saveProgress();
    this.player.pause();
  },

  updateProgress() {
    if (isNaN(this.player.duration)) {
      return false;
    }
    this.progress.style.width = `${
      (this.player.currentTime / this.player.duration) * 100
    }%`;
    this.currentTime.innerText = this.formatTime(this.player.currentTime);
  },

  saveProgress() {
    let player_state = {
      episode: this.episode,
      current_time: this.player.currentTime,
    };
    localStorage.setItem("player_state", JSON.stringify(player_state));
  },

  cleanup() {
    this.player.pause();
    clearInterval(this.progressTimer);
    clearInterval(this.saveTimer);
    localStorage.removeItem("player_state");
  },

  formatTime(seconds) {
    return new Date(1000 * seconds).toISOString().substr(14, 5);
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

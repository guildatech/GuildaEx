export default {
  mounted() {
    this._lastSecond = 0;

    this.el.addEventListener("timeupdate", (event) => {
      var currentTime = Math.round(event.target.currentTime);
      if (currentTime !== this._lastSecond && !event.target.paused) {
        this._lastSecond = currentTime;
        this.pushEventTo(`#${this.el.dataset.target}`, "play-second-elapsed", {
          time: currentTime,
        });
      }
    });

    this.el.addEventListener("play", (event) => {
      plausible("StartedListeningToEpisode", {
        props: { id: event.target.dataset.episodeId, slug: event.target.dataset.episodeSlug },
      });
    });
  },
};

export default {
  mounted() {
    this.handleEvent("episode-viewed", (episode) => {
      plausible("ListenedToEpisode", { props: { id: episode.id, slug: episode.slug } });
    });
  },
};

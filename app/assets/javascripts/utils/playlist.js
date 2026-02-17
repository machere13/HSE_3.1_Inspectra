(() => {
  const createSetPlaylist = (state, onChange) => (urls, index, titles) => {
    state.playlist = Array.isArray(urls) ? urls.filter(Boolean) : [];
    state.currentIndex = Math.max(0, Math.min(index | 0, Math.max(0, state.playlist.length - 1)));
    state.playlistTitles = Array.isArray(titles) ? titles.slice(0, state.playlist.length) : [];
    while (state.playlistTitles.length < state.playlist.length) state.playlistTitles.push('');
    if (state.playlist.length > 0 && typeof onChange === 'function') onChange();
  };
  window.createSetPlaylist = createSetPlaylist;
})();

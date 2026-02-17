(() => {
  const GLOBAL_TRANSITION_MS = 280;
  const audio = {
    GLOBAL_CONTAINER_ID: 'js-global-audio-player-container',
    GLOBAL_PANEL_ID: 'js-global-audio-player',
    GLOBAL_TRANSITION_MS: GLOBAL_TRANSITION_MS,
    STORAGE_KEY_VISIBLE: 'globalAudioPlayerVisible',
    STORAGE_KEY_SRC: 'globalAudioPlayerSrc',
    STORAGE_KEY_PLAYLIST: 'globalAudioPlayerPlaylist',
    STORAGE_KEY_INDEX: 'globalAudioPlayerIndex',
    STORAGE_KEY_TIME: 'globalAudioPlayerTime',
    STORAGE_KEY_PAUSED: 'globalAudioPlayerPaused',
    STORAGE_KEY_POSITION: 'globalAudioPlayerPosition',
    STORAGE_KEY_TITLES: 'globalAudioPlayerTitles',
    DATA_ATTR_PLAYLIST: 'data-global-playlist',
    DATA_ATTR_INDEX: 'data-global-index',
    DATA_ATTR_TITLES: 'data-global-titles',
    DATA_ATTR_SRC: 'data-global-src',
    DATA_ATTR_TIME: 'data-global-time',
    DATA_ATTR_PAUSED: 'data-global-paused'
  };
  const video = {
    GLOBAL_CONTAINER_ID: 'js-global-video-player-container',
    GLOBAL_PANEL_ID: 'js-global-video-player',
    GLOBAL_TRANSITION_MS: GLOBAL_TRANSITION_MS,
    STORAGE_KEY_VISIBLE: 'globalVideoPlayerVisible',
    STORAGE_KEY_RECT: 'globalVideoPlayerRect',
    STORAGE_KEY_VIDEO_STATE: 'globalVideoPlayerState'
  };

  window.GlobalMediaConstants = { audio, video };
})();

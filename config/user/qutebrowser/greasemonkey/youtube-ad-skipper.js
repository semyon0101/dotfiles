// ==UserScript==
// @name Skip YouTube ads
// @description Skips the ads in YouTube videos
// @run-at document-start
// @include *.youtube.com/*
// ==/UserScript==

document.addEventListener('load', () => {
    const skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-skip-ad-button');
    if (skipBtn) {
      skipBtn.click();
    }


   const adShowing = document.querySelector('.ad-showing');
        if (adShowing) {
            const video = document.querySelector('video');
            if (video && video.duration) {
                // Устанавливаем время видео в самый конец
                video.currentTime = video.duration;
            }
        }

}, true);

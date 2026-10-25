'use strict';
(() => {
  const input = document.getElementById('demo-input');
  if (!input) return;
  const status = document.getElementById('demo-status');
  const undo = document.getElementById('demo-revert');
  const examples = new Map([['tje', 'the'], ['hellloo', 'hello'], ['tomorow', 'tomorrow'], ['teh', 'the']]);
  let previous = null;
  function resetCorrection() { previous = null; undo.hidden = true; }
  function commit() {
    const match = input.value.match(/([a-z]+)(\s+)$/i);
    resetCorrection();
    if (!match) { status.textContent = 'Choose one of the four examples to try a correction.'; return; }
    const original = match[1];
    let word = examples.get(original.toLowerCase());
    if (!word) { status.textContent = 'This word is outside the four-example illustration.'; return; }
    if (original === original.toUpperCase()) word = word.toUpperCase();
    else if (/^[A-Z]/.test(original)) word = word[0].toUpperCase() + word.slice(1);
    previous = input.value;
    input.value = input.value.slice(0, match.index) + word + match[2];
    status.textContent = `“${original}” became “${word}”. You can undo it.`;
    undo.hidden = false;
  }
  input.addEventListener('input', () => {
    resetCorrection();
    if (/\s$/.test(input.value)) commit();
    else status.textContent = 'Press space to see the idea.';
  });
  document.querySelectorAll('[data-example]').forEach(button => button.addEventListener('click', () => {
    input.value = button.dataset.example;
    resetCorrection(); status.textContent = 'Press space to see the idea.';
    input.focus(); input.setSelectionRange(input.value.length, input.value.length);
  }));
  document.querySelectorAll('[data-key]').forEach(button => button.addEventListener('click', () => {
    const key = button.dataset.key;
    const start = input.selectionStart ?? input.value.length;
    const end = input.selectionEnd ?? start;
    let cursor;
    if (key === 'Backspace') {
      const from = start === end ? Math.max(0, start - 1) : start;
      input.value = input.value.slice(0, from) + input.value.slice(end); cursor = from;
    } else {
      if (input.value.length - (end - start) + key.length > input.maxLength) return;
      input.value = input.value.slice(0, start) + key + input.value.slice(end); cursor = start + key.length;
    }
    resetCorrection(); status.textContent = 'Press space to see the idea.';
    // Only commit at the end; preserve editing and selection in the middle of a sentence.
    if (key === ' ' && cursor === input.value.length) { commit(); cursor = input.value.length; }
    input.setSelectionRange(cursor, cursor);
  }));
  undo.addEventListener('click', () => {
    if (previous === null) return;
    input.value = previous; resetCorrection(); status.textContent = 'Original word restored.';
    input.focus(); input.setSelectionRange(input.value.length, input.value.length);
  });
  document.getElementById('demo-clear').addEventListener('click', () => {
    input.value = ''; resetCorrection(); status.textContent = 'Choose an example or type your own words.'; input.focus();
  });
})();

// Visitors choose a real screen; nothing moves or changes on a timer.
(() => {
  const image = document.getElementById('hero-screen');
  const note = document.getElementById('screen-note');
  if (!image || !note) return;
  const screens = {
    today: ['Today', 'TypeParkinson Today screen with daily rings, a six-tap check and personal insights. Simulator sample data.'],
    practice: ['Practice', 'TypeParkinson Practice screen with spiral tracing, rhythm tapping and typing activities. Simulator sample data.'],
    speak: ['Speak', 'TypeParkinson Speak screen with a message, speech controls and the personal keyboard. Simulator sample data.']
  };
  document.querySelectorAll('[data-screen]').forEach(button => button.addEventListener('click', () => {
    const screen = screens[button.dataset.screen];
    if (!screen) return;
    image.src = `assets/${button.dataset.screen}.webp`;
    image.alt = screen[1];
    note.textContent = `${screen[0]} · Actual app · Simulator sample data`;
    document.querySelectorAll('[data-screen]').forEach(item => item.setAttribute('aria-pressed', String(item === button)));
  }));
})();

(() => {
  const video = document.querySelector('#film video');
  const status = document.getElementById('chapter-status');
  if (!video) return;
  const failure = document.getElementById('film-error');
  video.addEventListener('error', () => { if (failure) failure.hidden = false; });
  video.addEventListener('loadeddata', () => { if (failure) failure.hidden = true; });
  let requested = null;
  function seekRequested() {
    if (requested === null || video.readyState < 1) return;
    video.currentTime = Math.min(requested, video.duration);
    requested = null;
    video.play().catch(() => { if (status) status.textContent = 'Chapter ready. Press Play on the video to begin.'; });
  }
  video.addEventListener('loadedmetadata', seekRequested);
  document.querySelectorAll('[data-film-time]').forEach(button => button.addEventListener('click', () => {
    requested = Number(button.dataset.filmTime);
    if (status) status.textContent = `Playing ${button.firstChild.textContent.trim()}.`;
    if (video.readyState >= 1) seekRequested();
    else video.load();
  }));
})();

var DragPorts = (function() {
  // data must be of the format:
  // { effectAllowed: string, event: DragEvent }
  function processDragStart(data) {
    data.event.dataTransfer.setData("text/plain", null); // needed
    data.event.dataTransfer.effectAllowed = data.effectAllowed;
  }

  // data must be of the format:
  // { dropEffect: string, event: DragEvent }
  function processDragOver(data) {
    data.event.dataTransfer.dropEffect = data.dropEffect;
  }

  // Automatic setup of standard drag ports subscriptions.
  function setup(elmApp) {
    elmApp.ports.dragstart.subscribe(processDragStart);
    elmApp.ports.dragover.subscribe(processDragOver);
  }

  return {
    processDragStart: processDragStart,
    processDragOver: processDragOver,
    setup: setup
  };
})();

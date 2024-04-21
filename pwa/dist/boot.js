// src/boot.js
async function boot({ bootMessage, bootProgress, bootConsoleOutput }) {
  if (!("serviceWorker" in navigator)) {
    console.error("Service Worker is not supported in this browser.");
    return;
  }
  if (navigator.serviceWorker.controller) {
    console.log("Service Worker already active.");
    return navigator.serviceWorker.ready;
  }
  const oldRegistrations = await navigator.serviceWorker.getRegistrations();
  for (const registration of oldRegistrations) {
    await registration.unregister();
  }
  await navigator.serviceWorker.register("/rails.sw.js", {
    scope: "/",
    type: "module"
  });
  navigator.serviceWorker.addEventListener("message", function(event) {
    switch (event.data.type) {
      case "progress": {
        bootMessage.textContent = event.data.step;
        bootProgress.value = event.data.value;
        break;
      }
      case "console": {
        bootConsoleOutput.textContent += event.data.message;
        break;
      }
      default: {
        console.log("Unknown message type:", event.data.type);
      }
    }
  });
  return await navigator.serviceWorker.ready;
}
async function init() {
  const bootMessage = document.getElementById("boot-message");
  const bootProgress = document.getElementById("boot-progress");
  const bootConsoleOutput = document.getElementById("boot-console-output");
  const registration = await boot({ bootMessage, bootProgress, bootConsoleOutput });
  if (!registration) {
    return;
  }
  bootMessage.textContent = "Service Worker Ready";
  bootProgress.value = 100;
  const launchButton = document.getElementById("launch-button");
  launchButton.disabled = false;
  launchButton.addEventListener("click", async function() {
    window.location.href = "/";
  });
  const rebootButton = document.getElementById("reboot-button");
  rebootButton.disabled = false;
  rebootButton.addEventListener("click", async function() {
    await registration.unregister();
    window.location.reload();
  });
}
init();
//# sourceMappingURL=boot.js.map

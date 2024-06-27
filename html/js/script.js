let settings = {
  using24hr: true,
};

let tc = 8;

let values = {
  hours: 8,
  minutes: 0,
  weather: "CLEAR",
  dynamic: false,
  blackout: false,
  freeze: false,
  instanttime: false,
  instantweather: false,
  tsunami: false,
  realtime: false,
  realweather: false,
};

let tsunamiSound;
let tsunamiSoundAvailable = true;

async function generateClouds() {
  const container = document.getElementById("easytime-clouds");

  const body = document.getElementById("easytime-card-body");

  const container_width = body.getBoundingClientRect().width;
  const container_height = body.getBoundingClientRect().height;

  container.innerHTML = "";
  for (let i = 0; i < 17; i++) {
    container.innerHTML +=
      "<img src='images/weathertype/cloudy.svg' style='position:absolute; width:" +
      (Math.floor(Math.random() * 128) + 10) +
      "px; opacity:" +
      Math.random() +
      "; top:" +
      Math.floor(Math.random() * container_height - 10) +
      "px; left:" +
      Math.floor(Math.random() * container_width) +
      "px'class='img-fluid' />";
  }
}
async function generateStars() {
  const container = document.getElementById("easytime-stars");

  const body = document.getElementById("easytime-card-body");

  const container_width = body.getBoundingClientRect().width;
  const container_height = body.getBoundingClientRect().height;

  container.innerHTML = "";

  for (let i = 0; i < 33; i++) {
    container.innerHTML +=
      "<img src='images/weathertype/stars.svg' style='position:absolute; width:" +
      Math.floor(Math.random() * 12) +
      "px; opacity:" +
      Math.random() +
      "; top:" +
      Math.floor(Math.random() * container_height - 10) +
      "px; left:" +
      Math.floor(Math.random() * container_width) +
      "px'class='img-fluid' />";
  }
}

async function post(url, data) {
  return new Promise((resolve, reject) => {
    fetch(url, {
      method: "POST",
      body: JSON.stringify(data),
    })
      .then((response) => {
        resolve(response);
      })
      .catch((error) => {
        reject(error);
      });
  });
}
function closeUI() {
  post("https://cd_easytime/close", {});
}
function easyTimeChange(values, savesettings) {
  post("https://cd_easytime/change", { values, savesettings });
}
function convertTime(hours, minutes) {
  if (hours >= 24) return { hours: Math.abs(hours - 24), minutes: minutes };
  else return { hours: parseFloat(hours), minutes: minutes };
}
async function updateBackground(time) {
  time = time.hours + time.minutes / 60;
  const easytime_card_body = document.getElementById("easytime-card-body");
  const easytime_card_body_width =
    easytime_card_body.getBoundingClientRect().width;
  const easytime_card_body_height =
    easytime_card_body.getBoundingClientRect().height;

  if (time == 0) time = 24;
  if (time >= 8 && time <= 12) {
    easytime_card_body.classList.add("easytime-morning");
    easytime_card_body.classList.remove("easytime-noon");
    easytime_card_body.classList.remove("easytime-afternoon");
    easytime_card_body.classList.remove("easytime-night");

    time = time - 8;
    let l = easytime_card_body_width * (time / 4 / 2) - 32;
    let b = easytime_card_body_height * (time / 4) - 32;
    l = (l / easytime_card_body_width) * 100;
    b = (b / easytime_card_body_height) * 100;

    document.getElementById("easytime-sun").style.left = l + "%";
    document.getElementById("easytime-sun").style.bottom = b + "%";

    easytime_card_body.style.backgroundColor = "var(--easytime-daytime)";
    document.getElementById("easytime-sun").style.display = "block";
    document.getElementById("easytime-moon").style.display = "none";

    document.getElementById("easytime-clouds").style.display = "block";
    document.getElementById("easytime-stars").style.display = "none";
  } else if (time > 12 && time < 21) {
    document.getElementById("easytime-sun").style.display = "block";
    document.getElementById("easytime-moon").style.display = "none";

    document.getElementById("easytime-clouds").style.display = "block";
    document.getElementById("easytime-stars").style.display = "none";

    easytime_card_body.style.backgroundColor = "var(--easytime-daytime)";

    time = time - 12;
    let l = easytime_card_body_width * (time / 8 / 2) - 32;
    let b = easytime_card_body_height * (time / 8) - 32;
    l = (l / easytime_card_body_width) * 100 + 50;
    b = 68 - (b / easytime_card_body_height) * 100;

    document.getElementById("easytime-sun").style.left = l + "%";
    document.getElementById("easytime-sun").style.bottom = b + "%";
  } else if (time >= 21 && time <= 24) {
    document.getElementById("easytime-sun").style.display = "none";
    document.getElementById("easytime-moon").style.display = "block";

    document.getElementById("easytime-clouds").style.display = "none";
    document.getElementById("easytime-stars").style.display = "block";

    easytime_card_body.style.backgroundColor = "var(--easytime-nighttime)";

    time = time - 20;

    let l = easytime_card_body_width * (time / 4 / 2) - 32;
    let b = easytime_card_body_height * (time / 4) - 32;
    l = (l / easytime_card_body_width) * 100;
    b = (b / easytime_card_body_height) * 100;

    document.getElementById("easytime-moon").style.left = l + "%";
    document.getElementById("easytime-moon").style.bottom = b + "%";
  } else {
    document.getElementById("easytime-sun").style.display = "none";
    document.getElementById("easytime-moon").style.display = "block";

    document.getElementById("easytime-clouds").style.display = "none";
    document.getElementById("easytime-stars").style.display = "block";

    easytime_card_body.style.backgroundColor = "var(--easytime-nighttime)";

    let l = easytime_card_body_width * (time / 7 / 2) - 32;
    let b = easytime_card_body_height * (time / 7) - 32;
    l = (l / easytime_card_body_width) * 100 + 50;
    b = 68 - (b / easytime_card_body_height) * 100;

    document.getElementById("easytime-moon").style.left = l + "%";
    document.getElementById("easytime-moon").style.bottom = b + "%";
  }
}
function updateTimeDisplay(hours, minutes) {
  let time;
  if (hours) time = convertTime(hours, minutes);
  else {
    let calculatedTime = numToTime(
      document.getElementById("easytime-range").value
    );
    time = convertTime(calculatedTime.hours, calculatedTime.minutes);
  }

  values.hours = time.hours;
  values.minutes = time.minutes;

  updateBackground(time);
  let newTime;
  if (settings.using24hr) {
    newTime = new Date(
      "1970-02-02T" +
        (time.hours < 10 ? "0" + time.hours : time.hours) +
        ":" +
        (time.minutes < 10 ? "0" + time.minutes : time.minutes) +
        ":00Z"
    ).toLocaleTimeString("en-US", {
      hour12: false,
      hour: "numeric",
      minute: "numeric",
      timeZone: "UTC",
    });
  } else {
    newTime = new Date(
      "1970-02-02T" +
        (time.hours < 10 ? "0" + time.hours : time.hours) +
        ":" +
        (time.minutes < 10 ? "0" + time.minutes : time.minutes) +
        ":00Z"
    ).toLocaleTimeString("en-US", {
      hour12: true,
      hour: "numeric",
      minute: "numeric",
      timeZone: "UTC",
    });
  }

  document.getElementById("easytime-menu-time").innerHTML = newTime;
}
document
  .getElementById("easytime-range")
  .addEventListener("input", function (e) {
    updateTimeDisplay();
  });

document.getElementById("easytime-24hr").addEventListener("click", function () {
  settings.using24hr = !settings.using24hr;

  if (settings.using24hr)
    document.getElementById("easytime-24hr-label").innerHTML = "24 hr";
  else document.getElementById("easytime-24hr-label").innerHTML = "12 hr";
  updateTimeDisplay(values.hours, values.minutes);
});

document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("[data-toggle='tooltip']").forEach((element) => {
    new bootstrap.Tooltip(element, { trigger: "hover" });
  });
  tsunamiSound = new Audio("sound/tsunami_siren.ogg");

  // Replacement for jQuery slideUp animation
  document
    .getElementById("easytime-card")
    .addEventListener("animationend", function () {
      if (this.getAttribute("closing")) {
        this.style.display = "none";

        this.removeAttribute("closing");

        document
          .getElementById("easytime-card")
          .classList.remove("slide-in-bottom");
        document
          .getElementById("easytime-card")
          .classList.remove("slide-out-bottom");
      }
    });
});

window.addEventListener("message", function (event) {
  if (event.data.action == "open") {
    document.getElementById("easytime-card").style.display = "block";
    document.getElementById("easytime-card").classList.add("slide-in-bottom");

    values = event.data.values;

    document
      .querySelectorAll(".easytime-weather-setting")
      .forEach((element) => {
        element.checked = false;
      });

    document.getElementById(
      "easytime-weather-" + values.weather.toLowerCase()
    ).checked = true;

    tc =
      values.hours >= 1 && values.hours <= 7 ? values.hours + 24 : values.hours;

    updateTimeDisplay(tc, values.minutes);

    if (values.dynamic) {
      document.getElementById("easytime-dynamic").checked = true;
    } else document.getElementById("easytime-dynamic").checked = false;

    if (values.blackout) {
      document.getElementById("easytime-blackout").checked = true;
    } else document.getElementById("easytime-blackout").checked = false;

    if (values.freeze) {
      document.getElementById("easytime-freeze").checked = true;
    } else document.getElementById("easytime-freeze").checked = false;

    if (values.instanttime) {
      document.getElementById("easytime-instant-time").checked = true;
    } else document.getElementById("easytime-instant-time").checked = false;

    if (values.instantweather) {
      document.getElementById("easytime-instant-weather").checked = true;
    } else document.getElementById("easytime-instant-weather").checked = false;

    if (values.tsunami) {
      document.getElementById("easytime-tsunami").checked = true;
    } else document.getElementById("easytime-tsunami").checked = false;

    if (values.realtime) {
      document.getElementById("easytime-realtime").checked = true;
      document.getElementById("easytime-range").disabled = true;
    } else {
      document.getElementById("easytime-realtime").checked = false;
      document.getElementById("easytime-range").disabled = false;
    }

    if (values.realweather) {
      document.getElementById("easytime-realweather").checked = true;
      toggleWeatherChanging(true);
    } else {
      document.getElementById("easytime-realweather").checked = false;
      toggleWeatherChanging(false);
    }

    this.document.getElementById("easytime-range").value =
      values.hours >= 1 && values.hours <= 7
        ? values.hours + 24 + values.minutes / 60
        : values.hours + values.minutes / 60;

    generateClouds();
    generateStars();
  } else if (event.data.action == "close") {
    document.getElementById("easytime-card").setAttribute("closing", true);

    document
      .getElementById("easytime-card")
      .classList.remove("slide-in-bottom");
    document.getElementById("easytime-card").classList.add("slide-out-bottom");

    document.getElementById("easytime-card").offsetWidth;
  } else if (event.data.action == "playsound") {
    playSound();
  }
});

document.querySelectorAll(".form-check > input").forEach((element) => {
  element.addEventListener("click", function () {
    if (element.value != "on") values.weather = element.value;
  });
});

document
  .getElementById("easytime-blackout")
  .addEventListener("click", function () {
    values.blackout = !values.blackout;
  });
document
  .getElementById("easytime-freeze")
  .addEventListener("click", function () {
    values.freeze = !values.freeze;
  });
document
  .getElementById("easytime-dynamic")
  .addEventListener("click", function () {
    values.dynamic = !values.dynamic;
  });
document
  .getElementById("easytime-instant-time")
  .addEventListener("click", function () {
    values.instanttime = !values.instanttime;
    post("https://cd_easytime/instanttime", {
      instanttime: values.instanttime,
    });
  });
document
  .getElementById("easytime-instant-weather")
  .addEventListener("click", function () {
    values.instantweather = !values.instantweather;
    post("https://cd_easytime/instantweather", {
      instantweather: values.instantweather,
    });
  });
document
  .getElementById("easytime-tsunami")
  .addEventListener("click", function () {
    values.tsunami = !values.tsunami;
  });
document
  .getElementById("easytime-realtime")
  .addEventListener("click", function () {
    values.realtime = !values.realtime;
    // disable all other radio buttons
    if (values.realtime) {
      document.getElementById("easytime-range").disabled = true;
    } else {
      document.getElementById("easytime-range").disabled = false;
    }
  });

document
  .getElementById("easytime-realweather")
  .addEventListener("click", function () {
    values.realweather = !values.realweather;
    if (values.realweather === true) {
      toggleWeatherChanging(true);
    } else {
      toggleWeatherChanging(false);
    }
  });
document
  .getElementById("easytime-button-close")
  .addEventListener("click", function () {
    window.postMessage({ action: "close" });
    closeUI();
  });
document
  .getElementById("easytime-button-change")
  .addEventListener("click", function () {
    window.postMessage({ action: "close" });

    if (tc == values.hours) {
      easyTimeChange(
        {
          weather: values.weather,
          blackout: values.blackout,
          freeze: values.freeze,
          dynamic: values.dynamic,
          instanttime: values.instanttime,
          instantweather: values.instantweather,
          tsunami: values.tsunami,
          realtime: values.realtime,
          realweather: values.realweather,
        },
        false
      );
    } else easyTimeChange(values, false);
  });
document
  .getElementById("easytime-button-save")
  .addEventListener("click", function () {
    window.postMessage({ action: "close" });
    if (tc == values.hours) {
      easyTimeChange(
        {
          weather: values.weather,
          blackout: values.blackout,
          freeze: values.freeze,
          dynamic: values.dynamic,
          instanttime: values.instanttime,
          instantweather: values.instantweather,
          tsunami: values.tsunami,
          realtime: values.realtime,
          realweather: values.realweather,
        },
        true
      );
    } else easyTimeChange(values, true);
  });

window.addEventListener("keydown", (e) => {
  if (e.code == "Escape" || e.key == "Escape") {
    window.postMessage({ action: "close" });
    closeUI();
  }
});

function toggleWeatherChanging(state) {
  document
    .querySelectorAll("[name='easytime-weather-selector']")
    .forEach((element) => {
      element.disabled = state;
    });
}
function playSound() {
  if (tsunamiSoundAvailable) {
    // Check if the sound stopped playing

    tsunamiSoundAvailable = false; // Set the avaliability to false, since we are going to play it now.
    tsunamiSound.volume = 0.5; // Set the volume to 0.5 (or adjust to your own preference)

    tsunamiSound.play().then(() => {
      tsunamiSound.currentTime = 0; // Reset the position to start
      tsunamiSoundAvailable = true; // Sound stopped playing, so it is now avaliable
    });
  }
}

function numToTime(number) {
  var hour = Math.floor(number);
  var decpart = number - hour;

  var min = 1 / 60;
  decpart = min * Math.round(decpart / min);

  var minute = Math.floor(decpart * 60) + "";

  return { hours: hour, minutes: minute };
}

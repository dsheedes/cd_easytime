let settings = {
	using24hr: true,
};

let originalHours = 8;
let originalMinutes = 0;

// Settings on boot
let defaultTime = null;
let defaultWeather = null;

let values = {
	hours: 8,
	mins: 0,
	weather: "CLEAR",
	dynamic: false,
	blackout: false,
	freeze: false,
	instanttime: false,
	instantweather: false,
	tsunami: false,
	realtime: false,
	realweather: false,
	game_build: 0,
	weathermethod: "realweather", // gameweather realweather,
	timemethod: "realtime", // gametime realtime
	real_info: {
		weather: "",
		weather_description: "",
		country: "",
		city: "",
	},
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
			.catch((error) => {});
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
	values.mins = time.minutes;

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
function toggleWeatherChanging(state) {
	document.getElementById("easytime-dynamic").disabled = state;
	document.getElementById("easytime-dynamic").checked = false;
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
	// decpart = min * Math.round(decpart / min);

	var minute = Math.floor(decpart * 60);

	return { hours: hour, minutes: minute };
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
	updateTimeDisplay(values.hours, values.mins);
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
		// Hide new weather option if game build is less than 3258
		if (Number(values.game_build) < 3258) {
			document.getElementById("new-weather").style.display = "none";
		}

		if (defaultWeather === null) defaultWeather = values.weathermethod;

		if (defaultTime === null) defaultTime = values.timemethod;

		if (values.weathermethod === "realweather") {
			values.realweather = true;
		} else values.realweather = false;

		if (values.timemethod === "realtime") {
			values.realtime = true;
		} else values.realtime = false;

		if (defaultTime === "gameweather") {
			document.getElementById("realweather").style.display = "none";
		} else {
			document.getElementById("real-city").innerHTML =
				values.real_info.city + ", " + values.real_info.country;
			document.getElementById("real-weather").innerHTML =
				values.real_info.weather + ", " + values.real_info.weather_description;
		}
		if (defaultWeather === "gametime") {
			document.getElementById("realtime").style.display = "none";
		} else {
			document.getElementById("real-city").innerHTML =
				values.real_info.city + ", " + values.real_info.country;
		}

		document
			.querySelectorAll(".easytime-weather-setting")
			.forEach((element) => {
				element.checked = false;
			});

		document.getElementById(
			"easytime-weather-" + values.weather.toLowerCase()
		).checked = true;

		originalHours =
			values.hours >= 1 && values.hours <= 7 ? values.hours + 24 : values.hours;

		originalMinutes = values.mins;

		updateTimeDisplay(originalHours, originalMinutes);

		document.getElementById("easytime-dynamic").checked = values.dynamic;
		document.getElementById("easytime-dynamic").disabled = values.realweather;

		document.getElementById("easytime-blackout").checked = values.blackout;
		document.getElementById("easytime-freeze").checked = values.freeze;
		document.getElementById("easytime-instant-time").checked =
			values.instanttime;
		document.getElementById("easytime-instant-weather").checked =
			values.instantweather;
		document.getElementById("easytime-tsunami").checked = values.tsunami;
		document.getElementById("easytime-realtime").checked = values.realtime;
		document.getElementById("easytime-range").disabled = values.realtime;
		document.getElementById("easytime-freeze").disabled = values.realtime;
		document.getElementById("easytime-realweather").checked =
			values.realweather;
		toggleWeatherChanging(values.realweather);

		this.document.getElementById("easytime-range").value =
			values.hours >= 1 && values.hours <= 7
				? values.hours + 24 + values.mins / 60
				: values.hours + values.mins / 60;

		generateClouds();
		generateStars();
	} else if (event.data.action == "close") {
		document.getElementById("easytime-card").setAttribute("closing", true);

		document
			.getElementById("easytime-card")
			.classList.remove("slide-in-bottom");
		document.getElementById("easytime-card").classList.add("slide-out-bottom");

		document.getElementById("easytime-card").offsetWidth;

		// Clear all the tooltips in case they are staying on
		document.querySelectorAll("[data-toggle='tooltip']").forEach((element) => {
			bootstrap.Tooltip.getInstance(element).hide();
		});
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
		values.timemethod = values.realtime ? "realtime" : "gametime";
		// disable all other radio buttons
		document.getElementById("easytime-range").disabled = values.realtime;
		document.getElementById("easytime-freeze").disabled = values.realtime;
	});

document
	.getElementById("easytime-realweather")
	.addEventListener("click", function () {
		values.realweather = !values.realweather;
		values.weathermethod = values.realweather ? "realweather" : "gameweather";
		toggleWeatherChanging(values.realweather);
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
		if (originalHours == values.hours && originalMinutes == values.mins) {
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
					weathermethod: values.realweather ? "realweather" : "gameweather",
					timemethod: values.realtime ? "realtime" : "gametime",
				},
				false
			);
		} else easyTimeChange(values, false);
	});
document
	.getElementById("easytime-button-save")
	.addEventListener("click", function () {
		window.postMessage({ action: "close" });
		if (originalHours == values.hours && originalMinutes == values.mins) {
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
					weathermethod: values.realweather ? "realweather" : "gameweather",
					timemethod: values.realtime ? "realtime" : "gametime",
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

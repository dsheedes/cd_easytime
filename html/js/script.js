let settings = {
    using24hr:true
}

let tc = 8;

let values = {
    time:8,
    weather:"CLEAR",
    dynamic:false,
    blackout:false,
    freeze:false,
    instanttime:false,
    instantweather:false,
    tsunami:false,
}
async function generateClouds(){
    let container = $("#easytime-clouds");
    container.html("");
    for(let i = 0; i < 17; i++){
        container.append("<img src='images/weathertype/cloudy.svg' style='position:absolute; width:"+(Math.floor(Math.random()*128)+10)+"px; opacity:"+Math.random()+"; top:"+Math.floor(Math.random()*container.height()-10)+"px; left:"+Math.floor(Math.random()*container.width())+"px'class='img-fluid' />")
    }
}
async function generateStars(){
    let container = $("#easytime-stars");
    container.html("");
    for(let i = 0; i < 33; i++){
        container.append("<img src='images/weathertype/stars.svg' style='position:absolute; width:"+(Math.floor(Math.random()*12))+"px; opacity:"+Math.random()+"; top:"+Math.floor(Math.random()*container.height()-10)+"px; left:"+Math.floor(Math.random()*container.width())+"px'class='img-fluid' />")
    }
}
function closeUI(){
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://cd_easytime/close", true);                                                                                                                                                                                                                                                                                                                                      
    xhr.send(JSON.stringify({}));
}
function easyTimeChange(values, savesettings){
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://cd_easytime/change", true);                                                                                                                                                                                                                                                                                                                                      
    xhr.send(JSON.stringify({values, savesettings}));
}
function convertTime(time){
    if(time >= 24)
        return Math.abs(time - 24);
    else return parseInt(time);
}
async function updateBackground(time){ //resource god
    if(time == 0)
        time = 24;   
    if(time >= 8 && time <= 12){
        $("#easytime-card-body").addClass("easytime-morning").removeClass("easytime-noon").removeClass("easytime-afternoon").removeClass("easytime-night");
        time = time - 8;
        let l = $("#easytime-card-body").width()*((time/4)/2)-32;
        let b = $("#easytime-card-body").height()*(time/4)-32;
        l = l/$("#easytime-card-body").width()*100;
        b = b/$("#easytime-card-body").height()*100;
        $("#easytime-sun").css({
            left:l+"%",
            bottom:b+"%",
        });
    } else if(time > 12 && time < 21){
        $("#easytime-sun").show(0);
        $("#easytime-moon").hide(0);

        $("#easytime-clouds").show(100);
        $("#easytime-stars").hide(100);

        $("#easytime-card-body").css("background-color", "var(--easytime-daytime)");
        time = time - 12;
        let l = $("#easytime-card-body").width()*((time/8)/2)-32;
        let b = $("#easytime-card-body").height()*(time/8)-32;
        l = l/$("#easytime-card-body").width()*100+50;
        b = 68-(b/$("#easytime-card-body").height()*100);
        $("#easytime-sun").css({
            left:l+"%",
            bottom:b+"%"
        });
        
    } else if(time >= 21 && time <= 24){
        $("#easytime-sun").hide(0);
        $("#easytime-moon").show(0);

        $("#easytime-clouds").hide(100);
        $("#easytime-stars").show(100);

        $("#easytime-card-body").css("background-color", "var(--easytime-nighttime)");
        time = time - 20;
        
        let l = $("#easytime-card-body").width()*((time/4)/2)-32;
        let b = $("#easytime-card-body").height()*(time/4)-32;
        l = l/$("#easytime-card-body").width()*100;
        b = b/$("#easytime-card-body").height()*100;

        $("#easytime-moon").css({
            left:l+"%",
            bottom:b+"%",
        });
    } else{
        $("#easytime-sun").hide(0);
        $("#easytime-moon").show(0);

        $("#easytime-clouds").hide(100);
        $("#easytime-stars").show(100);

        $("#easytime-card-body").css("background-color", "var(--easytime-nighttime)");
        let l = $("#easytime-card-body").width()*((time/7)/2)-32;
        let b = $("#easytime-card-body").height()*(time/7)-32;
        l = l/$("#easytime-card-body").width()*100+50;
        b = 68-(b/$("#easytime-card-body").height()*100);
        $("#easytime-moon").css({
            left:l+"%",
            bottom:b+"%"
        });
    }
}
function updateTimeDisplay(t){
    let time;
    if(t)
        time = convertTime(t);
    else time = convertTime($("#easytime-range").val());
    values.hours = time;
    updateBackground(time);
    let newTime;
    if(settings.using24hr){
        newTime = new Date('1970-02-02T' + ((time < 10) ? "0"+time : time) + ':00:00Z').toLocaleTimeString('en-US',{hour12:false,hour:'numeric',minute:'numeric', timeZone: 'UTC'});
    } else {
        newTime = new Date('1970-02-02T' + ((time < 10) ? "0"+time : time) + ':00:00Z').toLocaleTimeString('en-US',{hour12:true,hour:'numeric',minute:'numeric', timeZone: 'UTC'});
    }
    $("#easytime-menu-time").html(newTime);
}
$(document).on("input", "#easytime-range", function() {
    updateTimeDisplay();
});
$("#easytime-24hr").on("click", ()=>{
    settings.using24hr = !settings.using24hr;

    if(settings.using24hr)
        $("#easytime-24hr-label").html("24 hr")
    else $("#easytime-24hr-label").html("12 hr")
    updateTimeDisplay();
});

window.addEventListener("message", function(event){
    if(event.data.action == "open"){
        $("#easytime-card").slideDown(500);
        values = event.data.values;

        let id = "#easytime-weather-"+values.weather.toLowerCase();

        $(".easytime-weather-setting").each((index, element) => {
            $( element ).prop("checked", false); // Remove all current settings
        });

        $(id).prop("checked", true); // Apply the actual active one


        updateTimeDisplay(((values.hours >=1 && values.hours <= 7)?values.hours+24:values.hours));
        tc = ((values.hours >=1 && values.hours <= 7)?values.hours+24:values.hours);
        
        if(values.dynamic){
            $("#easytime-dynamic").prop("checked", true);
        } else $("#easytime-dynamic").prop("checked", false);

        if(values.blackout){
            $("#easytime-blackout").prop("checked", true);
        } else $("#easytime-blackout").prop("checked", false);

        if(values.freeze){
            $("#easytime-freeze").prop("checked", true);
        } else $("#easytime-freeze").prop("checked", false);

        if(values.instanttime){
            $("#easytime-instant-time").prop("checked", true);
        } else $("#easytime-instant-time").prop("checked", false);
        
        if(values.instantweather){
            $("#easytime-instant-weather").prop("checked", true);
        } else $("#easytime-instant-weather").prop("checked", false);

        if(values.tsunami){
            $("#easytime-tsunami").prop("checked", true);
        } else $("#easytime-tsunami").prop("checked", false);

        $("#easytime-range").val(((values.hours >=1 && values.hours <= 7)?values.hours+24:values.hours));

        generateClouds();
        generateStars();
    } else if(event.data.action == "close"){
        $("#easytime-card").slideUp(300);
    } else if(event.data.action == "playsound"){
        playSound();
    }
});

$(".custom-control > input").on("click", function(){
    if($(this).val() != "on")
        values.weather = $(this).val();
})
$("#easytime-blackout").click(() => {
    values.blackout = !values.blackout;
});
$("#easytime-freeze").click(() => {
    values.freeze = !values.freeze;
});
$("#easytime-dynamic").click(() => {
    values.dynamic = !values.dynamic;
});
$("#easytime-instant-time").click(() => {
    values.instanttime = !values.instanttime;
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://cd_easytime/instanttime", true);                                                                                                                                                                                                                                                                                                                                      
    xhr.send(JSON.stringify({instanttime:values.instanttime}));
})
$("#easytime-instant-weather").click(() => {
    values.instantweather = !values.instantweather;
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "https://cd_easytime/instantweather", true);                                                                                                                                                                                                                                                                                                                                      
    xhr.send(JSON.stringify({instantweather:values.instantweather}));
})
$("#easytime-tsunami").click(() => {
    values.tsunami = !values.tsunami;
});
$("#easytime-button-close").on("click", function() {
    window.postMessage({action:"close"});
    closeUI();
})
$("#easytime-button-change").on("click", function() {
    window.postMessage({action:"close"});

    if(tc == values.hours){
        easyTimeChange({
            weather:values.weather,
            blackout:values.blackout,
            freeze:values.freeze,
            dynamic:values.dynamic,
            instanttime:values.instanttime,
            instantweather:values.instantweather,
            tsunami:values.tsunami,
        }, false);
    } else easyTimeChange(values, false);
    
})
$("#easytime-button-save").on("click", () => {
    var xhr = new XMLHttpRequest();
    let data;

    window.postMessage({action:"close"});

    if(tc == values.hours){
        easyTimeChange({
            weather:values.weather,
            blackout:values.blackout,
            freeze:values.freeze,
            dynamic:values.dynamic,
            instanttime:values.instanttime,
            instantweather:values.instantweather,
            tsunami:values.tsunami,
        }, true);
    } else easyTimeChange(values, true);
});
let tsunamiSound;
let tsunamiSoundAvailable = true;

$(document).ready(function() {
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
      });

    tsunamiSound = new Audio('sound/tsunami_siren.ogg');
})

window.addEventListener("keydown", (e) => {
    if (e.code == "Escape" || e.key == "Escape") {
        window.postMessage({action:"close"});
        closeUI();
    }
});

function playSound(){
    if(tsunamiSoundAvailable){ // Check if the sound stopped playing
        
        tsunamiSoundAvailable = false; // Set the avaliability to false, since we are going to play it now.
        tsunamiSound.volume = 0.5; // Set the volume to 0.5 (or adjust to your own preference)

        tsunamiSound.play().then(() => {
            tsunamiSound.currentTime = 0; // Reset the position to start
            tsunamiSoundAvailable = true; // Sound stopped playing, so it is now avaliable
        });
      }
}
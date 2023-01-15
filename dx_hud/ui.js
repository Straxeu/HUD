lastprave = 'ne';
lastleve = 'ne';
const format = (num, decimals) => num.toLocaleString('en-US', {
   minimumFractionDigits: 2,      
   maximumFractionDigits: 2,
});
hudhidden = 0;
invehicle = 0;
$(document).ready(function() {
    window.addEventListener('message', function(event) {
        var data = event.data;
        if (event.data.action == "updateStatus") {
            updateStatus(event.data.st);
        }
        if (event.data.action == "hideHud") {
            hideHud();
        }
        if (event.data.action == "showHud") {
            showHud();
        }

        if (event.data.action == "sendcooldown") {
            $(".op_narozeni").html("OP zmizí za <strong>"+event.data.cooldownx+"</strong> vteřin ...");
        }
        if (event.data.action == "opdata") {
            $(".op_name").html(event.data.name);
            $(".op_pohlavi").html("Pohlaví: "+event.data.sex);
            $(".op_pohlavix").html("Narozen/a: "+event.data.birthday);
            $(".op_narozeni").html("OP zmizí za <strong>20</strong> vteřin ...");
        }
        if (event.data.action == "updatename") {
            $(".dashcam_name").html(event.data.name);
        }
        if (event.data.action == "hidedashcam") {
            hidehashcam();
        }
        if (event.data.action == "showdashcam") {
            showdashcam();
        }
        if (event.data.action == "hideop") {
            hideop();
        }
        if (event.data.action == "showop") {
            showop();
        }

        if (event.data.action == "unsetbelt") {
            $(".beltimg").attr("src", "beltoff.png");
        }   

        if (event.data.action == "hudStatus") {
            if(event.data.state == 1){
                invehicle = 1;
                if(hudhidden == 1){
                    $(".containerCar").css("display", "none");
                }
                else{
                    $(".containerCar").css("display", "block");
                }
            }
            else{
                invehicle = 0;
                $(".containerCar").css("display", "none");
            }
        }   

        if (event.data.action == "carData") {
            $(".tacho_speed").html(event.data.carspeed + " MPH");
            $(".tacho_gear").html(event.data.gear);
            $(".fuel_data").html(Math.round(event.data.fuel)+'%');
            $('#boxTacho').css('width', event.data.percent+'%');
            $(".fuel_icon").css("display", "inline");

            if(event.data.vehicleengine == 1){
                $(".lights_icon").css("display", "inline");
                $(".limiter_icon").css("display", "inline");
                $(".fuel_icon").css("display", "inline");
                $(".gear_icon").css("display", "inline");
                if(event.data.cruiser == "off"){
                    $(".tacho_speed").css("font-weight", "normal");
                }
                if(event.data.cruiser == "on"){
                    $(".tacho_speed").css("font-weight", "bold");
                }
            }
            else{
                $(".tacho_speed").css("font-weight", "normal");
                $(".gear_icon").css("display", "none");
            }
        }

        if (event.data.action == "update_myid") {
            $(".user_id").html(event.data.userid);
        }
        if (event.data.action == "update_postal") {
            $(".nrp").html(event.data.nearest);
        }
        if (event.data.action == "setbelt") {
            $(".beltimg").attr("src", "belton.png");
        }    
        if (event.data.action == "updateStreet") {
            $(".left_text").html(event.data.st);
            if(event.data.frequency == 0){
                $(".radio_show").css("display", "none");
            }
            else{
                $(".radio_show").css("display", "inline");
                $(".radio_freq").html(event.data.frequency + " Mhz");
            }
        }        
        if (event.data.action == "settime") {
            $(".time").html(event.data.datax);
        }        
        if (event.data.action == "runSpeed") {
        }       


        if (event.data.action == "showVehicleHud") {
        }
        if (event.data.action == "hideVehicleHud") {
        }
        if (event.data.action == "updateWeapon") {
            if(event.data.nuiammo == "0/0"){
                $('.weapon_show').css('display', "none");
                $(".weapon_ammo").html("");
            }
            else{
                $(".weapon_ammo").html(event.data.nuiammo);
                $('.weapon_show').css('display', "inline");

            }
        }
        if (event.data.action == "updateHunger") {
            $('#boxHungerText').html((event.data.value).toFixed(1)+'%');
            $('#boxHunger').css('width', event.data.value+'%');
        }
        if (event.data.action == "updateThirst") {
            $('#boxThirstText').html((event.data.value).toFixed(1)+'%');
            $('#boxThirst').css('width', event.data.value+'%')
        }

        if (event.data.action == "updateHealth") {
            $('#boxHealthText').html((event.data.value).toFixed(0)+'%');
            $('#boxHealth').css('width', event.data.value+'%');
            $('#boxArmorText').html((event.data.valuearmor).toFixed(0)+'%');
            $('#boxArmor').css('width', event.data.valuearmor+'%');
            $('#boxStaminaText').html((event.data.valuestamina).toFixed(0)+'%');
            $('#boxStamina').css('width', event.data.valuestamina+'%');
            if(event.data.podvodou == 1){
                zbyva = ((event.data.lefttime / 30) * 100);
                $(".oxygen").css("display", "block");
                $(".oxygenvalue").css("height", zbyva + "%");
            }
            else{
                $(".oxygen").css("display", "none");
            }
        }

        if (event.data.action == "hide_speedometer"){
            $(".radarcontainer").css("display", "none");
        }
        if (event.data.action == "show_speedometer"){
            $(".radarcontainer").css("display", "block");
        }
        if (event.data.action == "front_set") {
            $(".front_radar").html(event.data.datax);
        }        
        if (event.data.action == "back_set") {
            $(".back_radar").html(event.data.datax);
        }        
    })
})
function hideHud(){
    hudhidden = 1;
    $(".container").css("display", "none");
    $(".containerCar").css("display", "none");
    $(".containerStreet").css("display", "none");
    $(".sign").css("display", "none");
}
function showHud(){
    hudhidden = 0;
    $(".container").css("display", "block");
    if(invehicle == 1){
        $(".containerCar").css("display", "block");
    }
    $(".containerStreet").css("display", "block");
    $(".sign").css("display", "block");
}

function updateStatus(status){
    $('#boxHunger').css('width', status[0].percent+'%')
    $('#boxThirst').css('width', status[1].percent+'%')
    $('#boxDrunk').css('width', status[2].percent+'%')
}

var monthShortNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
];


function dateFormat(d) {
  var t = new Date(d);
  if(t.getDate() >= 0 && t.getDate() <= 9){
    day = "0" + t.getDate();
  }
  else{
    day = t.getDate()
  }
  if(t.getHours() >= 0 && t.getHours() <= 9){
    hour = "0" + t.getHours();
  }
  else{
    hour = t.getHours()
  }
  if(t.getMinutes() >= 0 && t.getMinutes() <= 9){
    minute = "0" + t.getMinutes();
  }
  else{
    minute = t.getMinutes()
  }
  if(t.getSeconds() >= 0 && t.getSeconds() <= 9){
    second = "0" + t.getSeconds();
  }
  else{
    second = t.getSeconds()
  }
  return day + ' ' + monthShortNames[t.getMonth()] + ' ' + t.getFullYear() + ' ' + hour + ':' + minute + ':' + second + ' CET';
}
function dateFormat2(d) {
  var t = new Date(d);
  if(t.getHours() >= 0 && t.getHours() <= 9){
    hour = "0" + t.getHours();
  }
  else{
    hour = t.getHours()
  }
  if(t.getMinutes() >= 0 && t.getMinutes() <= 9){
    minute = "0" + t.getMinutes();
  }
  else{
    minute = t.getMinutes()
  }
  return hour + ':' + minute;
}


var check = function(){
    $(".dash_time").html(dateFormat(new Date()));
    $(".time").html(dateFormat2(new Date()));
    setTimeout(check, 1000); 
}

check();

function showdashcam(){
    $(".dashcam").css("display", "block");
}
function hidehashcam(){
    $(".dashcam").css("display", "none");
}
function showop(){
    $(".op").css("display", "block");
}
function hideop(){
    $(".op").css("display", "none");
}
function loginRadiusInterfacePosition(checkVar, elemName){
	if(elemName == "LoginRadius_settings[LoginRadius_loginform]")
		var elem = document.getElementsByName('LoginRadius_settings[LoginRadius_loginformPosition]');
	else if(elemName == "LoginRadius_settings[LoginRadius_regform]")
		var elem = document.getElementsByName('LoginRadius_settings[LoginRadius_regformPosition]');
	else if(elemName == "LoginRadius_settings[LoginRadius_loginformPosition]"){
		var elem = document.getElementsByName('LoginRadius_settings[LoginRadius_loginform]');
	}else if(elemName == "LoginRadius_settings[LoginRadius_regformPosition]"){
		var elem = document.getElementsByName('LoginRadius_settings[LoginRadius_regform]');
	}
	
	if(!checkVar){
		elem[0].checked = false;
		elem[1].checked = false;
	}else{
		elem[0].checked = true;
	}
}
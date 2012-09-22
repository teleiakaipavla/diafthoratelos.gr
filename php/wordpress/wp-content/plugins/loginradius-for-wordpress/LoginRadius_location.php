<?php
  function loginRadiusLoginInterface()
  {
  		global $LoginRadius_settings;
	 	//$html = Login_Radius_get_interface();
		$lrLogin = ($LoginRadius_settings['LoginRadius_loginform'] == 1) && ($LoginRadius_settings['LoginRadius_loginformPosition'] == "beside");
		$lrRegister = ($LoginRadius_settings['LoginRadius_regform'] == 1) && ($LoginRadius_settings['LoginRadius_regformPosition'] == "beside");
		$script = '<script type="text/javascript">
		jQuery(document).ready(function(){ '.
					'var loginDiv = jQuery("div#login");';
		
		if( $lrLogin && $lrRegister){
			 $script .= 'if(jQuery("#loginform").length || jQuery("#registerform").length || jQuery("#lostpasswordform").length)
						{
							jQuery("#loginform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
							jQuery("#lostpasswordform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
							jQuery("#registerform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
							jQuery("div#login").css(\'width\', \'910px\');
							loginDiv.append("<div class=\"login-sep-text float-left\"><h3>OR</h3></div>");
							
							if( jQuery("#registerform").length ) {
								loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
							}else if( jQuery("#lostpasswordform").length ) {
								loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
								jQuery("#lostpasswordform").css("height", "178px");
							}else if( jQuery("#loginform").length ) {
								loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
								jQuery("#loginform").css("height", "178px");
							}
						}';
		}elseif($lrLogin) {
			$script .= 'if(jQuery("#loginform").length || jQuery("#lostpasswordform").length){
							jQuery("#loginform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
							jQuery("#lostpasswordform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
							jQuery("div#login").css(\'width\', \'910px\');
							loginDiv.append("<div class=\"login-sep-text float-left\"><h3>OR</h3></div>");
							
							if( jQuery("#lostpasswordform").length ) {
								loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
								jQuery("#lostpasswordform").css("height", "178px");
							}else if( jQuery("#loginform").length ) {
								loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
								jQuery("#loginform").css("height", "178px");
							}
						}';
		}elseif($lrRegister){
				$script .= 'if( jQuery("#registerform").length || jQuery("#lostpasswordform").length ){
								jQuery("#registerform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
								jQuery("#lostpasswordform").wrap("<div style=\'float:left; width:400px\'></div>").after(jQuery("#nav")).after(jQuery("#backtoblog"));
								jQuery("div#login").css(\'width\', \'910px\');
								loginDiv.append("<div class=\"login-sep-text float-left\"><h3>OR</h3></div>");

								if( jQuery("#lostpasswordform").length ) {
									loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
									jQuery("#lostpasswordform").css("height", "178px");
								}else if( jQuery("#registerform").length ) {
									loginDiv.append("<div class=\"login-panel-lr\" style=\"height:178px\" >'.Login_Radius_Connect_button(true).'</div>");
									jQuery("#loginform").css("height", "178px");
								}
							}';
		}
		
		$script .= 	 '}'.
					 ');'.
					 '</script>';
		echo $script;
  }

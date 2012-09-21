<?php 

  function LoginRadius_settings_validate($LoginRadius_settings) {

    $LoginRadius_settings ['LoginRadius_apikey'] = $LoginRadius_settings ['LoginRadius_apikey'];

    $LoginRadius_settings ['LoginRadius_secret'] = $LoginRadius_settings ['LoginRadius_secret'];

    $LoginRadius_settings ['LoginRadius_useapi'] = ((isset ($LoginRadius_settings ['LoginRadius_useapi']) AND in_array (           $LoginRadius_settings ['LoginRadius_useapi'], array ('curl', 'fsockopen'))) ? $LoginRadius_settings ['LoginRadius_useapi'] : 'curl');

    $LoginRadius_settings ['LoginRadius_sendemail'] = ((isset ($LoginRadius_settings ['LoginRadius_sendemail']) AND in_array ($LoginRadius_settings ['LoginRadius_sendemail'], array ('sendemail', 'notsendemail'))) ? $LoginRadius_settings ['LoginRadius_sendemail'] : 'sendemail');

    $LoginRadius_settings ['LoginRadius_socialavatar'] = ((isset ($LoginRadius_settings ['LoginRadius_socialavatar']) AND in_array ($LoginRadius_settings ['LoginRadius_socialavatar'], array ('socialavatar', 'defaultavatar'))) ? $LoginRadius_settings ['LoginRadius_socialavatar'] : 'socialavatar');

    $LoginRadius_settings ['LoginRadius_dummyemail'] = ((isset ($LoginRadius_settings ['LoginRadius_dummyemail']) AND in_array ($LoginRadius_settings ['LoginRadius_dummyemail'], array ('notdummyemail', 'dummyemail'))) ? $LoginRadius_settings ['LoginRadius_dummyemail'] : 'notdummyemail');

	$LoginRadius_settings ['LoginRadius_redirect'] = ((isset ($LoginRadius_settings ['LoginRadius_redirect']) AND in_array (     $LoginRadius_settings ['LoginRadius_redirect'], array ('samepage', 'homepage', 'dashboard', 'custom'))) ? $LoginRadius_settings ['LoginRadius_redirect'] : 'samepage');

	$LoginRadius_settings ['LoginRadius_loutRedirect'] = ((isset ($LoginRadius_settings ['LoginRadius_loutRedirect']) AND in_array (     $LoginRadius_settings ['LoginRadius_loutRedirect'], array ('homepage', 'custom'))) ? $LoginRadius_settings ['LoginRadius_loutRedirect'] : 'homepage');

	$LoginRadius_settings ['LoginRadius_loginformPosition'] = ((isset ($LoginRadius_settings ['LoginRadius_loginformPosition']) AND in_array ($LoginRadius_settings ['LoginRadius_loginformPosition'], array ('embed', 'beside'))) ? $LoginRadius_settings ['LoginRadius_loginformPosition'] : 'embed');

	$LoginRadius_settings ['LoginRadius_regformPosition'] = ((isset ($LoginRadius_settings ['LoginRadius_regformPosition']) AND in_array (     $LoginRadius_settings ['LoginRadius_regformPosition'], array ('embed', 'beside'))) ? $LoginRadius_settings ['LoginRadius_regformPosition'] : 'embed');

		

    $LoginRadius_settings ['LoginRadius_title'] = $LoginRadius_settings ['LoginRadius_title'];

    $LoginRadius_settings ['msg_email'] = $LoginRadius_settings ['msg_email'];

    $LoginRadius_settings ['msg_existemail'] = $LoginRadius_settings ['msg_existemail'];

	$LoginRadius_settings ['LoginRadius_share_title'] = $LoginRadius_settings ['LoginRadius_share_title'];

    foreach ( array('LoginRadius_loginform', 'LoginRadius_regform', 'LoginRadius_socialLinking', 'LoginRadius_commentform', 'LoginRadius_autoapprove', 'LoginRadius_sharetop', 'LoginRadius_sharebottom', 'LoginRadius_sharenewwindow', 'LoginRadius_sharehome', 'LoginRadius_sharepost', 'LoginRadius_sharepage','LoginRadius_sharearchive', 'LoginRadius_sharefeed', 'LoginRadius_shareexcerpt') as $val ) {

      if ( isset($LoginRadius_settings[$val]) && $LoginRadius_settings[$val] )
		{
        	$val =((isset ($LoginRadius_settings [$val]) AND  $LoginRadius_settings [$val] == '1') ? '1' : '0');
		}
    }

	$LoginRadius_settings ['custom_redirect'] = $LoginRadius_settings ['custom_redirect'];

	$LoginRadius_settings ['custom_loutRedirect'] = $LoginRadius_settings ['custom_loutRedirect'];

	

    return $LoginRadius_settings;

  }

  function LoginRadius_option_page() {

    global $LoginRadius_settings; ?>

    

	

	<div class="wrap" style="width:800px;">

    <form action="options.php" method="post">

    <?php settings_fields('LoginRadius_setting_options'); ?>

    <?php $LoginRadius_settings = get_option('LoginRadius_settings'); 
	
			if(is_multisite()){
				$socialLoginApi = $LoginRadius_settings['LoginRadius_apikey'];
				$socialLoginSecret = $LoginRadius_settings['LoginRadius_secret'];
				
				if( $socialLoginApi == "" && $socialLoginSecret == "" ){
					global $wpdb;
					$socialLoginMainSettings = $wpdb->get_row( $wpdb->prepare("select option_value from wp_options where option_name = %s", "LoginRadius_settings") );
					$socialLoginMainSettings = maybe_unserialize($socialLoginMainSettings->option_value);
					
					$LoginRadius_settings = $socialLoginMainSettings;
					update_option('LoginRadius_settings', $LoginRadius_settings);
				
				}
			}

	?>

	<h2 class="loginRadiusH2"><b style='color:#00ccff;'>Login</b><b>Radius</b> <?php _e('Settings', 'LoginRadius');?></h2>

	<div class="loginRadiusTopfield">

	<table class="form-table">

	  <tbody>

        <tr>

          <td  colspan="2">

              <fieldset>  

              

          <div class="LoginRadius_container_outer">

		    <div class="LoginRadius_container">

			<h3><?php _e('Thank you for installing the LoginRadius plugin for Social Login and Social Sharing!', 'LoginRadius');?></h3>

			<p align="justify" style="color:333333">

<?php _e('You can customize the settings for your plugin on this page, though you will have to choose your desired ID providers and get your unique', 'LoginRadius');?> <strong> <?php _e('LoginRadius API Key & Secret', 'LoginRadius');?> </strong>

<?php _e('from your', 'LoginRadius').  _e(' account at', 'LoginRadius');?> <a href="http://www.LoginRadius.com" target="_blank">www.LoginRadius.com.</a> <?php _e('There you can also customize your login interface with different login themes and icon sets. By using LoginRadius, the profile data of each user who logs in via social login will be saved to your WordPress database.', 'LoginRadius');?></p>



<p align="justify" style="color:333333"><strong>LoginRadius</strong> <?php _e('is a technology startup based in Canada that offers social login through popular ID providers such as Facebook Twitter Google LinkedIn and over 15 more as well as social sharing on over 80 networks. For tech support or if you have any questions please contact us at', 'LoginRadius');?> <strong>hello@loginradius.com.</strong></p><h3><?php _e('We are available 24/7 to assist our clients!', 'LoginRadius');?></h3>

<p>

<a class="button-secondary" href="http://www.loginradius.com/" target="_blank"><strong><?php _e('Create your FREE account now!', 'LoginRadius');?></strong></a>

</p>

		   </div>

		   

		   

		   <div class="LoginRadius_container_inner">

		   <h3 style="color:black;"><?php _e('Plugin Help', 'LoginRadius');?></h3>

		   <p><ul class="LoginRadius_container_links">
		   
		<li><a href="http://www.loginradius.com/AddOns/WordPress" target="_blank"><?php _e('Plugin Features', 'LoginRadius');?></a></li>
		<li><a href="http://support.loginradius.com/customer/portal/articles/594030-how-do-i-implement-social-login-on-my-wordpress-website-" target="_blank"><?php _e('Documentation', 'LoginRadius');?></a></li>
		
		<li><a href="http://wordpress.loginradius.com/" target="_blank"><?php _e('Live Demo (Wordpress)', 'LoginRadius');?></a></li>
		<li><a href="http://buddypress.loginradius.com/" target="_blank"><?php _e('Live Demo (BuddyPress)', 'LoginRadius');?></a></li>
		<li><a href="http://bbpress.loginradius.com/" target="_blank"><?php _e('Live Demo (bbPress)', 'LoginRadius');?></a></li>
		
		<li><a href="https://www.loginradius.com/LoginRadius/WhatIsLoginRadius" target="_blank"><?php _e('About LoginRadius', 'LoginRadius');?></a></li>

		<li><a href="http://www.loginradius.com/Product/SocialLogin" target="_blank"><?php _e('LoginRadius Products', 'LoginRadius');?></a></li>

		<li><a href="http://www.loginradius.com/AddOns" target="_blank"><?php _e('Other AddOns', 'LoginRadius');?></a></li>
		
		<li><a href="http://blog.LoginRadius.com" target="_blank"><?php _e('LoginRadius Blog', 'LoginRadius');?></a></li>

		<li><a href="http://support.loginradius.com/customer/portal/topics/272884-wordpress-plugin/articles" target="_blank"><?php _e('WP Social Login Support', 'LoginRadius');?></a></li>

		<li><a href="https://www.loginradius.com/LoginRadius/Contact" target="_blank"><?php _e('Contact LoginRadius', 'LoginRadius');?></a></li>


		</ul>

           </p>

		   </div>

	</div>

	</fieldset>	

            </td>

        </tr>

	</tbody>

</table>

</div>

    <div class="page-header loginRadiusTabs" id="tabs">

       <!-- <img alt='LoginRadius' src="//cache.LoginRadius.com/icons/v1/thumbs/32x32/more.png" class="header-img"/>-->

        <ul class="nav-tab-wrapper">

            <li style="width:auto" > <h2 class="nav-tab-wrapper loginRadiusH2"><a href="#tabs-3"><?php _e('LoginRadius API Settings', 'LoginRadius') ?></a></h2></li>

            <li style="width:auto" ><h2 class="nav-tab-wrapper loginRadiusH2"><a href="#tabs-1"><?php _e('Social Login', 'LoginRadius') ?> </a></h2></li>

            <li style="width:auto" ><h2 class="nav-tab-wrapper loginRadiusH2"><a href="#tabs-2"><?php _e('Social Share', 'LoginRadius') ?></a></h2></li>

        </ul>

        <div class='clear'>&nbsp;</div> 

        <div id="tabs-1">

<table class="form-table">

				<tbody>

					

<tr>

            <td colspan="2">

              <fieldset>  

				<legend>&nbsp; <?php _e('LoginRadius Login & Redirection Settings', 'LoginRadius');?> &nbsp;</legend>		

<table>		



<tr >

<th scope="row"><?php _e("Show Social Icons On", 'LoginRadius'); ?><br /><small><?php _e("where to show social icons", 'LoginRadius'); ?></small></th>

	<td>

	

<input type="checkbox" onchange="loginRadiusInterfacePosition( this.checked, this.name )" name="LoginRadius_settings[LoginRadius_loginform]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_loginform']); ?>/> <?php _e ('Show on Login Page', 'LoginRadius'); ?> <br />

			<input type="radio" onchange="loginRadiusInterfacePosition( this.checked, this.name )" name="LoginRadius_settings[LoginRadius_loginformPosition]" value="embed" <?php echo (($LoginRadius_settings['LoginRadius_loginform']== 1) && ($LoginRadius_settings['LoginRadius_loginformPosition'] == "embed"))? "checked" : ""; ?>/> <?php _e ('Embed in Login Form', 'LoginRadius'); ?><br />

			<input type="radio" onchange="loginRadiusInterfacePosition( this.checked, this.name )" name="LoginRadius_settings[LoginRadius_loginformPosition]" value="beside" <?php echo (($LoginRadius_settings['LoginRadius_loginform']== 1) && ($LoginRadius_settings['LoginRadius_loginformPosition'] == "beside"))? "checked" : "" ?>/> <?php _e ('Show Beside Login Form', 'LoginRadius'); ?> 



<br />

<br />

<input type="checkbox" onchange="loginRadiusInterfacePosition( this.checked, this.name)" name="LoginRadius_settings[LoginRadius_regform]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_regform']); ?>/> <?php _e ('Show on Register Page', 'LoginRadius'); ?> <br />

			<input type="radio" onchange="loginRadiusInterfacePosition( this.checked, this.name )" name="LoginRadius_settings[LoginRadius_regformPosition]" value="embed" <?php echo (($LoginRadius_settings['LoginRadius_regform']== 1) && ($LoginRadius_settings['LoginRadius_regformPosition'] == "embed"))? "checked" : ""; ?>/> <?php _e ('Embed in Register Form', 'LoginRadius'); ?><br />

			<input type="radio" onchange="loginRadiusInterfacePosition( this.checked, this.name )" name="LoginRadius_settings[LoginRadius_regformPosition]" value="beside" <?php echo (($LoginRadius_settings['LoginRadius_regform']== 1) && ($LoginRadius_settings['LoginRadius_regformPosition'] == "beside"))? "checked" : "" ?>/> <?php _e ('Show Beside Register Form', 'LoginRadius'); ?> 



<br />

<br />





<input type="checkbox" name="LoginRadius_settings[LoginRadius_commentform]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_commentform']); ?>/> <?php _e ('Show on Comment Form', 'LoginRadius'); ?> 

</td>

</tr>



<tr >

<th scope="row"><?php _e("Social Linking", 'LoginRadius'); ?><br /></th>

	<td>



<input type="checkbox" name="LoginRadius_settings[LoginRadius_socialLinking]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_socialLinking']); ?>/> <?php _e ('Link existing wordpress user accounts to Social Login (if any)', 'LoginRadius'); ?> 

<br />

</td>

</tr>



<tr class="row_white">

	<th scope="row"><?php _e("Show Social Avatar", 'LoginRadius'); ?><br /><small><?php _e("social provider avatar image on comment", 'LoginRadius'); ?></small></th>

	<td>

	<?php   $socialavatar = "";

			$defaultavatar = "";

			if ($LoginRadius_settings["LoginRadius_socialavatar"] == "socialavatar" ) $socialavatar = "checked='checked'";

			else if ($LoginRadius_settings["LoginRadius_socialavatar"] == "defaultavatar") $defaultavatar = "checked='checked'";

			else $socialavatar = "checked='checked'";

		?>

<input name="LoginRadius_settings[LoginRadius_socialavatar]" type="radio"  <?php echo $socialavatar;?> value="socialavatar"/><?php _e("Use Social provider avatar (if provide)", 'LoginRadius'); ?> <br />

<input name="LoginRadius_settings[LoginRadius_socialavatar]" type="radio" <?php echo $defaultavatar;?> value="defaultavatar" /><?php _e("Use default avatar", 'LoginRadius'); ?> 

</td>

	</tr>

	<tr >

<th scope="row"><?php _e('Auto Approve Social User\'s Comments', 'LoginRadius'); ?><br />

<small><?php _e('if user logged in using social login', 'LoginRadius'); ?></small></th>

	<td>

<input type="checkbox" name="LoginRadius_settings[LoginRadius_autoapprove]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_autoapprove']); ?>/> <?php _e ('Automatically approve comments made by social login users', 'LoginRadius'); ?> 

</td>

</tr>

	<tr >

<th scope="row"><?php _e("Login Redirection Setting", 'LoginRadius');?><br /><small><?php _e("Redirect user After login", 'LoginRadius'); ?></small></th>

	<td>

	<?php     $samepage = "";

              $homepage = "";

              $dashboard = "";

              $custom = "";

             if ($LoginRadius_settings["LoginRadius_redirect"] == "samepage") $samepage = "checked='checked'";

			 else if ($LoginRadius_settings["LoginRadius_redirect"] == "homepage") $homepage = "checked='checked'";

			 else if ($LoginRadius_settings["LoginRadius_redirect"] == "dashboard") $dashboard = "checked='checked'";

			 else if ($LoginRadius_settings["LoginRadius_redirect"] == "custom") $custom = "checked='checked'";

			 else $samepage = "checked='checked'";

		?>

	<input type="radio" name="LoginRadius_settings[LoginRadius_redirect]" value="samepage" <?php echo $samepage;?>/> <?php _e ('Redirect to Same Page of blog', 'LoginRadius');?> <strong>(<?php _e ('Default', 'LoginRadius') ?>)</strong><br />



<input type="radio" name="LoginRadius_settings[LoginRadius_redirect]" value="homepage" <?php echo $homepage;?> /> <?php _e ('Redirect to homepage of blog', 'LoginRadius');?> 

<br />

<input type="radio" name="LoginRadius_settings[LoginRadius_redirect]" value="dashboard" <?php echo $dashboard;?>/> <?php _e ('Redirect to account dashboard', 'LoginRadius');?>

<br />

<input type="radio" name="LoginRadius_settings[LoginRadius_redirect]" value="custom" <?php echo $custom;?>/> <?php _e ('Redirect to the following url:', 'LoginRadius');?>

<br />

<input type="text"  name="LoginRadius_settings[custom_redirect]" size="60" value="<?php if($LoginRadius_settings["LoginRadius_redirect"]=='custom'){echo htmlspecialchars($LoginRadius_settings["custom_redirect"]);}else{} ?>" />

</td>

</tr>



<!--*************** logout redirection setting *********** -->



<tr >

<th scope="row"><?php _e('Logout Redirection Setting', 'LoginRadius');?><br /><small><?php _e('Redirect user After logout', 'LoginRadius') ?> <br/> <?php _e('(Only for Login Radius widget area)', 'LoginRadius'); ?></small></th>

	<td>

	<?php     

              $homepage = "";

              $custom = "";

			 

			 if ($LoginRadius_settings["LoginRadius_loutRedirect"] == "custom" && $LoginRadius_settings["custom_loutRedirect"] != "")
			{
			 	$custom = "checked='checked'";
			}
			else
			{
				$homepage = "checked='checked'";
			}
		?>

	<input type="radio" name="LoginRadius_settings[LoginRadius_loutRedirect]" value="homepage" <?php echo $homepage;?>/> <?php _e ('Redirect to Home Page of blog', 'LoginRadius');?> <strong>(<?php _e ('Default', 'LoginRadius') ?>)</strong>

<br />



	<input type="radio" name="LoginRadius_settings[LoginRadius_loutRedirect]" value="custom" <?php echo $custom;?>/> <?php _e ('Redirect to the following url:', 'LoginRadius');?> 

<br />



<input type="text"  name="LoginRadius_settings[custom_loutRedirect]" size="60" value="<?php if($LoginRadius_settings["LoginRadius_loutRedirect"]=='custom'){echo htmlspecialchars($LoginRadius_settings["custom_loutRedirect"]);}else{} ?>" />

</td>

</tr>



<!--*************** logout redirection setting end *********** -->



<tr>

	<th scope="row"><?php _e("Select API Credential", 'LoginRadius'); ?><br /><small><?php _e("To Communicate with API", 'LoginRadius'); ?></small></th>

	<td>

	  <?php   $curl = "";

			  $fsockopen = "";

			  if ($LoginRadius_settings["LoginRadius_useapi"] == "curl") $curl = "checked='checked'";

	          else if ($LoginRadius_settings["LoginRadius_useapi"] == "fsockopen") $fsockopen = "checked='checked'";

              else $curl = "checked='checked'";?>

<input name="LoginRadius_settings[LoginRadius_useapi]" type="radio"  <?php echo $curl;?> value="curl" /><?php _e("Use cURL (Require cURL support = enabled in your php.ini settings)", 'LoginRadius'); ?> <br />

<input name="LoginRadius_settings[LoginRadius_useapi]" type="radio" <?php echo $fsockopen;?> value="fsockopen" /><?php _e("Use FSOCKOPEN (Require allow_url_fopen = On and safemode = off in your php.ini settings)", 'LoginRadius'); ?> 

</td>

	</tr>

</table>

	 </fieldset>	

            </td>

        </tr>	

		

		<tr>

            <td colspan="2">

              <fieldset>  

				<legend>&nbsp; <?php _e("LoginRadius Basic Settings", 'LoginRadius'); ?> &nbsp;</legend>		

<table>		<tr>

	<th scope="row"><?php _e("Title", 'LoginRadius'); ?></th>

	<td><?php _e("This text displyed above the Social login button.", 'LoginRadius'); ?>

	<br />

	<input type="text"  name="LoginRadius_settings[LoginRadius_title]" size="60" value="<?php if($LoginRadius_settings ['LoginRadius_title']) { echo htmlspecialchars ($LoginRadius_settings ['LoginRadius_title']); }else { _e('Please Login with', 'LoginRadius');} ?>" />

</td>

	</tr>

	<tr class="row_white">

	<th scope="row"><?php _e("Send Email", 'LoginRadius'); ?><br /><small><?php _e('After user registration', 'LoginRadius'); ?></small></th>

	<td><?php _e('Select YES if you would to like send an email to user after registration.', 'LoginRadius'); ?>

	<br />

<?php       $sendemail = "";

			$notsendemail = "";

			if ($LoginRadius_settings["LoginRadius_sendemail"] == "sendemail") $sendemail = "checked='checked'";

			else if ($LoginRadius_settings["LoginRadius_sendemail"] == "notsendemail") $notsendemail = "checked='checked'";

			else $sendemail = "checked='checked'";

		?>

<?php _e("Yes", 'LoginRadius'); ?> <input name="LoginRadius_settings[LoginRadius_sendemail]" type="radio"  value="sendemail" <?php echo $sendemail;?> />&nbsp;&nbsp;&nbsp;&nbsp;

<?php _e("No", 'LoginRadius'); ?> <input name="LoginRadius_settings[LoginRadius_sendemail]" type="radio" value="notsendemail" <?php echo $notsendemail;?> />

</td>

	</tr>

	<tr>

	<th scope="row"><?php _e("Email Required", 'LoginRadius'); ?></th>

	<td><?php _e("A few ID providers do not provide user's Email ID. Select YES if you would like an email pop-up after login or select NO if you would like to auto-generate the email address.", 'LoginRadius'); ?>

	</td>

	</tr>

	<tr>

	<th></th>

	<td>

	<?php   $dummyemail = "";

			$notdummyemail = "";

			if ($LoginRadius_settings["LoginRadius_dummyemail"] == "notdummyemail") $dummyemail = "checked='checked'";

			else if ($LoginRadius_settings["LoginRadius_dummyemail"] == "dummyemail") $notdummyemail = "checked='checked'";

			else $dummyemail = "checked='checked'";

		?>

<?php _e("Yes", 'LoginRadius'); ?> <input name="LoginRadius_settings[LoginRadius_dummyemail]" type="radio" value"notdummyemail" <?php echo $dummyemail;?> />&nbsp;&nbsp;&nbsp;&nbsp;

<?php _e("No", 'LoginRadius'); ?> <input name="LoginRadius_settings[LoginRadius_dummyemail]" type="radio" value="dummyemail" <?php echo $notdummyemail;?>  />

	</td>

	</tr>

	<tr class="row_white">

	<th></th>

	<td> 

<?php 

 _e('This text will be displayed on the email popup', 'LoginRadius'); ?> <br/>

<input size="60" type="text" name="LoginRadius_settings[msg_email]"  value="<?php if($LoginRadius_settings ['msg_email']) { echo htmlspecialchars ($LoginRadius_settings ['msg_email']); }else { _e('Please enter your email to proceed', 'LoginRadius'); } ?>" /><br />

<?php _e('This text will be displayed on the email popup if the email is already registered or invalid', 'LoginRadius'); ?> <br/>

<input size="60" type="text" name="LoginRadius_settings[msg_existemail]"  value="<?php if($LoginRadius_settings ['msg_existemail']) { echo htmlspecialchars ($LoginRadius_settings ['msg_existemail']); }else { _e('The email you entered is already registered or invalid, Please enter a valid email address', 'LoginRadius');} ?>" />

</td>

</tr>

</table>

	 </fieldset>	

            </td>

        </tr>	

<!----></tbody>

</table>

			

<div class='clear'>&nbsp;</div>  

			<br/>

		</div>

		

        <div id="tabs-2">

			<table class="form-table">

				<tbody>

<tr>

            <td colspan="2">

              <fieldset>  

				<legend>&nbsp; <?php _e('LoginRadius Share Basic Settings', 'LoginRadius'); ?> &nbsp;</legend>		

<table>		<tr>

	<th scope="row"><?php _e("Title", 'LoginRadius'); ?></th>

	<td><?php _e("This text displayed above the Social Share button", 'LoginRadius'); ?>

	<br />

	<input type="text"  name="LoginRadius_settings[LoginRadius_share_title]" size="60" value="<?php if($LoginRadius_settings ['LoginRadius_share_title']) { echo htmlspecialchars ($LoginRadius_settings ['LoginRadius_share_title']); }else { _e('Share it now', 'LoginRadius');} ?>" />

</td>

	</tr>

	

<!--<tr >

<th scope="row"><?php _e("Open in new window", 'LoginRadius'); ?><br /><small><?php _e("opened new window for sharing", 'LoginRadius'); ?></small></th>

	<td>

<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharenewwindow]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharenewwindow']); ?>/> <?php _e ('Open share link in new Window', 'LoginRadius'); ?> 

</td>

</tr>-->

	</table>

	 </fieldset>	

            </td>

        </tr>	

		<tr>

<td colspan="2">

<fieldset>  

<legend>&nbsp; <?php _e("LoginRadius Share Location Settings", 'LoginRadius'); ?> &nbsp;</legend>		

<table>

<tr >

<th scope="row"><?php _e("Social Share Position", 'LoginRadius'); ?><br /><small><?php _e("where to show social share bar", 'LoginRadius'); ?></small></th>

	<td>

<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharetop]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharetop']); ?>/> <?php _e ('Show on Top', 'LoginRadius'); ?> <br />



<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharebottom]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharebottom']); ?>/> <?php _e ('Show on Bottom', 'LoginRadius'); ?> 

</td>

</tr>

<tr>		

<th scope="row"><?php _e("Social Share Location", 'LoginRadius'); ?><br /><small><?php _e("which location to show social share bar", 'LoginRadius'); ?></small></th>



<td>

<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharehome]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharehome']); ?>/> <?php _e ('Show on Home page', 'LoginRadius'); ?> <br />



<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharepost]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharepost']); ?>/> <?php _e ('Show on Posts', 'LoginRadius'); ?> 

<br />

<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharepage]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharepage']); ?>/> <?php _e ('Show on Pages', 'LoginRadius'); ?> <br />



<input type="checkbox" name="LoginRadius_settings[LoginRadius_shareexcerpt]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_shareexcerpt']); ?>/> <?php _e ('Show on post excerpts ', 'LoginRadius'); ?> <br />



<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharearchive]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharearchive']); ?>/> <?php _e ('Show on archives pages', 'LoginRadius'); ?> 

<br />

<input type="checkbox" name="LoginRadius_settings[LoginRadius_sharefeed]" value="1" <?php checked('1', $LoginRadius_settings['LoginRadius_sharefeed']); ?>/> <?php _e ('Show on the feed', 'LoginRadius'); ?> 

</td>

</tr>

</table>

	 </fieldset>	

            </td>

        </tr>	

	</tbody>

</table>

<div class='clear'>&nbsp;</div>

		</div>

<!-- ********   tabs-3 start ********** -->		

		<div id="tabs-3" tabindex="0">

		<table class="form-table">

				<tbody>



		<tr>

            <td colspan="2">

              <fieldset>  

				<legend>&nbsp; <?php _e('LoginRadius API Settings', 'LoginRadius');?> &nbsp;</legend>		

<table>		<tr >

	<th scope="row"><?php _e('LoginRadius API key', 'LoginRadius');?><br /><small><?php _e('Required for Social Login and Social Share', 'LoginRadius') ?></small></th>

	<td><?php _e("Paste LoginRadius API Key here. To get the API Key, log in to", 'LoginRadius'); ?> 

<a href='http://www.LoginRadius.com/' target='_blank'>LoginRadius.</a><br/>

<input size="60" type="text" id="LoginRadius_settings[LoginRadius_apikey]" name="LoginRadius_settings[LoginRadius_apikey]" value="<?php echo (isset ($LoginRadius_settings ['LoginRadius_apikey']) ? htmlspecialchars ($LoginRadius_settings ['LoginRadius_apikey']) : ''); ?>" autofill='off' autocomplete='off'  /></td>

	</tr>

	<tr >

	<th scope="row"><?php _e('LoginRadius API Secret', 'LoginRadius');?><br /><small><?php _e('Required for Social Login', 'LoginRadius');?></small></th>

	<td><?php _e("Paste LoginRadius API Secret here. To get the API Secret, log in to ", 'LoginRadius'); ?><a href='http://www.LoginRadius.com/' target='_blank'>LoginRadius.</a><br/>

	<input size="60" type="text" id="LoginRadius_settings[LoginRadius_secret]" name="LoginRadius_settings[LoginRadius_secret]" value="<?php echo (isset ($LoginRadius_settings ['LoginRadius_secret']) ? htmlspecialchars ($LoginRadius_settings ['LoginRadius_secret']) : ''); ?>" autofill='off' autocomplete='off'  /></td>

	</tr>

	</table>

	 </fieldset>	

            </td>

        </tr>

		</tbody>

		</table>

		</div>	

<!-- ********   tabs-3 ends********** -->		

    

	</div>

    <div class="clear">&nbsp;</div>

	

    <p class="submit" >

    <?php

    // Build Preview Link

         $preview_link = esc_url( get_option( 'home' ) . '/' );

         if ( is_ssl() )
		 {
              $preview_link = str_replace( 'http://', 'https://', $preview_link );
		 }
         $stylesheet = get_option('stylesheet');

         $template = get_option('template');

         $preview_link = htmlspecialchars( add_query_arg( array( 'preview' => 1, 'template' => $template, 'stylesheet' => $stylesheet, 'preview_iframe' => true, 'TB_iframe' => 'true' ), $preview_link ) );

    ?>    

		<input type="submit" name="save" value="<?php _e("Save Changes", 'LoginRadius'); ?>" />

		<a href="<?php echo $preview_link; ?>" class="thickbox thickbox-preview" id="preview" ><?php _e('Preview', 'LoginRadius'); ?></a>

    </p>

   </form>

   </div>

<?php }?>
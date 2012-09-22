<?php

/*Plugin Name:Social Login for wordpress  

Plugin URI: http://www.LoginRadius.com

Description: Description: Add Social Login and Social Sharing to your WordPress website and also get accurate User Profile Data and Social Analytics.

Version: 2.4.3

Author: LoginRadius Team

Author URI: http://www.LoginRadius.com

License: GPL2+

*/

include('LoginRadius_function.php');

include('LoginRadius_widget.php');

include('LoginRadius_admin.php');

include('LoginRadiusSDK.php');



/**

 * Class that handling the overall process of plugin.

 */

class Login_Radius_Connect {



/**

 * Function that call all the function in class.

 */

  public static function init() {

    add_action('parse_request', array(get_class(), 'connect'));

    add_action('wp_enqueue_scripts', array(get_class(), 'LoginRadius_front_css_custom_page'));

    add_action('wp_enqueue_scripts', array(get_class(), 'LoginRadius_page_scripts'));


    add_filter('LR_logout_url', array(get_class(), 'log_out_url'), 20, 2);

    add_action('login_head', 'wp_enqueue_scripts', 1);
	
	add_action( 'login_enqueue_scripts', array(get_class(),'loginRadiusStylesheet') );
  }

	/**
	
	 * Function that adds stylesheet on wp-login page.
	
	 */
 	public static function loginRadiusStylesheet()
	{ ?>
    	<link rel="stylesheet" href="<?php echo plugins_url('css/loginRadiusStyle.css', __FILE__); ?>" type="text/css" media="all" />
	<?php
	}

	/**
	
	 * Function that add jquery.
	
	 */
	
  public static function LoginRadius_page_scripts() {
	if(!wp_script_is('jquery')) {		
		wp_deregister_script('jquery');
		wp_register_script('jquery', 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js', false, '1.7.1');
	
		wp_enqueue_script('jquery');
  	}	
  }



/**

 * Function that add js to admin.

 */

  public static function LoginRadius_admin_scripts() {

    wp_enqueue_scripts('loginRadiusAdmin', plugins_url('js/loginRadiusAdmin.js', __FILE__), array(), false, false);

  }



/**

 * Function that adding css.

 */	

  public static function LoginRadius_front_css_custom_page() {

    wp_register_style('LoginRadius-plugin-frontpage-css', plugins_url('css/loginRadiusStyle.css', __FILE__), array(), '1.0.0', 'all');

    wp_enqueue_style('LoginRadius-plugin-frontpage-css');

  }



/**

 * Function that uses for logout.

 */

  public static function log_out_url() {

    $redirect = get_permalink();

    $link = '<a href="' . wp_logout_url($redirect) . '" title="' . e__('Logout', 'LoginRadius') . '">' . e__('Logout', 'LoginRadius') . '</a>';

    echo apply_filters('Login_Radius_log_out_url', $link);

  }

  

/**

 * Function that verifying a new user if using popup.

 */

  private static function loginRadiusVerify() {

    global $wpdb;

    $lrVerifyKey = mysql_real_escape_string(trim($_GET['loginRadiusVk']));

    $lrVerifyUserId = mysql_real_escape_string(intval(trim($_GET['uid'])));

    if (isset($_GET['loginRadiusPvider']) && trim($_GET['loginRadiusPvider']) != '') {

      $loginRadiusProvider = mysql_real_escape_string(trim($_GET['loginRadiusPvider']));

      $lrProviderCheck = true;

    }

    else {

      $lrProviderCheck = false;

    }

    if ($lrProviderCheck) {

      $wp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id = %d AND meta_key = '".$loginRadiusProvider."LoginRadiusVkey' and meta_value = %s", $lrVerifyUserId, $lrVerifyKey));

    }

    else {

      $wp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id = %d AND meta_key = 'loginRadiusVkey' and meta_value = %s", $lrVerifyUserId, $lrVerifyKey));

    }

    if (!empty($wp_user_id)) {

      if ($lrProviderCheck) {	

        update_user_meta( $wp_user_id, $loginRadiusProvider.'LrVerified', '1');

        delete_user_meta( $wp_user_id, $loginRadiusProvider.'LoginRadiusVkey', $lrVerifyKey);

      }

      else {

        update_user_meta( $wp_user_id, 'loginRadiusVerified', '1');

        delete_user_meta( $wp_user_id, 'loginRadiusVkey', $lrVerifyKey);

      }

      self::lrNotVerified( "Your email has been successfully verified. Now you can login into your account." );

    }

    else
	{
      wp_redirect(site_url());
	}
      return;

  }

/**

 * Function that handle the login and register functionality.

 */	

  public static function connect() {

    global $wpdb;

    // email verification

  if (isset($_GET['loginRadiusVk']) && trim($_GET['loginRadiusVk']) != '' && isset($_GET['uid']) && trim($_GET['uid']) != '') {

      self::loginRadiusVerify();

    }	

    $LoginRadius_settings = get_option('LoginRadius_settings');

    $LoginRadius_secret = $LoginRadius_settings['LoginRadius_secret'];

    $dummyemail = $LoginRadius_settings['LoginRadius_dummyemail'];

    $obj = new LoginRadius();

    $lrdata = array();

    $userprofile = $obj->loginradius_get_data($LoginRadius_secret);

    if ($obj->IsAuthenticated == true && !is_user_logged_in() && !is_admin()) {

      $lrdata = self::loginradius_get_profiledata($userprofile);

      if (!empty($lrdata['Email']) OR (empty($lrdata['Email']) && $dummyemail == 'dummyemail')) {

        if (empty($lrdata['Email']) && $dummyemail == 'dummyemail') {
		
		  	// check if already verified or pending
          $loginRadiusProvider2 = $lrdata['Provider'];

          $wp_user_lrid2 = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE meta_key='".$loginRadiusProvider2."Lrid' AND meta_value = %s", $lrdata['id']));

          if (!empty($wp_user_lrid2)) {

            $lrVerified2 = get_user_meta( $wp_user_lrid2, $loginRadiusProvider2.'LrVerified', true);

            if ($lrVerified2 == '1') {	// Check if lrid is the smae that verified email.

              self::set_cookies($wp_user_lrid2);

              $redirect = LoginRadius_redirect();

              wp_redirect($redirect);
				return;
            }

            else {

              // Verify email

              self::lrNotVerified("Please verify your email by clicking the confirmation link sent to you.");
				return;
            }

          }

          $lrdata['Email'] = self::loginradius_get_randomEmail($lrdata);

        }

        // look for users with the id match

        $wp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE meta_key='id' AND meta_value = %s", $lrdata['id']));

        if (empty($wp_user_id)) {
		
          // Look for a user with the same email

          $wp_user_obj = get_user_by('email', $lrdata['Email']);

          // get the userid from the  email if the query failed

          $wp_user_id  = $wp_user_obj->ID;

        }

        // check verification status of the email

        if (!empty($wp_user_id)) {

          $loginRadiusUserInfo = get_userdata( $wp_user_id );

          $loginRadiusCaps = isset($loginRadiusUserInfo->caps) ? $loginRadiusUserInfo->caps : array('administrator' => ''); 

          if ($LoginRadius_settings['LoginRadius_socialLinking'] == 1) {

            $wp_user_id_tmp = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id = %d and meta_key='id'", $wp_user_id));

            if (empty($wp_user_id_tmp) && $loginRadiusCaps['administrator'] != 1) {

              update_user_meta($wp_user_id, 'id', $lrdata['id']);

              update_user_meta($wp_user_id, 'thumbnail', $lrdata['thumbnail']);

            }

          }

          $wp_tmp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id = %d and meta_key='loginRadiusVerified'", $wp_user_id));

          if (!empty($wp_tmp_user_id)) { 

            // check if verification field exists.

            $wp_verified = $wpdb->get_var($wpdb->prepare("SELECT meta_value FROM $wpdb->usermeta WHERE user_id = %d and meta_key='loginRadiusVerified'", $wp_user_id));

            if ($wp_verified == '1') {	

              // if email is verified

              self::set_cookies($wp_user_id);

              $redirect = LoginRadius_redirect();

              wp_redirect($redirect);

            }

            else {

				self::socialLoginRegistrationStatus();
                $loginRadiusDs = DIRECTORY_SEPARATOR;

                include(getcwd().$loginRadiusDs.'wp-admin'.$loginRadiusDs.'includes'.$loginRadiusDs.'user.php');

                wp_delete_user( $wp_user_id );

                self::add_new_wpuser($lrdata);


            }

          }

          else {

            // set cookies manually since wp_signon requires the username/password combo.

            self::set_cookies($wp_user_id);

            $redirect = LoginRadius_redirect();

            wp_redirect($redirect);

          }

        } // check verification status of the email ends.

        else {

			self::socialLoginRegistrationStatus();
            self::add_new_wpuser($lrdata);

        }

      }

      if (empty($lrdata['Email']) && $dummyemail == 'notdummyemail') {

        global $wpdb;

        $msg = "<p>" . trim(strip_tags($LoginRadius_settings['msg_email'])) . "</p>";

        // Look for users with the id match.

        $wp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE meta_key='id' AND meta_value = %s", $lrdata['id']));

        if (!empty($wp_user_id)) {

          // Check if verified field exist or not.

          $loginRadiusVfyExist = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id = %d AND meta_key = 'loginRadiusVerified'", $wp_user_id));
		  
          if ( !empty($loginRadiusVfyExist) ) {		// if verified field exists
			
            $loginRadiusVerify = $wpdb->get_var($wpdb->prepare("SELECT meta_value FROM $wpdb->usermeta WHERE user_id = %d AND meta_key = 'loginRadiusVerified'", $wp_user_id));
			if( $loginRadiusVerify != '1')
			{
            	self::lrNotVerified("Please verify your email by clicking the confirmation link sent to you.");
            	return;
			}
          }

          // Set cookies manually since.

          self::set_cookies($wp_user_id);

          $redirect = LoginRadius_redirect();

          wp_redirect($redirect);


        }

        else {	

          $loginRadiusProvider = $lrdata['Provider'];

          $wp_user_lrid = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE meta_key='".$loginRadiusProvider."Lrid' AND meta_value = %s", $lrdata['id']));

          if (!empty($wp_user_lrid)) {

            $lrVerified = get_user_meta( $wp_user_lrid, $loginRadiusProvider.'LrVerified', true);

            if ($lrVerified == '1') {	// Check if lrid is the smae that verified email.

              self::set_cookies($wp_user_lrid);

              $redirect = LoginRadius_redirect();

              wp_redirect($redirect);

            }

            else {

              // Verify email

              self::lrNotVerified("Please verify your email by clicking the confirmation link sent to you.");

            }

          }

          else {

			  self::socialLoginRegistrationStatus();
              self::set_tmpuser_data($lrdata);

              self::popup($lrdata, $msg);

          }

        }

      } // Check email ends.

    } // Autantication ends

    if (isset($_POST['sociallogin_emailclick'])) {

      if($_POST['sociallogin_emailclick'] == "Submit") {

        $user_email = mysql_real_escape_string(trim($_POST['email']));

        if (!is_email($user_email)) {

          // If email not in correct format.

          $msg = "<p style='color:red;'>" . trim(strip_tags($LoginRadius_settings['msg_existemail'])) . "</p>";

          $lrdata['session'] = $_POST['session'];

          self::popup($lrdata, $msg);

        }

        else {

          // Email is in correct format.

          $lrdata = array();

          $tmp_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE meta_key='tmpsession' AND meta_value = %s", $_POST['session']));

          $lrdata['session'] = get_user_meta( $tmp_user_id, 'tmpsession', true);

          if (isset($lrdata['session']) && isset($_POST['session']) && $lrdata['session'] == $_POST['session']) {

            // if email exists.

            if ($loginRadiusUserId = email_exists($user_email)) {

              $loginRadiusProvider = get_user_meta( $tmp_user_id, 'tmpProvider', true);

              $loginRadiusId = get_user_meta( $tmp_user_id, 'tmpid', true);

              // Check if email is verified for this provider.

              $loginRadius_user_id = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id=%d and meta_key='".$loginRadiusProvider."LrVerified' AND meta_value = '1'", $loginRadiusUserId));

              if (!empty($loginRadius_user_id)) {

                // if email is verified for this provider.

                $loginRadius_user_lrid = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id=%d and meta_key='".$loginRadiusProvider."Lrid' AND meta_value = %s", $loginRadiusUserId, $loginRadiusId));

                if (!empty($loginRadius_user_lrid)) {

                  // If the user is the one who verified email.

                  // Login user.

                  self::set_cookies($loginRadius_user_lrid);

                  $redirect = LoginRadius_redirect();

                  wp_redirect($redirect);

                }

                else {

                  // This is not the user who verified email.

                  $msg = "<p style='color:red;'>" . trim(strip_tags($LoginRadius_settings['msg_existemail'])) . "</p>";

                  $lrdata['session'] = $_POST['session'];

                  self::popup($lrdata, $msg);

                }

              }

              else {

                // Check if verification is pending for this provider.

                $loginRadiusUnverifiedUid = $wpdb->get_var($wpdb->prepare("SELECT user_id FROM $wpdb->usermeta WHERE user_id=%d and meta_key='".$loginRadiusProvider."LrVerified' AND meta_value = '0'", $loginRadiusUserId));

                if (!empty($loginRadiusUnverifiedUid)) {

                  // Verification pending.

                  $loginRadiusMetaLrid = get_user_meta($loginRadiusUserId, $loginRadiusProvider.'Lrid', true);

                  if ($loginRadiusMetaLrid == $loginRadiusId) {

                    // If verification pending for this login radius id.

                    // Show notification.

                    self::lrNotVerified("Please verify your email by clicking the confirmation link sent to you.");

                  }

                  else {

                    $loginRadiusKey = $loginRadiusUserId.time().mt_rand();

                    update_user_meta($loginRadiusUserId, $loginRadiusProvider.'Lrid', $loginRadiusId);

                    update_user_meta($loginRadiusUserId, $loginRadiusProvider.'LrVerified', '0');

                    update_user_meta($loginRadiusUserId, $loginRadiusProvider.'LoginRadiusVkey', $loginRadiusKey);

                    self::loginRadiusVerifyUser( $loginRadiusUserId, $user_email, $loginRadiusKey, $loginRadiusProvider);

                    self::lrNotVerified("Your Confirmation link Has Been Sent To Your Email Address. Please verify your email by clicking on confirmation link.");

                  }

                }

                else {

                  $loginRadiusKey = $loginRadiusUserId.time().mt_rand();

                  update_user_meta($loginRadiusUserId, $loginRadiusProvider.'Lrid', $loginRadiusId);

                  update_user_meta($loginRadiusUserId, $loginRadiusProvider.'LrVerified', '0');

                  update_user_meta($loginRadiusUserId, $loginRadiusProvider.'LoginRadiusVkey', $loginRadiusKey);

                  self::loginRadiusVerifyUser( $loginRadiusUserId, $user_email, $loginRadiusKey, $loginRadiusProvider);

                  self::lrNotVerified("Your Confirmation link Has Been Sent To Your Email Address. Please verify your email by clicking on confirmation link.");

                }

              }

            } // Email exists check ends.

            else {	 

              // New user.

              $lrdata['session'] = get_user_meta($tmp_user_id, 'tmpsession', true);

              $lrdata['id'] = get_user_meta($tmp_user_id, 'tmpid', true);

              $lrdata['FullName'] = get_user_meta($tmp_user_id, 'tmpFullName', true);

              $lrdata['ProfileName'] = get_user_meta($tmp_user_id, 'tmpProfileName', true);

              $lrdata['NickName'] = get_user_meta($tmp_user_id, 'tmpNickName', true);

              $lrdata['Fname'] = get_user_meta($tmp_user_id, 'tmpFname', true);

              $lrdata['Lname'] = get_user_meta($tmp_user_id, 'tmpLname', true);

              $lrdata['Provider'] = get_user_meta($tmp_user_id, 'tmpProvider', true);

              $lrdata['thumbnail'] = get_user_meta($tmp_user_id, 'tmpthumbnail', true);

              $lrdata['aboutme'] = get_user_meta($tmp_user_id, 'tmpaboutme', true);

              $lrdata['website'] = get_user_meta( $tmp_user_id, 'tmpwebsite', true);

              $lrdata['Email'] = mysql_real_escape_string(trim($_POST['email']));

              self::add_new_wpuser($lrdata, true);

            }

          }

        }

      }

    }

  } //connect ends

 /**
  * check if new user registration is allowed
  */
 private static function socialLoginRegistrationStatus(){
	include_once( ABSPATH . 'wp-admin/includes/plugin.php' );
	if( is_plugin_active('s2member/s2member.php') ){
	
		if(is_multisite()){
			$tempArr = get_option('ws_plugin__s2member_options'); 
			if( $tempArr['mms_registration_grants'] == "none" ){
				wp_redirect('wp-login.php?registration=disabled');
				exit();
			}
		}else{
			if (!get_option('users_can_register') ) {
				wp_redirect('wp-login.php?registration=disabled');
				exit();
			}
		}
	}else{
	  if (!get_option('users_can_register') ) {
		wp_redirect('wp-login.php?registration=disabled');
		exit();
	  }
    }
	return;
 }


/**

 * Function that adding a new wp user.

 */

  private static function add_new_wpuser($lrdata, $loginRadiusPopup = false) {

    global $wpdb; 

    $LoginRadius_settings = get_option('LoginRadius_settings');

    $dummyemail = $LoginRadius_settings['LoginRadius_dummyemail'];

    $user_pass = wp_generate_password();

    $aboutme = $lrdata['aboutme'];

    $website = $lrdata['website'];

    $id = $lrdata['id'];

    $thumbnail = $lrdata['thumbnail'];

    if (isset($id) && !empty($id)) {

      if (!empty($lrdata['Email'])) {

        $email = $lrdata['Email'];

      }

      if (!empty($lrdata['Fname']) && !empty($lrdata['Lname'])) {

        $username = $lrdata['Fname'] . ' ' . $lrdata['Lname'];

        $fname = $lrdata['Fname'];

        $lname = $lrdata['Lname'];

      }

      elseif (!empty($lrdata['FullName'])) {

        $username = $lrdata['FullName'];

        $fname = $lrdata['FullName'];

        //$lname = $lrdata['FullName'];

      }

      elseif (!empty($lrdata['ProfileName'])) {

        $username = $lrdata['ProfileName'];

        $fname = $lrdata['ProfileName'];

        //$lname = $lrdata['ProfileName'];

      }

      elseif (!empty($lrdata['NickName'])) {

        $username = $lrdata['NickName'];

        $fname = $lrdata['NickName'];

        //$lname = $lrdata['NickName'];

      }

      elseif (!empty($email)) {

        $user_name = explode('@', $email);

        $username = $user_name[0];

        $fname = str_replace("_", " ", $user_name[0]);

        //$lname = str_replace("_"," ",$user_name[0]);

      }

      else {

        $username = $lrdata['id'];

        $fname = $lrdata['id'];

        //$lname = $lrdata['id'];

      }

      $role = get_option('default_role');

      $sendemail  = $LoginRadius_settings['LoginRadius_sendemail'];

      //look for user with username match	

      $nameexists = true;

      $index = 0;

	  $username = str_replace(' ', '-', $username);
      $userName   = $username;

      while ($nameexists == true) {

        if (username_exists($userName) != 0) {

          $index++;

          $userName = $username . $index;

        }

        else {

          $nameexists = false;

        }

      }

      $username = $userName;

      $userdata = array(

                    'user_login' => $username,

                    'user_nicename' => $fname,

                    'user_email' => $email,

                    'display_name' => $fname,

                    'nickname' => $fname,

                    'first_name' => $fname,

                    'last_name' => $lname,

                    'description' => $aboutme,

                    'user_url' => $website,

                    'role' => $role

                  );

      //$user_id = wp_create_user( $username,$user_pass,$email );

      $user_id = wp_insert_user($userdata);

      self::unset_tmpuser_data($lrdata);

      if ($sendemail == 'sendemail') {

        wp_new_user_notification($user_id, $user_pass);

      }

      if (!is_wp_error($user_id)) {

        if (!empty($email)) {

          $user = wp_signon(array(

                             'user_login' => $username,

                             'user_password' => $user_pass,

                             'remember' => true

                             ), false);

          do_action('LR_registration', $user, $username, $email, $user_pass, $userdata);

      }

      if (is_wp_error($user)) {} 

	  else {}

      if (!empty($email)) {

        update_user_meta($user_id, 'email', $email);

      }

      if (!empty($id)) {

        update_user_meta($user_id, 'id', $id);

      }

      if (!empty($thumbnail)) {

        update_user_meta($user_id, 'thumbnail', $thumbnail);

      }

	  if ( $loginRadiusPopup ) {

        $loginRadiusKey = $user_id.time().mt_rand();

        update_user_meta($user_id, 'loginRadiusVkey', $loginRadiusKey);

        update_user_meta($user_id, 'loginRadiusVerified', '0');

        self::loginRadiusVerifyUser( $user_id, $email, $loginRadiusKey);

        self::lrNotVerified("Your Confirmation link Has Been Sent To Your Email Address. Please verify your email by clicking on confirmation link.");

        return;

      }

      wp_clear_auth_cookie();

      wp_set_auth_cookie($user_id);

      wp_set_current_user($user_id);

      $redirect = LoginRadius_redirect();

      wp_redirect($redirect);

    }

    else {

      wp_redirect($redirect);

    }

  }

}



/**

 * Function that verify new wp user.

 */

  private static function loginRadiusVerifyUser($loginRadiusUserId, $loginRadiusEmail, $loginRadiusKey, $loginRadiusProvider="") {

    $loginRadiusSubject = "[".get_option('blogname')."] Email Verification";

    $loginRadiusUrl = site_url()."?loginRadiusVk=".$loginRadiusKey."&uid=".$loginRadiusUserId;

    if (!empty($loginRadiusProvider))
	{
      $loginRadiusUrl .= "&loginRadiusPvider=".$loginRadiusProvider;
	}
      $loginRadiusMessage = "Please click on the following link to verify your email \r\n".$loginRadiusUrl;

      wp_mail( $loginRadiusEmail, $loginRadiusSubject, $loginRadiusMessage);

  }



/**

 * Function that asking for enter email.

 */

  private static function popup($lrdata, $msg) {

    $output = '<div class="LoginRadius_overlay" id="fade"><div id="popupouter"><div id="popupinner"><div id="textmatter">';

	if ($msg) {

      $output .= "<b>" . $msg . "</b>";

    }

    $output .= '</div><form method="post" action=""><div><input type="text" name="email" id="email" class="inputtxt"/></div><div><input type="submit" id="sociallogin_emailclick" name="sociallogin_emailclick" value="Submit" class="inputbutton"><input type="Submit" name="sociallogin_emailclick" value="Cancel" class="inputbutton" /> <input type="hidden" value="'.$lrdata['session'].'" name = "session"/> <input type="hidden" value="'.$lrdata['Provider'].'" name = "lrProvider"/>';

    $output .= '</div></form></div></div></div>';

    print $output;

  }



/**

 * Function that asking for enter email.

 */

  private static function lrNotVerified($loginRadiusMsg) {

    $output = '<div class="LoginRadius_overlay" id="fade"><div id="popupouter"><div id="popupinner"><div id="textmatter">';

    $output .= "<b> ".$loginRadiusMsg." </b>";

    $output .= '</div><form method="post" action=""><div><input type="submit" value="OK" class="inputbutton"></div></form></div></div></div>';

    print $output;

  }



/**

 * Function that setting up cookies for user.

 */

  private static function set_cookies($user_id = 0, $remember = true) {

    if (!function_exists('wp_set_auth_cookie'))
	{
      return false;
	}
    if (!$user_id)
	{
      return false;
	}
    if (!$user = get_userdata($user_id))
	{
      return false;
	}
    wp_clear_auth_cookie();

    wp_set_auth_cookie($user_id, $remember);

    wp_set_current_user($user_id);

    return true;

  }



/**

 * Function that setting up tmp data in db.

 */

  private static function set_tmpuser_data($lrdata) {

    $tmpdata = array();

    $tmpdata['tmpsession'] = $lrdata['session'];

    $tmpdata['tmpid'] = $lrdata['id'];

    $tmpdata['tmpFullName'] = $lrdata['FullName'];

    $tmpdata['tmpProfileName'] = $lrdata['ProfileName'];

    $tmpdata['tmpNickName'] = $lrdata['NickName'];

    $tmpdata['tmpFname'] = $lrdata['Fname'];

    $tmpdata['tmpLname'] = $lrdata['Lname'];

    $tmpdata['tmpProvider'] = $lrdata['Provider'];

    $tmpdata['tmpthumbnail'] = $lrdata['thumbnail'];

    $tmpdata['tmpaboutme'] = $lrdata['aboutme'];

    $tmpdata['tmpwebsite'] = $lrdata['website'];

    $tmpdata['tmpEmail'] = $lrdata['Email'];

    $uni_id = $tmpdata['tmpsession'];

    $uniqu_id = explode('.',$uni_id);

    $unique_id = $uniqu_id[1];

    if (!is_numeric($unique_id)) {

      $unique_id = rand();

    }

    $key = array('tmpid', 'tmpsession', 'tmpEmail', 'tmpFullName', 'tmpProfileName', 'tmpNickName', 'tmpFname', 'tmpLname', 'tmpProvider', 'tmpthumbnail','tmpaboutme', 'tmpwebsite'); 

    foreach ($tmpdata as $key => $value) {

      update_user_meta( $unique_id, $key, $value);

    }

  }



/**

 * Function that delete tmp data from db.

 */

  private static function unset_tmpuser_data($lrdata) {

    $tmpdata = array();

	$tmpdata['tmpsession'] = $lrdata['session'];

    $tmpdata['tmpid'] = $lrdata['id'];

	$tmpdata['tmpFullName'] = $lrdata['FullName'];

	$tmpdata['tmpProfileName'] = $lrdata['ProfileName'];

	$tmpdata['tmpNickName'] = $lrdata['NickName'];

	$tmpdata['tmpFname'] = $lrdata['Fname'];

	$tmpdata['tmpLname'] = $lrdata['Lname'];

	$tmpdata['tmpProvider'] = $lrdata['Provider'];

	$tmpdata['tmpthumbnail'] = $lrdata['thumbnail'];

	$tmpdata['tmpaboutme'] = $lrdata['aboutme'];

	$tmpdata['tmpwebsite'] = $lrdata['website'];

	$tmpdata['tmpEmail'] = $lrdata['Email'];

	$uni_id = $tmpdata['tmpsession'];

	$uniqu_id = explode('.',$uni_id);

	$unique_id = $uniqu_id[1];

    $key = array('tmpid', 'tmpsession', 'tmpEmail', 'tmpFullName', 'tmpProfileName', 'tmpNickName', 'tmpFname', 'tmpLname', 'tmpProvider', 'tmpthumbnail','tmpaboutme', 'tmpwebsite'); 

    foreach ($tmpdata as $key => $value) {

      delete_user_meta( $unique_id, $key, $value );

    }

  }

  

/**

 * Function that getting data from lr.

 */

  private static function loginradius_get_profiledata($userprofile) {

    $lrdata['id'] = (!empty($userprofile->ID) ? $userprofile->ID : '');

    $lrdata['session'] = uniqid('LoginRadius_', true);

    $lrdata['Email'] = $userprofile->Email[0]->Value;

    $lrdata['FullName'] = (!empty($userprofile->FullName) ? $userprofile->FullName : '');

    $lrdata['ProfileName'] = (!empty($userprofile->ProfileName) ? $userprofile->ProfileName : '');

    $lrdata['NickName'] = (!empty($userprofile->NickName) ? $userprofile->NickName : '');

    $lrdata['Fname'] = (!empty($userprofile->FirstName) ? $userprofile->FirstName : '');

    $lrdata['Lname'] = (!empty($userprofile->LastName) ? $userprofile->LastName : '');

    $lrdata['Provider'] = (!empty($userprofile->Provider) ? $userprofile->Provider : '');

    $lrdata['thumbnail'] = (!empty($userprofile->ImageUrl) ? trim($userprofile->ImageUrl) : '');

    if (empty($lrdata['thumbnail']) && $lrdata['Provider'] == 'facebook') {

      $lrdata['thumbnail'] = "http://graph.facebook.com/" . $lrdata['id'] . "/picture?type=large";

    }

    $lrdata['aboutme'] = (!empty($userprofile->About) ? $userprofile->About : '');

    $lrdata['website'] = (!empty($userprofile->ProfileUrl) ? $userprofile->ProfileUrl : '');

	return $lrdata;

  }

  

/**

 * Function that generate a random mail.

 */

  private static function loginradius_get_randomEmail($lrdata) {

    switch ($lrdata['Provider']) {

      case 'twitter':

        $lrdata['Email'] = $lrdata['id'] . '@' . $lrdata['Provider'] . '.com';

        break;

            

      case 'linkedin':

        $lrdata['Email'] = $lrdata['id'] . '@' . $lrdata['Provider'] . '.com';

        break;

                        

      default:

        $Email_id = substr($lrdata['id'], 7);

        $Email_id2 = str_replace("/", "_", $Email_id);

        $lrdata['Email'] = str_replace(".", "_", $Email_id2) . '@' . $lrdata['Provider'] . '.com';

        break;

    }

	return $lrdata['Email'];

  }

}// Class ends.



add_action('init', array('Login_Radius_Connect', 'init'));



/**

 * Function adding avatar image to user.

 */

function loginradius_custom_avatar($avatar, $avuser, $size, $default, $alt = '') {

  $LoginRadius_settings = get_option('LoginRadius_settings');

  $socialavatar = $LoginRadius_settings['LoginRadius_socialavatar'];

  if ($socialavatar == 'socialavatar') {

    $user_id = null;

    if (is_numeric($avuser)) {

      if ($avuser > 0) {

        $user_id = $avuser;

      }

    }

    else if (is_object($avuser)) {

      if (property_exists($avuser, 'user_id') AND is_numeric($avuser->user_id)) {

        $user_id = $avuser->user_id;

      }

    }

    if (!empty($user_id)) {

      if (($user_thumbnail = get_user_meta($user_id, 'thumbnail', true)) !== false) {

        if (strlen(trim($user_thumbnail)) > 0) {

          return '<img alt="' . esc_attr($alt) . '" src="' . $user_thumbnail . '" class="avatar avatar-' . $size . ' " height="' . $size . '" width="' . $size . '" />';

        }

      }

    }

  }

  return $avatar;

}

add_filter('get_avatar', 'loginradius_custom_avatar', 10, 5);



/**

 * This function makes sure is able to load the different language files from

 * the i18n subfolder 

 **/

function LoginRadius_init_locale() {

  global $LoginRadiuspluginpath;

  load_plugin_textdomain('LoginRadius', false, basename(dirname(__FILE__)) . '/i18n');

}

add_filter('init', 'LoginRadius_init_locale');



/**

 * Add the LoginRadius menu to the Settings menu

 */

function LoginRadius_admin_menu() {

  $page = add_options_page('LoginRadius', '<b style="color:#0ccdfe;">Login</b><b style="color:#000;">Radius</b>', 8, 'LoginRadius', 'LoginRadius_option_page');

  add_action('admin_print_scripts-' . $page, 'LoginRadius_options_page_scripts');

  add_action('admin_print_styles-' . $page, 'LoginRadius_options_page_style');

  add_action('admin_print_styles-' . $page, 'LoginRadius_admin_css_custom_page');

}

add_action('admin_menu', 'LoginRadius_admin_menu');



/**

 * Add option to admin on init.

 */

function LoginRadius_options_init() {

  register_setting('LoginRadius_setting_options', 'LoginRadius_settings', 'LoginRadius_settings_validate');

}

add_action('admin_init', 'LoginRadius_options_init');



/**

 * Add Settings CSS.

 */

function LoginRadius_get_wp_version() {

  return (float) substr(get_bloginfo('version'), 0, 3);

}



/**

 * Add Settings js.

 */

function LoginRadius_options_page_scripts() {

  $script = (LoginRadius_get_wp_version() >= 3.2) ? 'loginradius_options-page32.js' : 'loginradius_options-page29.js';

  $script_location = apply_filters('LoginRadius_files_uri', plugins_url('js/' . $script, __FILE__));

  wp_enqueue_script('LoginRadius_options_page_script', $script_location, array(

        'jquery-ui-tabs',

        'thickbox'

  ));

  wp_enqueue_script('LoginRadius_options_page_script2', plugins_url('js/loginRadiusAdmin.js', __FILE__), array(), false, false);

}



/**

 * Add option Settings css.

 */

function LoginRadius_options_page_style() {

  $style_location = apply_filters('LoginRadius_files_uri', plugins_url('css/loginRadiusOptionsPage.css', __FILE__));

  wp_enqueue_style('LoginRadius_options_page_style', $style_location);

  wp_enqueue_style('thickbox');

}



/**

 * Add custom page Settings css.

 */

function LoginRadius_admin_css_custom_page() {

  wp_register_style('LoginRadius-plugin-page-css', plugins_url('css/loginRadiusStyle.css', __FILE__), array(), '1.0.0', 'all');

  wp_enqueue_style('LoginRadius-plugin-page-css');

}



/**

 * Update message, used in the admin panel to show messages to users.

 */

function LoginRadius_message($message) {

  echo "<div id=\"message\" class=\"updated fade\"><p>$message</p></div>\n";

}



/**

 * Add a settings link to the Plugins page, so people can go straight from the plugin page to the

 * settings page.

 */

function LoginRadius_filter_plugin_actions($links, $file) {

    static $this_plugin;

    if (!$this_plugin)
	{
        $this_plugin = plugin_basename(__FILE__);
	}
    if ($file == $this_plugin) {

        $settings_link = '<a href="options-general.php?page=LoginRadius">' . __('Settings') . '</a>';

        array_unshift($links, $settings_link); // before other links

    }

    return $links;

}

add_filter('plugin_action_links', 'LoginRadius_filter_plugin_actions', 10, 2);



/**

 * Set Default options when plugin is activated first time.

 */

function loginRadiusActivation() {

  $loginRadiusOptions = get_option('LoginRadius_settings');

  if ( false === $loginRadiusOptions ) {

    // Set plugin default options

    add_option('LoginRadius_settings', array(

										 'LoginRadius_loginform' => '1',

										 'LoginRadius_regform' => '1',

										 'LoginRadius_loginformPosition' => 'embed',

										 'LoginRadius_regformPosition' => 'embed',

										 'LoginRadius_commentform' => '1'

										));

  }

}

register_activation_hook(__FILE__, 'loginRadiusActivation');?>
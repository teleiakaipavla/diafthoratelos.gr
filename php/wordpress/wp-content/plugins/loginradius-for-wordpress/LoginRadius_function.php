<?php 

/**
 * Function that process callback redirection.
 */
function get_redirect_location($http) {
  $loc = urlencode($http.$_SERVER["HTTP_HOST"] . $_SERVER["REQUEST_URI"]);
  if (urldecode($loc) == wp_login_url() OR urldecode($loc) == site_url().'/wp-login.php?action=register' OR urldecode($loc) ==site_url().'/wp-login.php?loggedout=true') {
    $loc = site_url().'/';
  }
  elseif (urldecode($_GET['redirect_to']) == admin_url()) {
    $loc = site_url().'/';
  }
  elseif (isset($_GET['redirect_to'])) {
    $loc = $_GET['redirect_to'];
  }
  else {
    $loc = urlencode($http.$_SERVER["HTTP_HOST"] . $_SERVER["REQUEST_URI"]);
  }
  return $loc;
}

/**
 * Function that shows social icons on wp.
 */
function Login_Radius_Connect_button($newInterface = false) {
  global $LoginRadius_settings;
  $title = $LoginRadius_settings['LoginRadius_title'];
  if (!is_user_logged_in()) { 
    if ($newInterface) {
      $result = "<div style='margin-bottom: 3px;'><label>".$title."</label></div>".Login_Radius_get_interface( $newInterface );
      return $result;
    }
    else {?>
      <div>
      <div style='margin-bottom: 3px;'><label><?php _e( $title, 'LoginRadius' ) ?></label></div><?php 
      Login_Radius_get_interface($newInterface);?>
      </div><?php
    }
  }
}

/**
 * Function that shows social icons on wp.
 */ 
function Login_Radius_get_interface( $newInterface=false ) {
  $LoginRadius_settings = get_option ('LoginRadius_settings');
  $LoginRadius_apikey = trim($LoginRadius_settings['LoginRadius_apikey']);
  $LoginRadius_secret = trim($LoginRadius_settings['LoginRadius_secret']);
  $loginRadiusError = "<p style ='color:red;'>Your LoginRadius API key and secret is not valid, please correct it or contact LoginRadius support at <b><a href ='http://www.loginradius.com' target = '_blank'>www.LoginRadius.com</a></b></p>";
  
  $loginRadiusConnErr = "<p style ='color:red;'>Your API connection setting not working. try to change setting from module option or check your php.ini setting for (<b>cURL support = enabled</b> OR <b>allow_url_fopen = On</b>)</p>";
  
  $loginRadiusEmpty = "<p style ='color:red;'>To activate your plugin, please log in to LoginRadius and get API Key & Secret. Web: <b><a href ='http://www.loginradius.com' target = '_blank'>www.LoginRadius.com</a></b></p>";
  
  if($LoginRadius_apikey == "" && $LoginRadius_secret == ""){
      if (!$newInterface)
	  {
        echo $loginRadiusEmpty;
	  	return;
      }
	  else
      { 
		return $loginRadiusEmpty;
      }
  }
  
  if (isset($LoginRadius_apikey)) {
    require_once ('LoginRadiusSDK.php');
    $obj_auth = new LoginRadius();
    $UserAuth = $obj_auth->loginradius_get_auth($LoginRadius_apikey, $LoginRadius_secret);
    if ($UserAuth == "invalid") {
	
      if (!$newInterface)
	  {
        echo $loginRadiusError;
	  	return;
      }
	  else
      { 
		return $loginRadiusError;
      }
    }
	
	if( $UserAuth == "api connection")
	{
	   if (!$newInterface)
	   {
		 echo $loginRadiusConnErr;
		 return;
	   }
	   else
	   { 
		 return $loginRadiusConnErr;
	   }
	}
	
    $IsHttps = (!empty($UserAuth->IsHttps) ? $UserAuth->IsHttps : '');
    $iframeHeight = (!empty($UserAuth->height) ? $UserAuth->height : 50);
    $iframeWidth = (!empty($UserAuth->width) ? $UserAuth->width : 169);
    $http = ($IsHttps == 1 ? "https://" : "http://");
    $loc = get_redirect_location($http);
    $loginRadiusResult = "<iframe src=".$http."hub.loginradius.com/Control/PluginSlider.aspx?apikey=".$LoginRadius_apikey."&callback=".$loc." width='".$iframeWidth."' height='".$iframeHeight."' frameborder='0' scrolling='no' allowtransparency='true' ></iframe>";
    if (!$newInterface)
	{
      echo $loginRadiusResult;
    }
	else
    {
	  return $loginRadiusResult;
  	}
  }
}

/**
 * Function that shows social icons in widget area.
 */	
function Login_Radius_widget_Connect_button( ) {
  if (!is_user_logged_in()) { 
    Login_Radius_get_interface();
  }
  // On user Login show user details.
  if (is_user_logged_in() && !is_admin()) {
    global $LoginRadius_settings;
    global $user_ID; $size ='60';
    $user = get_userdata($user_ID);
    echo "<div style='height:80px;width:180px'><div style='width:63px;float:left;'>";
    if (($user_thumbnail = get_user_meta ($user_ID, 'thumbnail', true)) !== false) {
      if (strlen (trim ($user_thumbnail)) > 0) {
	    echo '<img alt="user social avatar" src="'.$user_thumbnail.'" height = "'.$size.'" width = "'.$size.'" style="border:2px solid #e7e7e7;"/>';
      }
	  else {
	    echo get_avatar( $user_ID, $size, $default, $alt );  
	  }
    }
	echo "</div><div style='width:110px;float:right;'>";
	_e($user->user_login,  'LoginRadius') ;
	//$redirect = get_permalink();
	if ($LoginRadius_settings['LoginRadius_loutRedirect'] == 'custom' && !empty($LoginRadius_settings['custom_loutRedirect']))
	{
	  $redirect = htmlspecialchars($LoginRadius_settings["custom_loutRedirect"]);
	}
	else
	{
	  $redirect = home_url();?><br />
     <?php 
	 }
	 ?>
	  <a href="<?php echo wp_logout_url($redirect);?>"><?php _e('Log Out', 'LoginRadius');?></a></div></div><?php 
  }
}
$LoginRadius_settings = get_option('LoginRadius_settings');

// social share
if( is_active_widget(false, false, 'loginradiusshare', true) || $LoginRadius_settings['LoginRadius_sharetop'] == '1' || $LoginRadius_settings['LoginRadius_sharebottom'] == '1' )
{
	include('LoginRadius_socialShare.php');
}

// Social Login location
include('LoginRadius_location.php');

if ($LoginRadius_settings['LoginRadius_loginform'] == '1' && $LoginRadius_settings['LoginRadius_loginformPosition'] == "embed") {
  add_action( 'login_form','Login_Radius_Connect_button');
      add_action('bp_before_sidebar_login_form', 'Login_Radius_Connect_button');

}
if (($LoginRadius_settings['LoginRadius_loginform'] == '1' && $LoginRadius_settings['LoginRadius_loginformPosition'] == "beside") || ($LoginRadius_settings['LoginRadius_regform'] == '1' && $LoginRadius_settings['LoginRadius_regformPosition'] == "beside")) {  	  add_action('login_head', 'loginRadiusLoginInterface');
     if($LoginRadius_settings['LoginRadius_loginformPosition'] == "beside")
	 {
	 	 add_action('bp_before_sidebar_login_form', 'Login_Radius_Connect_button');
	 }
	 if($LoginRadius_settings['LoginRadius_regformPosition'] == "beside")
	 {
 
		  add_action('bp_before_account_details_fields', 'Login_Radius_Connect_button');
  		}
}
if ($LoginRadius_settings['LoginRadius_regform'] == '1' && $LoginRadius_settings['LoginRadius_regformPosition'] == "embed") {
  add_action( 'register_form', 'Login_Radius_Connect_button');
  add_action( 'after_signup_form','Login_Radius_Connect_button');
      add_action('bp_before_account_details_fields', 'Login_Radius_Connect_button');

}
if ($LoginRadius_settings['LoginRadius_commentform'] == '1') {
  if ( get_option('comment_registration') && !$user_ID ) {
    add_action( 'comment_form_must_log_in_after','Login_Radius_Connect_button');
  }
  else {
    add_action( 'comment_form_top','Login_Radius_Connect_button');
  }
}

/**
 * Function for redirects user after login.
 */	
function LoginRadius_redirect() {
  $LoginRadius_settings = get_option ('LoginRadius_settings');
  $LoginRadius_redirect = $LoginRadius_settings['LoginRadius_redirect'];
  $LoginRadius_redirect_custom_redirect = $LoginRadius_settings['custom_redirect'];
  $redirect_to = site_url();
  $redirect_to_safe = false;
  if (!empty($_GET['redirect_to'])) {
    $redirect_to = $_GET['redirect_to'];
    $redirect_to_safe = true;
  }
  else {
    if (isset($LoginRadius_redirect)) {
      switch (strtolower($LoginRadius_redirect)) {
        case 'homepage':
          $redirect_to = site_url().'/';
		  break;
		  
		case 'dashboard':
		  $redirect_to = admin_url();
		  break;
		  
		case 'custom':
		  if (isset ($LoginRadius_redirect) && strlen(trim($LoginRadius_redirect_custom_redirect)) > 0) {
            $redirect_to = trim($LoginRadius_redirect_custom_redirect);
          }
		  break;
		
		default:
		  case 'samepage':
		    $redirect_to = $_GET['callback'];
		  break;
      }
    }
  }
  include_once( ABSPATH . 'wp-admin/includes/plugin.php' );
  if( is_plugin_active("buddypress/bp-loader.php") ){
		if(isset($LoginRadius_redirect) && strtolower($LoginRadius_redirect) == "samepage" ){
			$redirect_to = site_url().$_SERVER['REQUEST_URI'];
		}
		
		bp_core_redirect($redirect_to);
  }else {
	  if ($redirect_to_safe) {
		wp_redirect($redirect_to);
	  }
	  else {
		wp_safe_redirect($redirect_to); 
	  }
  }
}

/**
 * Function for shows share bar.
 */	  
function loginradius_share_output() {
  $loginRadiusShareSettings = new LoginRadius();
  global $LoginRadius_settings;
  $lrSocialInterface = $loginRadiusShareSettings ->loginradius_get_sharing($LoginRadius_settings['LoginRadius_apikey']);
  echo '<script type="text/javascript" src="//share.loginradius.com/Content/js/Wp_LoginRadiusSharing.js" id="lrsharescript"></script>'; 
  
	
	echo '<script>
			jQuery(document).ready(function( $ ){$(".loginradiusshare").LoginRadiusShare('.$lrSocialInterface.'); });  
			</script>';

}

/**
 * Function for shows share bar title.
 */		
function loginradius_share_title() {
  global $LoginRadius_settings;
  $html = '<!-- Start Sociable --><div class="loginradius">';
  // If a tagline is set, display it above the social icons
  $tagline = isset( $LoginRadius_settings['LoginRadius_share_title'] ) ? $LoginRadius_settings['LoginRadius_share_title'] : '' ;
  if (!empty($tagline)) {
    $html .= '<div class="loginradius_tagline">';
    $html .= "<a class='loginradius_tagline' target='_blank' href='http://loginradius.com' style='color:#333333;text-decoration:none'>".$tagline."</a>";
    $html .= "</div>";
  }
  return $html;
}

/**
 * Function for auto approve comment if uses sociallogin.
 */
function loginradius_comment_approved($approved) {
  global $LoginRadius_settings;
  if (empty($approved)) {
    $LoginRadius_settings = get_option ('LoginRadius_settings');
    if ($LoginRadius_settings['LoginRadius_autoapprove'] == '1') {
      $user_id = get_current_user_id();
      if (is_numeric($user_id)) {
        $comment_user = get_user_meta ($user_id, 'id', true);
        if ($comment_user !== false) {
          $approved = 1;
        }
      }
    }
  }
  return $approved;
}
add_action('pre_comment_approved', 'loginradius_comment_approved');?>
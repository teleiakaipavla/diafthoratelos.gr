<?php
$page_id = $_GET["page_id"];
$page_data = get_page( $page_id );

$category_title = single_cat_title( $category_id, false );


$current_title = 'Τελεία και παύλα';

if ((strlen($category_title) != 0) || (strlen($page_data->post_title) != 0))
{
	$current_title = $current_title.' - '.$page_data->post_title.$category_title;
}
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title><?php echo $current_title; ?></title>
    

	<link href="css/style.css" rel="stylesheet" type="text/css" />
    <script src="js/jquery/jquery-1.6.1.min.js" type="text/javascript"></script>
    <script src="js/global.js" type="text/javascript"></script>
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:700,800,400,600&subset=latin,greek' rel='stylesheet' type='text/css'>
  <link href="js/nkal/dropdown/scroll/jquery.jscrollpane.css" rel="stylesheet" type="text/css" />
     <script src="js/nkal/dropdown/scroll/jquery.mousewheel.js" type="text/javascript"></script>
    <script src="js/nkal/dropdown/scroll/jquery.jscrollpane.js" type="text/javascript"></script>
    <link href="js/nkal/dropdown/dropdown.css" rel="stylesheet" type="text/css" />
    <script src="js/nkal/dropdown/dropdown.js" type="text/javascript"></script>
 <script src="js/sum.js" type="text/javascript"></script>



	        <meta name="name" content="Τελεία και παύλα" />
		<meta name="description" content="Η δράση μας έχει στόχο να δώσει βήμα και φωνή σε όσους από μας θέλουν έμπρακτα να αναδείξουν και να πολεμήσουν το πρόβλημα της διαφθοράς στην Ελλάδα. Μέσα από την καταγραφή περιστατικών διαφθοράς θα μπορέσουμε να εκτιμήσουμε τον οικονομικό και ηθικό αντίκτυπο στην κάθε επιμέρους κοινότητα που κινούμαστε, στο σχολείο, στη δουλειά, στη γειτονιά, στο χώρο της υγείας, στις δημόσιες υπηρεσίες, στο Δήμο. Στην καθημερινότητά μας συνολικά." />
	        <meta name="keywords" />
	
					<meta property="og:title" content="<?php echo $current_title; ?>" />
					<meta property="og:description" content="Η δράση μας έχει στόχο να δώσει βήμα και φωνή σε όσους από μας θέλουν έμπρακτα να αναδείξουν και να πολεμήσουν το πρόβλημα της διαφθοράς στην Ελλάδα. Μέσα από την καταγραφή περιστατικών διαφθοράς θα μπορέσουμε να εκτιμήσουμε τον οικονομικό και ηθικό αντίκτυπο στην κάθε επιμέρους κοινότητα που κινούμαστε, στο σχολείο, στη δουλειά, στη γειτονιά, στο χώρο της υγείας, στις δημόσιες υπηρεσίες, στο Δήμο. Στην καθημερινότητά μας συνολικά." />
					<meta property="og:image" content="http://www.teleiakaipavla.gr/images/global/fb_logo.png"/>

					

	        <meta name="author" content="Τελεία και παύλα"/>
			<meta name="copyright" content="2012 Τελεία και παύλα"/>
			<meta name="revisit-after" content="7 days"/>
	        <link rel="shortcut icon" href="images/global/favicon.ico" />
	        <link rel="image_src" href="images/global/fb_logo.png" />
			
</head>
<body>

	<!--Popup Start        -->
	    <div class="popupMain">
	        <div class="popup">
	            <div class="popup-close">
	                <a onclick="$('.popupMain').hide()"><img src="images/global/close.png" /></a>
	            </div>
	            <div class="readmore">
	                <div class="stars pl5">&nbsp;</div>
	                <div class="txt">Προστασία προσωπικών δεδομένων</div>
	                <div class="stars"></div>
	                <div class="clear"></div><div class="clear"></div>
	                <div class="popup-holder">
	                    <div>
	                 		<?php $id=82; $post = get_page($id); $content = apply_filters('the_content', $post->post_content); echo $content;  ?>
	                    </div>

	                </div>
	            </div>
	        </div>
	    </div>
	<!--Popup End        -->
    <div class="master">
	
	    <div id="Header">
		
		    <div class="master-logo-holder-new">
            <!--Social Start        -->
                <div class="social">
                    <div class="fb"><a target="_blank" href="http://www.facebook.com/share.php?u=http://www.teleiakaipavla.gr"><img border="0" src="images/global/facebook.png" /></a></div>
                    <div class="tw"><a target="_blank" href="http://twitter.com/home?status=http://www.teleiakaipavla.gr"><img border="0" src="images/global/twitter.png" /></a></div>
                    <div class="bb"><a href="#"><img border="0" src="images/global/b.png" /></a></div>
                    <div class="mail"><a href="?page_id=139"><img border="0" src="images/global/mail.png" /></a></div>
                </div>

            <!--Social End        -->
		

                <div class="logo"><div class="logobeta"><img src="images/global/beta.png" /></div>
	<a href="<?php echo get_option( 'home' ); ?>"><img border="0" src="images/global/logo.png" /></a></div>
                <div class="menu">
                    <ul id="menu">
                    </ul>
                    <div>
                        <img src="images/global/kinimapolitontext.png" />
                    </div>
                </div>
                <div class="clear"></div>
            </div>
           <div class="master-black-hole-new"><a href="?cat=20">
	             <?php if (($cat == 16) || ($cat == 18)) {  ?>
			   <div style="position:absolute;margin-left:243px;margin-top:10px"><img src="images/global/blackholeover.png" /></div>             
				<?php }?>
	
	          
                <div class="text">Xρήμα που <b>χάθηκε</b> στη μαύρη τρύπα!</div>
                <div class="money"></div>
                <div class="clear"></div>
				</a>
            </div>
            <div class="clear"></div>
        </div>
<!--Header Start        -->


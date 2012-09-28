<?php
get_header();

?>

<script type="text/javascript"
    src="http://maps.googleapis.com/maps/api/js?key=AIzaSyDaNazRRfP1_qU91WrC3J5XAtH4buXQbnA&sensor=false">
  </script>


<script type="text/javascript">var incident_id = "<?php echo $_GET['inc'] ?>";</script>
<script src="js/good_incident.js" type="text/javascript"></script>


<div class="content">
       <h1 class="goodnews-icon"><?php echo single_cat_title( $category_id ); ?></h1>
       <div class="subtext" id="incid_meta"></b></div>
       <div><br /></div>
       <div class="text exeisimvikaisemena">
          <div class="PeristatikoIn-TextLeft-big" id="incid_desc">
            
          </div>
           <div class="PeristatikoIn-MapCenter" id="googlemaps">

          </div>
 <div class="clear"></div>
           <br /><br />
		<a href="?cat=14">Δες περισσότερα καλά νέα</α>
           <br />
       </div>
       <div class="readmore">
           <div class="shareit">Μοιράσου το</div>

		<?php 
			$fburl = 'http://www.facebook.com/share.php?&u='.urlencode('http://www.teleiakaipavla.gr?cat=22&inc='.$_GET['inc']);
			$turl = 'http://twitter.com/home?status='.urlencode('http://www.teleiakaipavla.gr?cat=22&inc='.$_GET['inc']);
		 ?>

		           <div class="left fbicon" ><a target="_blank" href="<?php echo $fburl; ?>"><img border="0" src="images/global/facebook.png" /></a></div> 
		           <div class="left twicon" ><a target="_blank"href="<?php echo $turl; ?>"><img border="0" src="images/global/twitter.png" /></a></div>
           <div class="left btanafora"><a href="?cat=16"><img border="0" src="images/global/btnAnafereto.png" /></a></div>
           <div class="clear"></div>
       </div>
   </div>

<?php
get_footer();
?>

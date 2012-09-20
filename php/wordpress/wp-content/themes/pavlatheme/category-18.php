<?php
get_header();
?>
    <div class="content">
	
		   <h1 class="exeisimvikaisemena-icon"><?php echo single_cat_title( $category_id ); ?></h1>
	        <div class="subtext"><?php echo category_description( $category_id );  ?></div>

         <div class="readmore">
            <div class="starts">* * *</div>
            <div class="txt">ΤΑ ΣΤΟΙΧΕΙΑ ΥΠΟΒΑΛΛΟΝΤΑΙ ΑΝΩΝΥΜΑ</div>
            <div class="starts">* * *</div>
            <div class="link"><a href="#">Μάθε περισσότερα</a></div>
        </div>
        <div class="text">
            <iframe src="http://www.teleiakaipavla.gr/backkick/incidents/new" width="100%" height="740" frameborder="0" >
            
            </iframe>
       
        </div>
    </div>
        
	<?php
	get_footer();
	?>

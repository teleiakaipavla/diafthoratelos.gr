<?php
get_header();
?>
<div class="content">

	   <h1 class="exeisimvikaisemena-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>

    <div class="text">
        <iframe src="http://www.teleiakaipavla.gr/backkick/places/where_it_happens" width="100%" height="770" frameborder="0" >
        	
        </iframe>
   
    </div>


</div>
<?php
get_footer();
?>

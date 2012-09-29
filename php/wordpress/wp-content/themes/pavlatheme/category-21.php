<?php
get_header();
?>
<?php wp_enqueue_script("jquery"); ?><!--VERY IMPORTANT-->
<script src="js/faq.js" type="text/javascript"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.js" type="text/javascript"></script>
<script src="js/jquery/jquery-ui-1.8.9.custom.min.js" type="text/javascript"></script>
<script src="js/jquery/jquery.scrollTo-1.4.3.1-min.js" type="text/javascript"></script>

<div class="faqcontent">
    <h1 class="sxetika-icon"><?php echo single_cat_title( $category_id ); ?></h1>
    <div class="subtext"><?php echo category_description( $category_id );  ?></div>
	<div class="text">

		<?php  
		      query_posts('post_type=faq&order=ASC&posts_per_page=-1')  
		  ?>

	        <div id="questions" >  
	            <ul>  
	                <?php while (have_posts()) : the_post(); ?>  
	                <li ><a href="#answer<?php the_id() ?>"><?php the_title(); ?></a></li>  
	                <?php endwhile; ?>  
	            </ul>  
	        </div>  
	
	<?php rewind_posts(); ?> 
	<BR/>
	    <div id="answers">  
	        <ul>  
	            <?php while (have_posts()) : the_post(); ?>  
	                <li id="answer<?php the_id(); ?>">  
	                    <h4><?php the_title(); ?></h4>  
	                    <?php the_content(); ?>  
	                </li>  
	            <?php endwhile; ?>  
	        </ul>  
	    </div>  
	    <?php wp_reset_query(); ?>  
		</div>
	</div>
<?php
get_footer();
?>

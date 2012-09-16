<?php
get_header();
?>


	<?php
	$page_id = $_GET["page_id"];
	$page_data = get_page( $page_id );

	?>





    <div class="content">
        <h1 class="<?php echo get_post_meta($page_id, 'blue-icon', true); ?>"><?php echo $page_data->post_title; ?></h1>

        <div class="subtext"><?php echo get_post_meta($page_id, 'small-header', true); ?></div>

        <div class="text">

	<?php echo apply_filters('the_content', $page_data->post_content); ?>

        </div>

    </div>
<?php
get_footer();
?>

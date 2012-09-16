<?php
get_header();
?>

    <div class="content">
        <h1 class="pousimveni-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>
        <div class="text">
            <iframe width="896" height="898" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=el&amp;geocode=&amp;q=greece,athens&amp;aq=&amp;sll=35.51383,24.018037&amp;sspn=0.062109,0.132093&amp;t=m&amp;ie=UTF8&amp;hq=&amp;hnear=%CE%91%CE%B8%CE%AE%CE%BD%CE%B1,+%CE%9A%CE%B5%CE%BD%CF%84%CF%81%CE%B9%CE%BA%CF%8C%CF%82+%CE%A4%CE%BF%CE%BC%CE%AD%CE%B1%CF%82+%CE%91%CE%B8%CE%B7%CE%BD%CF%8E%CE%BD,+%CE%95%CE%BB%CE%BB%CE%AC%CE%B4%CE%B1&amp;z=13&amp;ll=37.983715,23.72931&amp;output=embed"></iframe><br /><small></small>
        </div>
        
    </div>
<?php
get_footer();
?>
